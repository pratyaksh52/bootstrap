setopt INTERACTIVE_COMMENTS

alias lla="ls -alFh"
alias ll="ls -lFh"
alias h="history 0"
alias inv='realpath $(fzf --preview="bat --color=always {}") | pbcopy'
alias update-brew="brew update && brew upgrade && brew upgrade --greedy --cask --verbose && brew cleanup"

export PATH=$PATH:$HOME/go/bin
export LESSOPEN="|/opt/homebrew/bin/lesspipe.sh %s"

fpath=(~/.zsh $fpath)

# Enable completion system
autoload -Uz compinit
compinit

eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

. "$HOME/.cargo/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


if [ -z "$DISABLE_ZOXIDE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

eval "$(uv generate-shell-completion zsh)"
eval "$(uvx --generate-shell-completion zsh)"

export PATH="$HOME/bin:$PATH"

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# Git completion (zsh)
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash

##############################################################
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
##############################################################
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/pratyakshchoudhary/.lmstudio/bin"
# End of LM Studio CLI section

