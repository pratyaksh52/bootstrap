source ./.config/zsh/init.sh
export PATH=$PATH:$HOME/go/bin

. "$HOME/.cargo/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

##############################################################
# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
##############################################################
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

eval "$(starship init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/pratyakshchoudhary/.lmstudio/bin"
# End of LM Studio CLI section

# Added by Antigravity
export PATH="/Users/pratyakshchoudhary/.antigravity/antigravity/bin:$PATH"
