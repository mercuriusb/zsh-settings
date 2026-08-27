# zsh-settings

A personal ZSH configuration with completions, aliases and plugins, plus a
tmux setup whose everyday bindings work without the prefix.

Paths in this repository mirror `$HOME` — `.zshrc` belongs at `~/.zshrc`,
`.config/tmux/` at `~/.config/tmux/`.

## Required packages

| Package | Needed for | apt (Debian/Ubuntu) | brew (macOS) |
|---------|------------|---------------------|--------------|
| `zsh` | the shell itself | `sudo apt install zsh` | pre-installed |
| `tmux` 3.2+ | `display-popup` and `bind -N`, both used by the config | `sudo apt install tmux` | `brew install tmux` |
| `eza` | `ll`, `la`, `l` and the `cd` completion preview | `sudo apt install eza` | `brew install eza` |
| `bat` | the `bat` and `less` aliases | `sudo apt install bat` | `brew install bat` |
| `fzf` | `fzf-tab` completion and the `M-F1` binding search | `sudo apt install fzf` | `brew install fzf` |

## Recommended packages

### Shell & file utilities

| Package | apt (Debian/Ubuntu) | brew (macOS) |
|---------|---------------------|--------------|
| `fd` — fast file finder | `sudo apt install fd-find` | `brew install fd` |
| `sd` — intuitive sed alternative | `sudo apt install sd` | `brew install sd` |
| `dos2unix` | `sudo apt install dos2unix` | `brew install dos2unix` |
| `mc` — midnight commander | `sudo apt install mc` | `brew install midnight-commander` |
| `locate` | `sudo apt install locate` | built-in (`mdfind` / `locate` via `brew install findutils`) |
| `htop` | `sudo apt install htop` | `brew install htop` |
| `tldr` | `sudo apt install tldr` | `brew install tlrc` |

### Network & web

| Package | apt (Debian/Ubuntu) | brew (macOS) |
|---------|---------------------|--------------|
| `netstat` | `sudo apt install net-tools` | built-in on macOS |
| `telnet` | `sudo apt install telnet` | `brew install telnet` |
| `httpie` | `sudo apt install httpie` | `brew install httpie` |

### Viewing & logging

| Package | apt (Debian/Ubuntu) | brew (macOS) |
|---------|---------------------|--------------|
| `lnav` — log file navigator | `sudo apt install lnav` | `brew install lnav` |
| `pandoc` | `sudo apt install pandoc` | `brew install pandoc` |
| `poppler-utils` — PDF tools | `sudo apt install poppler-utils` | `brew install poppler` |

### Database

| Package | apt (Debian/Ubuntu) | brew (macOS) |
|---------|---------------------|--------------|
| `pgbadger` | `sudo apt install pgbadger` | `brew install pgbadger` |
| `pg_activity` | `sudo apt install pg-activity` ¹ | `pip install pg_activity` |

> ¹ May require backports on Debian: `pg_activity/bullseye-backports`

### Security & certificates

| Package | apt (Debian/Ubuntu) | brew (macOS) |
|---------|---------------------|--------------|
| `mkcert` | `sudo apt install mkcert` | `brew install mkcert` |
| `libnss3-tools` | `sudo apt install libnss3-tools` | `brew install nss` |
| `libcap2-bin` | `sudo apt install libcap2-bin` | n/a (Linux-only) |

### Backup

| Package | apt (Debian/Ubuntu) | brew (macOS) |
|---------|---------------------|--------------|
| `restic` | `sudo apt install restic` | `brew install restic` |

### Misc

| Package | apt (Debian/Ubuntu) | brew (macOS) |
|---------|---------------------|--------------|
| `jql` — JSON query tool | `sudo apt install jql` | `brew install jql` |
| `grv` — git repository viewer | `sudo apt install grv` | not in homebrew-core; install via `go install github.com/rgburke/grv/cmd/grv@latest` |

### tmux popups

| Package | Needed for | apt (Debian/Ubuntu) | brew (macOS) |
|---------|------------|---------------------|--------------|
| `glow` | renders the cheat sheet in the `M-?` popup | not in the standard repos — see charm.sh/glow | `brew install glow` |
| `lazygit` | the `prefix g` popup | not in the standard repos — see the project's releases | `brew install lazygit` |

> Without `glow` the `M-?` popup stays empty. `tmux.conf` carries commented
> fallbacks using `bat` or `less` right next to that binding.

### Git

