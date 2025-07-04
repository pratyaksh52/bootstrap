setopt INTERACTIVE_COMMENTS

alias lla="ls -alFh"
alias ll="ls -lFh"
alias h="history 0"
alias zed="open -a /Applications/Zed.app -n"
alias inv='realpath $(fzf --preview="bat --color=always {}") | pbcopy'
alias update-brew="brew update && brew upgrade && brew upgrade --greedy --cask --verbose && brew cleanup"

export PATH=$PATH:$HOME/go/bin
export LESSOPEN="|/opt/homebrew/bin/lesspipe.sh %s"

eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

. "$HOME/.cargo/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/pratyakshchoudhary/.lmstudio/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

eval "$(zoxide init --cmd cd zsh)"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
