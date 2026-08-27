export ZSH=~/.zsh

source $ZSH/agnoster/agnoster.zsh-theme

# --- ZSH Completions Setup ---
ZSH_COMPLETIONS_DIR="$HOME/.zsh_cache"
mkdir -p "$ZSH_COMPLETIONS_DIR"
fpath=($ZSH_COMPLETIONS_DIR $fpath)

# Completions werden nach 7 Tagen automatisch neu generiert
_generate_completion() {
  local tool=$1
  local file="$ZSH_COMPLETIONS_DIR/_${tool}"
  local max_age_days=7

  # Tool vorhanden?
  if ! command -v "$tool" &>/dev/null; then
    return
  fi

  # Neu generieren wenn Datei fehlt oder zu alt
  if [[ ! -f "$file" ]] || [[ $(find "$file" -mtime +${max_age_days} 2>/dev/null) ]]; then
    echo "Generating completion for $tool..."

    # Erst in eine Temp-Datei schreiben und pruefen. Direkt nach "$file"
    # umgeleitet wuerde ein fehlgeschlagener Aufruf eine leere Datei
    # hinterlassen -- die gilt dann 7 Tage als gueltiger Cache und die
    # Completion ist still kaputt.
    # Punkt-Prefix: liegengebliebene Temp-Dateien wuerden sonst von
    # compinit als Completion "_<name>" eingelesen -- der Cache-Ordner
    # steht im fpath.
    local tmp="$ZSH_COMPLETIONS_DIR/.tmp_${tool}.$$"
    if "${@:2}" > "$tmp" 2>/dev/null && [[ -s "$tmp" ]]; then
      mv -f "$tmp" "$file"
    else
      rm -f "$tmp"
      print -u2 "  failed - keeping previous completion for $tool"
    fi
  fi
}

LOCAL_ZSH="$ZSH/local"

if [ -d "$LOCAL_ZSH" ]; then
  for file in "$HOME/.zsh/local"/*.zsh(.N); do
    source "$file"
  done
fi

export EZA_CONFIG_DIR=$ZSH/eza

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.

# misc
alias sshcopyid='ssh-copy-id -i ~/.ssh/id_rsa.pub '
alias opensslinfo='openssl x509 -text -noout -in '
alias zshreload='source ~/.zshrc'
alias aliassearch='alias | grep '
alias resticsnapshots='restic -r /restic snapshots'
alias vi='vim'
alias apt='sudo apt'
export EDITOR=/usr/bin/vim

# ls
alias ll='eza -la --group-directories-first --time-style "+%Y-%m-%d %H:%M:%S"'
alias la='eza -a'
alias l='eza -l --group-directories-first --time-style "+%Y-%m-%d %H:%M:%S"'

# less
alias rless='/usr/bin/less'
if command -v batcat &>/dev/null; then
  alias bat='batcat --style="plain"'
  alias less='batcat --style="plain"'
elif command -v bat &>/dev/null; then
  alias less='bat --style="plain"'
fi
export BAT_THEME="Monokai Extended"


# rsync
alias rsync-copy="rsync -avz --progress -h"
alias rsync-move="rsync -avz --progress -h --remove-source-files"
alias rsync-update="rsync -avzu --progress -h"
alias rsync-synchronize="rsync -avzu --delete --progress -h"

# git
alias gacp='git acp' # vorher git config --global alias.acp '!f() { git add . && git commit -m "$@" && git push; }; f'
alias gadd='git add .'
alias gdelmergedbr="git branch --merged main | grep -v '^\*\|main' | xargs -r git branch -d"
alias gdelmergedbrmaster="git branch --merged master | grep -v '^\*\|master' | xargs -r git branch -d"

alias gchkb='git checkout -b'
alias gchko='git checkout'
alias gclean='git clean -fdx'
alias gclone='git clone'
alias gcm='git commit -m'
alias gdc='git diff --cached'
alias gdf='git diff'
alias gfetch='git fetch'
alias glg='git log --oneline --graph --decorate --all'
alias gmerge='git merge'
alias gps='git push'
alias gpull='git pull'
alias grebasem='git rebase origin/main'
alias grst='git restore'
alias gstash='git stash'
alias gstatus='git status'
alias gswitch='git switch'

# maven
alias mvncli="mvn clean install"
alias mvncliskt="mvn clean install -DskipTests"
alias mvncl="mvn clean"
alias mvni="mvn install"
alias mvnverset='mvn versions:set -DprocessAllModules -DnewVersion='
alias mvnvercom='mvn versions:commit'
alias mvndepupdates='mvn versions:display-dependency-updates'

# docker
alias dockallup='~/docker/bin/all up'
alias dockalldown='~/docker/bin/all down'
alias dockrmorphans='docker image prune -f'   # war: docker rmi $(...) -- scheiterte ohne dangling images
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcdown='docker compose down'
alias dcps='docker compose ps'
alias dclog='docker compose logs'
alias dctail='docker compose logs -f'
alias dcstatus='docker compose ls'            # 'compose status' gibt es nicht; ps steckt schon in dcps
alias dockerrmimages='docker rmi --force $(docker images -q)'
alias dcud='docker compose down && docker compose up -d && docker compose logs -f'

# grep http
alias grephttperror='grep "HTTP/1\.1\" [45]"'
alias grephttpok='grep "HTTP/1\.1\" [23]"'

alias zsh-completions-refresh="rm -f $HOME/.zsh_cache/_* && source ~/.zshrc"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

autoload -Uz compinit && compinit

# --- fzf-tab ---
# Die Konfiguration steht bewusst hier und nicht in
# .zsh/fzf-tab/fzf-tab.plugin.zsh: dort waere sie in einem Vendor-Ordner
# versteckt und beim Neukopieren des Plugins verloren.

# Dateifarben fuer die Kandidatenliste. Ohne LS_COLORS bleibt list-colors
# unten leer, fzf-tab ueberspringt dann -ftb-colorize komplett und die
# Liste ist einfarbig -- waehrend die eza-Vorschau daneben bunt ist.
# Achtung: GNU-Standardpalette, passt nicht zum Dracula-Theme in
# .zsh/eza/theme.yml. Fuer gleiche Farben LS_COLORS von Hand setzen.
(( $+commands[dircolors] )) && eval "$(dircolors -b)"

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# Tab akzeptiert direkt. Ohne Farb-Flags -- der README-Beispielblock
# setzte hier --color=fg:1,fg+:2 (rot mit gruener Auswahl), das war nur
# eine Demo. So nutzt fzf seine Standardfarben.
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# Completion im tmux-Popup; ausserhalb von tmux faellt ftb-tmux-popup
# selbsttaetig auf normales fzf zurueck
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# Das Popup bemisst seine Breite am laengsten Eintrag (comp_length + 5 in
# lib/ftb-tmux-popup). Bei cd frisst die eza-Vorschau davon die Haelfte,
# dann werden Verzeichnisnamen abgeschnitten. Untergrenze dagegen setzen --
# der Wert wird auf die Fenstergroesse gedeckelt, zu gross schadet nicht.
zstyle ':fzf-tab:*' popup-min-size 70 20

# Vorschau schmaler, damit mehr Platz fuer die Namen bleibt.
# Achtung: zstyle vereinigt Patterns nicht -- das spezifischere ersetzt das
# allgemeinere komplett. --bind=tab:accept von oben muss deshalb mit rein,
# sonst geht es ausgerechnet bei cd verloren.
zstyle ':fzf-tab:complete:cd:*' fzf-flags --bind=tab:accept --preview-window=right,40%

source $ZSH/fzf-tab/fzf-tab.plugin.zsh
