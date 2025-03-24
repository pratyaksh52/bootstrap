alias lla="ls -alFh"
alias ll="ls -lFh"
alias h="history"
alias zed="open -a /Applications/Zed.app -n"

# # Custom PS1 for zsh

# # Define colors
# RESET="%f"
# RED="%F{red}"
# GREEN="%F{green}"
# BLUE="%F{blue}"
# YELLOW="%F{yellow}"
# ORANGE="%F{214}"

# NEWLINE=$'\n'

# # Function to get branch name if the current directory is a git repository
# function git_prompt() {
#     git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
# }

# # Function to update the prompt
# function prompt_command {
#     if [[ -z "${VIRTUAL_ENV}" ]]; then
#         VENV_NOTICE_PROMPT=""
#     else
#         VENV_NOTICE_PROMPT="(${${VIRTUAL_ENV:t}}) "
#     fi

#     # if [[ -z "${VIRTUAL_ENV_PROMPT}" ]]; then
#     #     VENV_NOTICE_PROMPT=""
#     # else
#     #     VENV_NOTICE_PROMPT="(${VIRTUAL_ENV_PROMPT}) "
#     # fi

#     PS_HOST="${GREEN}%n@%m${RESET}"
#     PS_WD="${BLUE}%~${RESET}"
#     PS_GITPROMPT="${YELLOW}$(git_prompt)${RESET}"
#     PS_VENV_PROMPT="${ORANGE}${VENV_NOTICE_PROMPT}${RESET}"

#     PROMPT="${NEWLINE}${PS_VENV_PROMPT}${PS_HOST}: ${PS_WD} ${PS_GITPROMPT}${NEWLINE} \$> "
# }

# # Hook the function to the prompt update
# precmd() {
#     prompt_command
# }

# ASDF settings
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

eval "$(starship init zsh)"
