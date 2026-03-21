# Shared helper functions for POSIX shells.

copy() {
  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy
  elif shell_is_wsl && command -v clip.exe >/dev/null 2>&1; then
    clip.exe
  elif command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    printf 'No clipboard utility found\n' >&2
    return 1
  fi
}

realpath_compat() {
  if command -v realpath >/dev/null 2>&1; then
    realpath "$1"
  else
    python3 -c 'import os,sys; print(os.path.realpath(sys.argv[1]))' "$1"
  fi
}

eza-ls() {
  eza \
    --icons=auto \
    --group-directories-first \
    --git \
    --classify=auto \
    --octal-permissions \
    "$@"
}

inv() {
  local file

  command -v fzf >/dev/null 2>&1 || {
    printf 'fzf not found\n' >&2
    return 1
  }

  file="$(fzf --preview='bat --color=always {}')" || return
  realpath_compat "$file" | tr -d '\n' | copy
}

update-brew() {
  if ! command -v brew >/dev/null 2>&1; then
    printf 'Homebrew not found\n' >&2
    return 1
  fi

  brew update
  brew upgrade
  brew upgrade --cask --greedy
  brew cleanup
  brew doctor
}
