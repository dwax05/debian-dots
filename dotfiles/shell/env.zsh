export HISTSIZE=100000
export SAVEHIST=100000
export HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
export LESSHISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/less/history"
export HIST_STAMPS='dd/mm/yyyy'

setopt autocd interactive_comments share_history
unsetopt beep prompt_subst

export STARSHIP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/starship/starship.toml"
export FZF_DEFAULT_OPTS='--history-size=20000'
export GOPATH="$HOME/.go"
export LOCAL_ENDPOINT='http://localhost:11434'
export PATH="$HOME/.local/bin:$GOPATH/bin:/opt/nvim/bin:$PATH"

source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliases.zsh"
