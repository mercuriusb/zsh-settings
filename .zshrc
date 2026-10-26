export ZSH=~/.zsh

source $ZSH/agnoster/agnoster.zsh-theme

# --- ZSH Completions Setup ---
ZSH_COMPLETIONS_DIR="$HOME/.zsh_cache"
mkdir -p "$ZSH_COMPLETIONS_DIR"
fpath=($ZSH_COMPLETIONS_DIR $fpath)

# Completions are regenerated automatically after 7 days
_generate_completion() {
  local tool=$1
  local file="$ZSH_COMPLETIONS_DIR/_${tool}"
  local max_age_days=7

  # Tool installed?
  if ! command -v "$tool" &>/dev/null; then
    return
  fi

  # Regenerate if the file is missing or too old
  if [[ ! -f "$file" ]] || [[ $(find "$file" -mtime +${max_age_days} 2>/dev/null) ]]; then
    echo "Generating completion for $tool..."

    # Write to a temp file first and check it. Redirecting straight to
    # "$file" would leave an empty file behind if the call fails -- that
    # then counts as a valid cache for 7 days and completion is silently
    # broken.
    # Dot prefix: otherwise leftover temp files would be read by compinit
    # as a completion "_<name>" -- the cache directory is in fpath.
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

# Without this line zsh picks the keymap itself -- and chooses vi as soon
# as $EDITOR or $VISUAL contains the string "vi". The line above does
# exactly that, so the shell ran in vi mode without anyone deciding so.
# There ^R is not history search but "redisplay" -- the key visibly does
# nothing. Check with:
#     bindkey -lL main        # expected: bindkey -e main
#     bindkey | grep '\^R'    # expected: history-incremental-search-backward
# Set explicitly so that a changed EDITOR does not mess up the keys.
bindkey -e

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
alias dcstatus='docker compose ls'            # 'compose status' does not exist; ps is already covered by dcps
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
# The configuration lives here on purpose, not in
# .zsh/fzf-tab/fzf-tab.plugin.zsh: there it would be hidden in a vendored
# folder and lost the next time the plugin is copied over from upstream.

# File colors for the candidate list. Without LS_COLORS, list-colors below
# stays empty, fzf-tab then skips -ftb-colorize entirely and the list is
# monochrome -- while the eza preview next to it is colored.
# Caution: GNU default palette, does not match the Dracula theme in
# .zsh/eza/theme.yml. Set LS_COLORS by hand for matching colors.
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
# Tab accepts directly. No color flags -- the README example block set
# --color=fg:1,fg+:2 here (red with green selection), that was only a
# demo. This way fzf uses its default colors.
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'
# Completion in a tmux popup; outside tmux, ftb-tmux-popup falls back to
# plain fzf on its own
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup

# The popup sizes its width by the longest entry (comp_length + 5 in
# lib/ftb-tmux-popup). With cd the eza preview eats half of that, so
# directory names get cut off. Set a lower bound against that -- the value
# is capped at the window size, so too large does no harm.
zstyle ':fzf-tab:*' popup-min-size 70 20

# Narrower preview to leave more room for the names.
# Caution: zstyle does not merge patterns -- the more specific one replaces
# the more general one completely. So --bind=tab:accept from above has to
# be repeated here, otherwise it gets lost for cd of all places.
zstyle ':fzf-tab:complete:cd:*' fzf-flags --bind=tab:accept --preview-window=right,40%

source $ZSH/fzf-tab/fzf-tab.plugin.zsh
