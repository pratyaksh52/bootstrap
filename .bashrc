## Variables
DEV="/home/chopr/development"
WIP="$DEV/wip"

## Aliases
alias ll="ls -alFh"
alias h="history"
alias update="sudo apt update"
alias upgrade="sudo apt update && sudo apt upgrade"
alias sublime="/mnt/c/Program\ Files/Sublime\ Text/sublime_text.exe"
alias wip="cd $WIP"
alias dev="cd $DEV"

## Make less mouse scrollable
[[ "${LESS}" != *--mouse\s--wheel-lines* ]] && export LESS="${LESS} --mouse --wheel-lines 3"

#####
## Custom PS1
RESET="\[\033[0m\]"
RED="\[\033[0;91m\]"
GREEN="\[\033[01;32m\]"
BLUE="\[\033[01;36m\]"
YELLOW="\[\033[0;93m\]"
ORANGE="\[\033[38;5;214m\]"

### Function to get branch name if the current directory is a git repository
function git_prompt() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Function that is to be called every time the terminal prompt is refreshed
function prompt_command {
    if [ -z "${VIRTUAL_ENV_PROMPT}" ]; then
        VENV_NOTICE_PROMPT=""
    else
        VENV_NOTICE_PROMPT="(${VIRTUAL_ENV_PROMPT}) "
    fi

    PS_HOST="$GREEN\u@\h$RESET"
    PS_WD="$BLUE$PWD$RESET"
    PS_GITPROMPT="$YELLOW$(git_prompt)$RESET"
    PS_VENV_PROMPT="$ORANGE$VENV_NOTICE_PROMPT$RESET"
    # PS_TIME="$RED$(date)$RESET"

    export PS1="\n$PS_VENV_PROMPT$PS_HOST: $PS_WD $PS_GITPROMPT\n \$> "
}

### PROMPT_COMMAND is an env var that get's called everytime the terminal
### prompt is refreshed, we are doing this because the time displayed needs
### to be refeshed everytime the prompt is refreshed
export PROMPT_COMMAND=prompt_command
#####


