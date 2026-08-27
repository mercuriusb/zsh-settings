# tmux Cheat Sheet — matching this config

**Prefix is `Ctrl-a`** (not `Ctrl-b`).
`prefix r` means: press `Ctrl-a`, release, then `r`.
`M-` is the Alt key; uppercase letters mean Alt + Shift.

---

## No prefix — everyday keys

### Panes

| Key | Action |
|---|---|
| `M-h` `M-j` `M-k` `M-l` | Focus pane left / down / up / right |
| `M-Enter` | Split vertically — new pane on the right |
| `M-v` | Split horizontally — new pane below |
| `M-z` | Toggle zoom |
| `M-q` | Kill pane (no confirmation) |
| `M-H` `M-J` `M-K` `M-L` | Resize in that direction |

New panes always start in the current pane's directory.

### Windows

| Key | Action |
|---|---|
| `M-1` … `M-9` | Jump straight to window N |
| `M-c` | New window |
| `M-o` | Back to the last window |

### Overview

| Key | Action |
|---|---|
| `M-w` | Browse all sessions and windows |
| `M-↑` | Enter copy mode (scroll, search, copy) |

### Help

| Key | Action |
|---|---|
| `M-?` | This cheat sheet in a popup (`q` to close) |
| `M-F1` | Search all bindings — **Enter runs it**, `Esc` cancels |

Requires `~/.config/tmux/cheatsheet.md` and `~/.config/tmux/keyhelp.sh`.

---

## With prefix — used less often

### Sessions

| Key | Action |
|---|---|
| `prefix d` | Detach — keeps running in the background |
| `prefix s` | Session list |
| `prefix $` | Rename session |
| `prefix (` / `prefix )` | Previous / next session |

### Windows and panes

| Key | Action |
|---|---|
| `prefix c` | New window |
| `prefix ,` | Rename window |
| `prefix &` | Kill window (with confirmation) |
| `prefix H` / `prefix L` | Move window left / right in the status bar |
| `prefix \|` | Split vertically |
| `prefix -` | Split horizontally |
| `prefix Space` | Cycle through layouts |
| `prefix q` | Show pane numbers |
| `prefix {` / `prefix }` | Swap pane position |

### Extras

| Key | Action |
|---|---|
| `prefix r` | Reload config |
| `prefix S` | Toggle sync — input goes to every pane |
| `prefix g` | lazygit in a popup |
| `prefix ?` | Show all key bindings |
| `prefix :` | tmux command prompt |

---

## Copy mode (Vim keys)

| Key | Action |
|---|---|
| `M-↑` or `prefix [` | Enter copy mode |
| `h j k l` | Move around |
| `Ctrl-u` / `Ctrl-d` | Half page up / down |
| `g` / `G` | Start / end of the scrollback |
| `/` `?` | Search forward / backward, `n` for next |
| `v` | Start selection |
| `y` | Copy and leave copy mode |
| `prefix ]` | Paste |
| `q` or `Esc` | Cancel |

For the system clipboard, uncomment the matching `copy-pipe` line in the
config (`pbcopy`, `xclip` or `wl-copy`).

---

## From the shell

| Command | Action |
|---|---|
| `tmux` | New session |
| `tmux new -s name` | New named session |
| `tmux ls` | List sessions |
| `tmux attach -t name` | Attach |
| `tmux kill-session -t name` | Kill one session |
| `tmux kill-server` | Kill everything |
| `tmux list-keys -T root` | Show all bindings that need no prefix |

---

## Left alone for zsh

These Alt combinations are deliberately **not** bound, because ZLE uses them:

`M-b` `M-f` move by word · `M-d` kill word · `M-Backspace` kill word backwards ·
`M-.` insert last argument · `M-n` `M-p` search history · `M-t` transpose words ·
`M-u` upcase word · `M-y` yank-pop · `M-x` execute-named-cmd

Taken over from zsh by the bindings above: `M-q` `M-h` `M-w` `M-z` `M-l` `M-c`.
Only `push-line` (`M-q`) is worth keeping — move it in `~/.zshrc`:

```zsh
bindkey '^[e' push-line     # was M-q
bindkey '^[r' run-help      # was M-h
```

---

## Setup

```bash
mkdir -p ~/.config/tmux
cp tmux.conf     ~/.config/tmux/tmux.conf
cp cheatsheet.md ~/.config/tmux/cheatsheet.md
cp keyhelp.sh    ~/.config/tmux/keyhelp.sh
chmod +x ~/.config/tmux/keyhelp.sh

# tmux reads EVERY config it finds, in order, and merges them.
# An old ~/.tmux.conf is still applied first, so settings that
# only exist there stay active. Remove it after moving:
rm -f ~/.tmux.conf

tmux kill-server        # or inside tmux:  prefix r
tmux
```

`M-?` needs `glow` for rendering (`brew install glow` or your
distribution's package), `M-F1` needs `fzf`. Check that zsh really lives
at `/bin/zsh` with `command -v zsh` and adjust `default-shell` if not.

**macOS:** the Option key has to send Meta, otherwise none of the Alt
bindings work.
iTerm2: Profiles → Keys → Left Option Key → `Esc+`.
Terminal.app: Settings → Keyboard → "Use Option as Meta key".

---

## Worth memorising first

`M-h/j/k/l` to move, `M-z` to zoom, `M-w` for the overview,
`prefix d` to detach. Everything else follows on its own.