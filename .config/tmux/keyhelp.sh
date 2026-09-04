#!/usr/bin/env bash
# -------------------------------------------------------------
#  tmux-keyhelp.sh
#  Lists every binding with its description in fzf.
#  Enter runs the selected command.
#
#  Install to: ~/.config/tmux/keyhelp.sh   (chmod +x)
#  Invoked from display-popup, see ~/.config/tmux/tmux.conf
#  Requires:   tmux 3.2+, fzf, awk
#
#  Deliberately avoids associative arrays and "column" so it also
#  runs under the ancient bash 3.2 that ships with macOS.
#
#  Troubleshooting: every run appends to /tmp/tmux-keyhelp.log.
#  If the popup only flickers, look there first.
# -------------------------------------------------------------

set -u

LOG=/tmp/tmux-keyhelp.log
TAB=$(printf '\t')

log() { printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" >> "$LOG"; }

# Hold the popup open so the message is readable. Without this,
# display-popup -E closes the moment the script exits -- including
# on an error, which looks like a brief flicker and nothing else.
hold() {
    printf '\n  %s\n\n  Press any key to close...' "$1"
    read -r _ </dev/tty 2>/dev/null || sleep 5
}

log "--- start (bash ${BASH_VERSION:-?}) ---"

# --- Dependency check ----------------------------------------
for tool in tmux fzf awk; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        log "missing dependency: $tool"
        hold "Missing: $tool -- please install it."
        exit 1
    fi
done
log "fzf $(fzf --version 2>&1 | head -1)"

tmpd=$(mktemp -d) || { hold "mktemp failed"; exit 1; }
trap 'rm -rf "$tmpd"' EXIT

# Needed to normalise the "list-keys -N" output across tmux versions.
PFX=$(tmux show-options -gv prefix 2>/dev/null || echo C-b)
log "tmux $(tmux -V 2>&1), prefix $PFX"

# Emits one record per binding:  table <TAB> key <TAB> desc <TAB> cmd
collect() {
    table=$1

    tmux list-keys    -T "$table" > "$tmpd/cmd"  2>>"$LOG"
    tmux list-keys -N -T "$table" > "$tmpd/desc" 2>>"$LOG"

    log "$table: $(wc -l < "$tmpd/cmd" | tr -d ' ') bindings, $(wc -l < "$tmpd/desc" | tr -d ' ') descriptions"
    log "$table sample: $(head -1 "$tmpd/desc")"

    # The command file is read first so we know which keys exist.
    # "list-keys -N" formats its output differently across tmux
    # versions -- 3.7 prepends the prefix key to BOTH tables, older
    # ones print the bare key -- so the description line is matched by
    # finding the first token that is a known key, instead of assuming
    # a fixed column.
    awk -v table="$table" -v TAB="$TAB" -v pfx="$PFX" '
        # First pass: keys and commands from "list-keys"
        FNR == NR {
            marker = "-T " table " "
            i = index($0, marker)
            if (i == 0) next
            rest = substr($0, i + length(marker))
            sub(/^[ \t]+/, "", rest)

            key = rest
            sub(/[ \t].*$/, "", key)

            cmd = rest
            sub(/^[^ \t]+[ \t]+/, "", cmd)
            sub(/[ \t]+$/, "", cmd)

            # Skip mouse and menu bindings: you would not want to
            # trigger them here and their commands run for pages
            if (key ~ /Mouse|Wheel|Click/) next
            if (cmd == "") next

            order[++n] = key
            cmds[key]  = cmd
            valid[key] = 1
            next
        }
        # Second pass: descriptions from "list-keys -N"
        {
            # Drop a leading prefix token, otherwise "C-a C-a ..."
            # would match on the first C-a rather than the real key.
            line = $0
            if ($1 == pfx && NF > 2) sub(/^[^ \t]+[ \t]+/, "", line)

            m = split(line, tok, /[ \t]+/)
            pos = 0
            for (j = 1; j <= m; j++) {
                if (tok[j] in valid) { pos = j; break }
            }
            if (pos == 0) next

            d = ""
            for (j = pos + 1; j <= m; j++) d = d (d == "" ? "" : " ") tok[j]
            if (d != "") desc[tok[pos]] = d
        }
        END {
            for (k = 1; k <= n; k++) {
                key = order[k]
                printf "%s%s%s%s%s%s%s\n", \
                    table, TAB, key, TAB, (key in desc ? desc[key] : ""), TAB, cmds[key]
            }
        }
    ' "$tmpd/cmd" "$tmpd/desc"
}

# Merge both tables into one line per command, so a binding that
# exists with and without the prefix is listed once with both ways
# to trigger it shown side by side.
{ collect root; collect prefix; } | awk -v TAB="$TAB" -v pfx="$PFX" '
    {
        split($0, f, TAB)
        table = f[1]; key = f[2]; d = f[3]; cmd = f[4]

        # Group by a normalised form of the command: tmux writes its
        # own window targets as "-t :=3" while a hand-written binding
        # says "-t 3". Same effect, so they should share a line.
        # The original command is kept for execution.
        gkey = cmd
        gsub(/-t :=/, "-t ", gkey)
        gsub(/[ \t]+$/, "", gkey)

        if (!(gkey in seen)) { seen[gkey] = 1; order[++n] = gkey }
        if (!(gkey in real)) real[gkey] = cmd

        if (table == "root") {
            plain[gkey] = plain[gkey] (plain[gkey] == "" ? "" : " ") key
            hasplain[gkey] = 1
            real[gkey] = cmd          # prefer the hand-written variant
        } else {
            withpfx[gkey] = withpfx[gkey] (withpfx[gkey] == "" ? "" : " ") pfx " " key
        }
        if (d != "" && !(gkey in desc)) desc[gkey] = d
    }
    END {
        # Bindings reachable without the prefix come first -- those are
        # the ones used all day.
        for (pass = 1; pass <= 2; pass++) {
            for (k = 1; k <= n; k++) {
                gkey = order[k]
                if (pass == 1 && !(gkey in hasplain)) continue
                if (pass == 2 &&  (gkey in hasplain)) continue

                p = (gkey in withpfx) ? withpfx[gkey] : ""
                q = (gkey in plain)   ? plain[gkey]   : ""
                d = (gkey in desc)    ? desc[gkey]    : real[gkey]

                if (length(d) > 42) d = substr(d, 1, 39) "..."
                if (length(p) > 15) p = substr(p, 1, 15)

                printf "%-16s%s%-14s%s%-42s%s%s\n", p, TAB, q, TAB, d, TAB, real[gkey]
            }
        }
    }
' > "$tmpd/list"

lines=$(wc -l < "$tmpd/list" | tr -d ' ')
log "collected $lines bindings"

if [ "$lines" -eq 0 ]; then
    hold "No bindings found -- is this running inside tmux?"
    exit 1
fi

# Do NOT redirect fzf's stderr here. Up to roughly 0.5x, fzf draws its
# entire interface on stderr and only newer versions moved that to
# /dev/tty -- so a "2> file" swallows the whole list and leaves an
# empty popup. Measured with this exact call: 0.44.1 (the version in
# Ubuntu 24.04) sent 16 KB of UI to the file and 170 bytes to the
# terminal, 0.74.3 the other way round. That is why the popup was
# empty on one machine and fine on another with identical tmux.
# A startup error from fzf now simply stays visible in the popup,
# which "hold" below keeps open long enough to read.
#
# Exit codes: 0 = picked, 1 = no match,
# 130 = cancelled by the user, anything else = fzf itself failed.
sel=$(fzf --delimiter="$TAB" \
          --with-nth=1,2,3 \
          --preview 'printf "%s" {4}' \
          --preview-window=down,3,wrap \
          --header='with prefix             plain           description
Enter runs it  |  Esc cancels' \
          --prompt='Binding > ' \
          < "$tmpd/list")
rc=$?
log "fzf exit $rc"

if [ "$rc" -ne 0 ] && [ "$rc" -ne 1 ] && [ "$rc" -ne 130 ]; then
    log "fzf error: exit $rc (message printed above)"
    hold "fzf failed (exit $rc) -- see the message above."
    exit 1
fi

[ -z "$sel" ] && exit 0

cmd=$(printf '%s' "$sel" | awk -F"$TAB" '{print $4}')
[ -z "$cmd" ] && exit 0

# list-keys prints chained commands as "\;" (shell notation);
# source-file expects a plain ";" there.
cmd=$(printf '%s' "$cmd" | sed 's/\\;/;/g')
log "running: $cmd"

# Hand the command to the tmux server instead of backgrounding a
# subshell here: when the popup closes, everything in its process
# group dies, so a "sleep 0.1 & " child would be killed before it runs.
# run-shell -b is executed by the server itself and survives.
#
# The short delay lets the popup close first -- otherwise interactive
# commands (choose-tree, copy-mode) would open inside a window that is
# disappearing at that very moment.
#
# "source-file" lets tmux parse the command itself, so quotes and
# #{...} formats survive -- unlike with eval.
run=$(mktemp) || exit 1
printf '%s\n' "$cmd" > "$run"
tmux run-shell -b "sleep 0.15; tmux source-file '$run'; rm -f '$run'"

exit 0