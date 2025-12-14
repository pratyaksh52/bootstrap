# Function to view files with fzf
inv() {
  local file

  command -v fzf >/dev/null 2>&1 || {
    echo "fzf not found" >&2
    return 1
  }

  file=$(fzf --preview='bat --color=always {}') || return
  realpath_compat "$file" | copy
}

# Function to update homebrew packages
update-brew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found" >&2
    return 1
  fi

  brew update
  brew upgrade
  brew upgrade --cask --greedy
  brew cleanup
  brew doctor
}
