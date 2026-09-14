export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh" "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.zsh"

autoload -Uz compinit
zstyle ':completion:*' menu select
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

eval "$(zoxide init zsh --cmd cd)"
eval "$(starship init zsh)"
source <(fzf --zsh)

autoload -Uz add-zsh-hook
_restore_cursor() { printf '\e[6 q' }
add-zsh-hook precmd _restore_cursor

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