| Package | Needed for | apt (Debian/Ubuntu) | brew (macOS) |
|---------|------------|---------------------|--------------|
| `git-delta` | nicer diffs | `sudo apt install git-delta` | `brew install git-delta` |

> Recommended rather than required: this repository ships no `.gitconfig`, so
> nothing here wires delta up. Do it yourself with
> `git config --global core.pager delta`.
>
> The `gacp` alias likewise expects a git alias that is not part of this repo:
> `git config --global alias.acp '!f() { git add . && git commit -m "$@" && git push; }; f'`

## Structure

```
pack-config.sh          # builds config.tgz from the three paths below
config.tgz              # the same content as a ready-to-unpack archive

~/.zshrc                # aliases, history, completion cache, fzf-tab config
~/.zsh/
├── fzf-tab/            # fzf-powered tab completion (copy of Aloxaf/fzf-tab)
├── agnoster/           # agnoster theme
├── eza/                # eza config (theme.yml, Dracula palette)
└── local/              # machine-local *.zsh, plus template.zsh.file to start from
~/.zsh_cache/           # auto-generated completions (regenerated every 7 days)
~/.config/tmux/
├── tmux.conf           # prefix C-a, plus Alt bindings that need no prefix
├── cheatsheet.md       # shown by M-?
└── keyhelp.sh          # searchable list of all bindings, M-F1
```

Only `*.zsh` in `~/.zsh/local/` is sourced, which is why the example is called
`template.zsh.file` — it is ignored until you copy it to something like
`local.zsh`.

## config.tgz

`config.tgz` bundles `.zshrc`, `.zsh/` and `.config/` and is committed to the
repository, so a machine can be set up without cloning anything:

```sh
tar -xzf config.tgz -C ~
rm -f ~/.tmux.conf        # older config, tmux would still merge it in
exec zsh
```

Rebuild it after changing any of those files:

```sh
./pack-config.sh
```

The script needs GNU tar and builds the archive reproducibly — fixed
timestamps, no owner, sorted entries, `gzip -n`. Identical content therefore
yields a byte-identical file, so rebuilding without real changes does not show
up as a diff.

## Features

- **Tab completion** via `fzf-tab` for fuzzy-search completions. Inside tmux the
  candidate list opens as a popup at the cursor; outside it falls back to plain fzf
- **Auto-generated completions** cached in `~/.zsh_cache/`, refreshed every 7 days.
  A failed generator run keeps the previous file instead of caching an empty one
- **Local overrides** — place `*.zsh` files in `~/.zsh/local/` for machine-specific config (e.g. work-specific env vars, paths)
- **Persistent history** — 10 million entries, shared across sessions
- **tmux without the prefix** — Alt bindings for panes, windows and zoom, with
  `M-?` for the cheat sheet and `M-F1` to search every binding and run it

All `fzf-tab` configuration lives in `.zshrc`, not in the vendored plugin folder,
so `.zsh/fzf-tab/` stays a clean copy of upstream.

## tmux

Prefix is `Ctrl-a`. The everyday keys need no prefix at all: `M-h/j/k/l` moves
between panes, `M-z` zooms, `M-w` opens the session and window overview,
`M-1`…`M-9` jump to a window.

`M-?` shows the full cheat sheet in a popup, `M-F1` lists every binding with its
description and runs the one you pick. The list is generated from the config
itself, so it cannot drift out of date.

The complete reference is in [`.config/tmux/cheatsheet.md`](.config/tmux/cheatsheet.md).

tmux reads **every** config file it finds and merges them, so an older
`~/.tmux.conf` still applies alongside `~/.config/tmux/tmux.conf`. Remove it
when migrating:

```sh
rm -f ~/.tmux.conf
```

On macOS the Option key has to send Meta, otherwise none of the Alt bindings
arrive — iTerm2: Profiles → Keys → Left Option Key → `Esc+`.

## Aliases overview

| Group     | Examples                                      |
|-----------|-----------------------------------------------|
| Git       | `gstatus`, `gadd`, `gcm`, `gps`, `glg`, …    |
| Docker    | `dcup`, `dcdown`, `dctail`, `dcud`, …         |
| Maven     | `mvncli`, `mvncliskt`, `mvnverset`, …         |
| Files     | `ll`, `la`, `l` (via eza), `bat`, `less`      |
| rsync     | `rsync-copy`, `rsync-move`, `rsync-synchronize` |
| Misc      | `apt` (sudo), `vi` (vim), `zshreload`         |

## Refresh completions manually

```sh
zsh-completions-refresh
```
