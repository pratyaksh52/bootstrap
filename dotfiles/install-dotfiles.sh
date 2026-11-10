#!/usr/bin/env bash
# Install the dotfiles into $HOME:
#   1. stow the Stowed dotfiles in this directory;
#   2. write a Managed block at the top of each Live startup file.
# Safe to re-run. See docs/adr/0001-posix-startup-files-use-managed-blocks.md.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BLOCK_BEGIN='# >>> bootstrap >>>'
BLOCK_END='# <<< bootstrap <<<'

SOURCE_ENV='[ -f "$HOME/.config/shell/env.sh" ] && . "$HOME/.config/shell/env.sh"'
SOURCE_INTERACTIVE='[ -f "$HOME/.config/shell/interactive.sh" ] && . "$HOME/.config/shell/interactive.sh"'
SOURCE_PROFILE='[ -f "$HOME/.profile" ] && . "$HOME/.profile"'
SOURCE_BASHRC='[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"'

# write_managed_block FILE BODY
# Puts BODY between the markers at the top of FILE, replacing any existing
# block wherever it is. Lines outside the block are left untouched.
write_managed_block() {
  local file="$1" body="$2" tmp

  touch "$file"
  tmp="$(mktemp)"

  {
    printf '%s\n%s\n%s\n\n' "$BLOCK_BEGIN" "$body" "$BLOCK_END"
    awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" '
      $0 == begin { skipping = 1; next }
      $0 == end   { skipping = 0; drop_blank = 1; next }
      skipping    { next }
      drop_blank && $0 == "" { drop_blank = 0; next }
      { drop_blank = 0; print }
    ' "$file"
  } >"$tmp"

  # Write through (not mv) so the file keeps its permissions and inode.
  cat "$tmp" >"$file"
  rm -f "$tmp"
  printf 'Managed block written: %s\n' "$file"
}

stow_dotfiles() {
  (cd "$SCRIPT_DIR" && stow -t "$HOME" --restow -v .)
}

write_managed_blocks() {
  write_managed_block "$HOME/.zshenv" "$SOURCE_ENV"
  write_managed_block "$HOME/.zshrc" "$SOURCE_INTERACTIVE"
  write_managed_block "$HOME/.bashrc" "$SOURCE_ENV
$SOURCE_INTERACTIVE"
  # Login bash reads only ~/.bash_profile when it exists, skipping both
  # ~/.profile and ~/.bashrc, so load both from here.
  write_managed_block "$HOME/.bash_profile" "$SOURCE_PROFILE
$SOURCE_BASHRC"
  write_managed_block "$HOME/.profile" "$SOURCE_ENV"
}

stow_dotfiles
write_managed_blocks
