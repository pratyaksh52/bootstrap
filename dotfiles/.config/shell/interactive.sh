# Interactive setup for zsh and bash.
# Loaded from the managed block in ~/.zshrc and ~/.bashrc, after env.sh.

case $- in
  *i*) ;;
  *) return 0 ;;
esac

# Login bash can reach this twice (~/.profile and ~/.bashrc); load once per shell.
[ -n "${_bootstrap_interactive_loaded:-}" ] && return 0
_bootstrap_interactive_loaded=1

if [ -n "${ZSH_VERSION:-}" ]; then
  _bootstrap_shell=zsh
elif [ -n "${BASH_VERSION:-}" ]; then
  _bootstrap_shell=bash
else
  return 0
fi

# Helpers are scripts on PATH; only aliases are loaded here.
[ -f "$HOME/.config/shell/aliases.sh" ] && . "$HOME/.config/shell/aliases.sh"

if [ "$_bootstrap_shell" = zsh ]; then
  setopt INTERACTIVE_COMMENTS
  alias h="history 0"
  autoload -Uz compinit
  compinit -C
else
  alias h="history"
fi

command -v starship >/dev/null 2>&1 && eval "$(starship init "$_bootstrap_shell")"
command -v fzf >/dev/null 2>&1 && eval "$(fzf --"$_bootstrap_shell")"
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init --cmd cd "$_bootstrap_shell")"
command -v uv >/dev/null 2>&1 && eval "$(uv generate-shell-completion "$_bootstrap_shell")"
command -v mise >/dev/null 2>&1 && eval "$(mise activate "$_bootstrap_shell")"

unset _bootstrap_shell
