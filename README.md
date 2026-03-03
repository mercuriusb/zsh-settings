# zsh-settings

A personal ZSH configuration with completions, aliases, and plugins.

## Required packages

| Package | apt (Debian/Ubuntu) | brew (macOS) |
|---------|---------------------|--------------|
| `eza` | `sudo apt install eza` | `brew install eza` |
| `bat` | `sudo apt install bat` | `brew install bat` |
| `fzf` | `sudo apt install fzf` | `brew install fzf` |
| `git-delta` | `sudo apt install git-delta` | `brew install git-delta` |

> **Note:** On Debian/Ubuntu, `bat` may be packaged as `batcat`. The config aliases `bat` and `less` to `batcat` accordingly. On macOS via brew, the binary is simply `bat`.

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

## Structure

```
~/.zsh/
├── fzf-tab/            # fzf-powered tab completion
├── agnoster/           # agnoster theme
├── eza/                # eza config
└── local/              # machine-local config files (*.zsh, not tracked)
~/.zsh_cache/           # auto-generated completions (regenerated every 7 days)
```

## Features

- **Tab completion** via `fzf-tab` for fuzzy-search completions
- **Auto-generated completions** cached in `~/.zsh_cache/`, refreshed every 7 days
- **Local overrides** — place `*.zsh` files in `~/.zsh/local/` for machine-specific config (e.g. work-specific env vars, paths)
- **Persistent history** — 10 million entries, shared across sessions

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
