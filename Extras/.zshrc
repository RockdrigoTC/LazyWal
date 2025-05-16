# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


export PATH=$HOME/.local/bin:/usr/local/bin:$PATH
export ZSH=~/.oh-my-zsh/

export EDITOR=nvim
export VISUAL=nvim
export RANGER_LOAD_DEFAULT_RC=FALSE

ZSH_THEME="powerlevel10k/powerlevel10k"
zstyle ':omz:update' mode disabled

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

zshwatch_pacman=0 zshwatch_wal=0
autoload -Uz add-zsh-hook

reload_precmd() {
  local ts
  [[ -f /var/cache/zsh/pacman ]] && \
    ts=$(( $(stat -c %Y /var/cache/zsh/pacman) * 1000000000 )) && \
    (( zshwatch_pacman < ts )) && \
      rehash && zshwatch_pacman=$ts

  [[ -f ~/.cache/wal/colors.sh ]] && \
    ts=$(( $(stat -c %Y ~/.cache/wal/colors.sh) * 1000000000 )) && \
    (( zshwatch_wal < ts )) && \
    source "$HOME/.cache/wal/colors.sh" && source "$HOME/.p10k.zsh" && zshwatch_wal=$ts
}

add-zsh-hook precmd reload_precmd

# omz
alias zshconfig="geany ~/.zshrc"
alias ohmyzsh="thunar ~/.oh-my-zsh"

# ls
alias l='lsd -l'
alias ls='lsd -lh'
alias ll='lsd -lah'
alias la='lsd -A'
alias lm='lsd -m'
alias lr='lsd -R'
alias lg='lsd -l --group-directories-first'

# cat
alias cat='bat'

# git
alias gcl='git clone --depth 1'
alias gi='git init'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push origin master'

# extra
alias cls='clear'

alias logless='less +G ${XDG_CACHE_HOME:-$HOME/.cache}/lazywal/lazywal.log'
alias logtail='tail -f ${XDG_CACHE_HOME:-$HOME/.cache}/lazywal/lazywal.log'
alias logbat='bat ${XDG_CACHE_HOME:-$HOME/.cache}/lazywal/lazywal.log'
alias loggrep='bat ${XDG_CACHE_HOME:-$HOME/.cache}/lazywal/lazywal.log | grep -i'

# Functions
change-theme() {
  "$HOME/.config/lazywal/change_theme.sh" "$@"
}

#custom stuff
[ -f "$HOME/.cache/wal/colors.sh" ] && source "$HOME/.cache/wal/colors.sh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
