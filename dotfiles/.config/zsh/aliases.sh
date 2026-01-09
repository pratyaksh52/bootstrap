alias h="history 0"

# # ls
# if ls --color=auto >/dev/null 2>&1; then
#   alias ll="ls -lFh --color=auto"
#   alias lla="ls -alFh --color=auto"
# else
#   alias ll="ls -lFhG"
#   alias lla="ls -alFhG"
# fi

# # lsd
# alias ll="lsd -lFhG"
# alias lla="lsd -alFhG"

# eza
alias ll="eza-ls -lh"
alias lla="eza-ls -alh"

# Source work aliases, if present
[ -f "$HOME/.config/zsh/work/aliases.sh" ] && . "$HOME/.config/zsh/work/aliases.sh"
