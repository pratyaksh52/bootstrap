[[ -o interactive ]] && setopt INTERACTIVE_COMMENTS

[ -f "$HOME/.config/zsh/utils.sh" ] && . "$HOME/.config/zsh/utils.sh"
[ -f "$HOME/.config/zsh/functions.sh" ] && . "$HOME/.config/zsh/functions.sh"
[ -f "$HOME/.config/zsh/aliases.sh" ] && . "$HOME/.config/zsh/aliases.sh"


export LESSOPEN="|/opt/homebrew/bin/lesspipe.sh %s"
export LESS="-R"

fpath=(~/.zsh $fpath)

eval "$(starship init zsh)"

# Enable completion system
autoload -Uz compinit
compinit -C

# Set up fzf key bindings and fuzzy completion
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# Flag to disable ZOXIDE
if [ -z "$DISABLE_ZOXIDE" ] && command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# uv shell completions
command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion zsh)"
command -v uvx >/dev/null 2>&1 && eval "$(uvx --generate-shell-completion zsh)"

export PATH="$HOME/jetbrains:$PATH"

if command -v brew >/dev/null 2>&1; then
  AUTOSUGGESTIONS="$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -f "$AUTOSUGGESTIONS" ] && source "$AUTOSUGGESTIONS"
fi

# Git completion (zsh)
[ -f "$HOME/.zsh/git-completion.bash" ] &&
  zstyle ':completion:*:*:git:*' script "$HOME/.zsh/git-completion.bash"
