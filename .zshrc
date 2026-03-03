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
    "${@:2}" > "$file" 2>/dev/null
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
alias apt='sudo apt'
alias zshreload='source ~/.zshrc'
alias resticsnapshots='restic -r /restic snapshots'
alias vi='vim'
alias aliassearch='alias | grep '
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
alias gstash="git stash"
alias gclone="git clone"
alias grst="git restore"
alias gmm="git merge origin/master"
alias grm="git rebase origin/master"
alias gfetch="git fetch"
alias gpull="git pull"
alias gswitch="git switch"
alias gclean="git clean -fdx"
alias gstatus='git status'
alias gchko='git checkout'
alias gchkb='git checkout -b'
alias gcm='git commit -m'
alias gadd='git add .'
alias gps='git push'
alias glg='git log --oneline --graph --decorate --all'
alias gdf='git diff'
alias gdc='git diff --cached'

# maven
alias mvncli="mvn clean install"
alias mvncliskt="mvn clean install -DskipTests"
alias mvncl="mvn clean"
alias mvni="mvn install"
alias mvnverset='mvn versions:set -DprocessAllModules -DnewVersion='
alias mvnvercom='mvn versions:commit'
alias mvndepupdates=' mvn versions:display-dependency-updates:'

# docker
alias dockallup='~/docker/bin/all up'
alias dockalldown='~/docker/bin/all down'
alias dockrmorphans='docker rmi $(docker images -f dangling=true -q)'
alias dcup='docker compose up'
alias dcupd='docker compose up -d'
alias dcdown='docker compose down'
alias dcps='docker compose ps'
alias dclog='docker compose logs'
alias dctail='docker compose logs -f'
alias dcstatus='docker compose status'
alias dockerrmimages='docker rmi "$(docker images -q)" --force'
alias dcud='docker compose down && docker compose up -d && docker compose logs -f'

# grep http
alias grephttperror='grep "HTTP/1\.1\" [45]"'
alias grephttpok='grep "HTTP/1\.1\" [23]"'

alias zsh-completions-refresh="rm -f $HOME/.zsh_cache/_* && source ~/.zshrc"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

autoload -Uz compinit && compinit
source $ZSH/fzf-tab/fzf-tab.plugin.zsh
