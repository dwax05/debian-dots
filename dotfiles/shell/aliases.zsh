export EDITOR=nvim
export PAGER='less -R'
export MANPAGER='nvim +Man!'

mkcd() { mkdir -p -- "$1" && cd -- "$1" }
fcd() { local dir; dir=$(find . -type d | fzf) && cd -- "$dir" }
e() { local file; file=$(fd --type f | fzf --preview='bat -n --color=always {}') && "$EDITOR" "$file" }

alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -vI'
alias mkd='mkdir -pv'
alias ls='eza --group-directories-first'
alias ll='eza -l --group-directories-first'
alias la='eza -Ga --group-directories-first'
alias lla='eza -la --group-directories-first'
alias lt='eza -lT --group-directories-first'
alias lta='eza -lTa --group-directories-first'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias g=git
alias v=nvim
alias vim=nvim
