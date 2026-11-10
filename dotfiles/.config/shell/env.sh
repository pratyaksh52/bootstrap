# Shared environment for POSIX shells.

shell_prepend_path() {
  [ -n "${1:-}" ] || return 0
  [ -d "$1" ] || return 0

  case ":${PATH:-}:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

shell_is_macos() {
  [ "$(uname -s)" = "Darwin" ]
}

shell_is_linux() {
  [ "$(uname -s)" = "Linux" ]
}

shell_is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

export BOOTSTRAP_OS="unknown"
export BOOTSTRAP_IS_WSL="0"

if shell_is_macos; then
  export BOOTSTRAP_OS="macos"
elif shell_is_linux; then
  export BOOTSTRAP_OS="linux"
fi

if shell_is_wsl; then
  export BOOTSTRAP_IS_WSL="1"
fi

[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

shell_prepend_path "$HOME/.local/bin"
shell_prepend_path "$HOME/.lmstudio/bin"
shell_prepend_path "$HOME/jetbrains"

# GUI-launched processes start with a minimal PATH, so look in the standard
# Homebrew locations too rather than relying on brew already being on PATH.
for _brew in "$(command -v brew 2>/dev/null)" /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
  [ -n "$_brew" ] && [ -x "$_brew" ] && break
  _brew=""
done

if [ -n "$_brew" ]; then
  BREW_PREFIX="$("$_brew" --prefix)"
  export BREW_PREFIX
  shell_prepend_path "$BREW_PREFIX/bin"
  shell_prepend_path "$BREW_PREFIX/sbin"

  if [ -x "$BREW_PREFIX/bin/lesspipe.sh" ]; then
    export LESSOPEN="|$BREW_PREFIX/bin/lesspipe.sh %s"
  fi
fi
unset _brew

# mise shims give non-interactive shells (tools, editors, scripts) the
# mise-managed tool versions. Interactive shells switch to full activation
# in interactive.sh.
shell_prepend_path "${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims"

export LESS="${LESS:--R}"
