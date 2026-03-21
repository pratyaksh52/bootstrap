#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APT_MANIFEST="$SCRIPT_DIR/packages/apt-packages.txt"
PACMAN_MANIFEST="$SCRIPT_DIR/packages/pacman-packages.txt"

is_wsl() {
  [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

platform() {
  case "$(uname -s)" in
    Darwin) printf 'macos\n' ;;
    Linux)
      if is_wsl; then
        printf 'wsl\n'
      else
        printf 'linux\n'
      fi
      ;;
    *)
      printf 'unsupported\n'
      ;;
  esac
}

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  printf 'Homebrew not found. Installing Homebrew...\n'
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

install_with_apt() {
  local -a packages=()
  local package

  while IFS= read -r package || [[ -n "$package" ]]; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    if apt-cache show "$package" >/dev/null 2>&1; then
      packages+=("$package")
    else
      printf 'Skipping unavailable apt package: %s\n' "$package" >&2
    fi
  done <"$APT_MANIFEST"

  if [[ ${#packages[@]} -eq 0 ]]; then
    printf 'No installable apt packages found in %s\n' "$APT_MANIFEST" >&2
    return
  fi

  sudo apt-get update
  sudo apt-get install -y "${packages[@]}"
}

install_with_pacman() {
  local -a packages=()
  local package

  while IFS= read -r package || [[ -n "$package" ]]; do
    [[ -z "$package" || "$package" == \#* ]] && continue
    packages+=("$package")
  done <"$PACMAN_MANIFEST"

  if [[ ${#packages[@]} -eq 0 ]]; then
    printf 'No pacman packages found in %s\n' "$PACMAN_MANIFEST" >&2
    return
  fi

  sudo pacman -Syu --needed --noconfirm "${packages[@]}"
}

install_linux_packages() {
  if command -v apt-get >/dev/null 2>&1; then
    install_with_apt
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    install_with_pacman
    return
  fi

  printf 'Unsupported Linux package manager. Expected apt-get or pacman.\n' >&2
  exit 1
}

print_next_steps() {
  local target_platform="$1"

  printf '\nSetup complete.\n'
  printf 'The repo now manages shell startup files with stow.\n'
  printf 'Fish is the supported interactive shell; bash remains the scripting shell.\n'

  case "$target_platform" in
    macos)
      printf 'To switch your login shell when ready: chsh -s "$(brew --prefix)/bin/fish"\n'
      ;;
    linux)
      printf 'To switch your login shell when ready: chsh -s "$(command -v fish)"\n'
      ;;
    wsl)
      printf 'WSL detected. Set fish as your interactive shell when ready: chsh -s "$(command -v fish)"\n'
      ;;
  esac

  printf 'Manual installers still expected from %s\n' "$SCRIPT_DIR/non-brew-packages.yaml"
}

main() {
  local target_platform

  cd "$SCRIPT_DIR"
  target_platform="$(platform)"

  case "$target_platform" in
    macos)
      ensure_homebrew
      require_command brew
      brew bundle --file "$SCRIPT_DIR/Brewfile"
      ;;
    linux | wsl)
      install_linux_packages
      ;;
    *)
      printf 'Unsupported platform: %s\n' "$(uname -s)" >&2
      exit 1
      ;;
  esac

  "$SCRIPT_DIR/dotfiles/stow-dotfiles.sh"
  print_next_steps "$target_platform"
}

main "$@"
