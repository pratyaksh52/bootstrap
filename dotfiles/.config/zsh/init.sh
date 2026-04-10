[[ -o interactive ]] && setopt INTERACTIVE_COMMENTS

[ -f "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"
[ -f "$HOME/.config/shell/helpers.sh" ] && . "$HOME/.config/shell/helpers.sh"
[ -f "$HOME/.config/zsh/functions.sh" ] && . "$HOME/.config/zsh/functions.sh"
[ -f "$HOME/.config/zsh/aliases.sh" ] && . "$HOME/.config/zsh/aliases.sh"

if [[ -o interactive ]]; then
  if [ -z "${BOOTSTRAP_ZSH_SHIM_NOTICE:-}" ]; then
    printf 'bootstrap: zsh is compatibility-only; fish is the supported interactive shell.\n' >&2
    export BOOTSTRAP_ZSH_SHIM_NOTICE=1
  fi

  autoload -Uz compinit
  compinit -C

  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
  fi

  if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
  fi

  if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
  fi

  if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion zsh)"
  fi
fi

eval "$(mise activate zsh)"
