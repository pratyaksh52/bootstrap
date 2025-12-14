alias lla="ls -alFh"
alias ll="ls -lFh"
alias h="history 0"
alias inv='realpath $(fzf --preview="bat --color=always {}") | pbcopy'
alias update-brew="brew update && brew upgrade && brew upgrade --greedy --cask --verbose && brew cleanup"

# ls
if ls --color=auto >/dev/null 2>&1; then
  alias ll="ls -lFh --color=auto"
  alias lla="ls -alFh --color=auto"
else
  alias ll="ls -lFhG"
  alias lla="ls -alFhG"
fi
