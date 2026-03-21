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

if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
  export BREW_PREFIX
  shell_prepend_path "$BREW_PREFIX/bin"
  shell_prepend_path "$BREW_PREFIX/sbin"

  if [ -x "$BREW_PREFIX/bin/lesspipe.sh" ]; then
    export LESSOPEN="|$BREW_PREFIX/bin/lesspipe.sh %s"
  fi
fi

export LESS="${LESS:--R}"
