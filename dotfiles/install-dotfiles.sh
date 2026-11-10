#!/usr/bin/env bash
# Install the dotfiles into $HOME:
#   1. unfold any directory an earlier stow linked whole into the repo;
#   2. stow the Stowed dotfiles in this directory, files only;
#   3. write a Managed block at the top of each Live startup file.
# Safe to re-run. See docs/adr/0001-posix-startup-files-use-managed-blocks.md
# and docs/adr/0002-stow-files-never-directories.md.

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

# unfold_dir DIR
# DIR (relative to $HOME) is a symlink to the same directory in the repo.
# Replace it with a real directory and move the repo directory's untracked
# files (installer output, fish_variables, ...) into it. Stow then links the
# tracked files back in one by one.
unfold_dir() {
  local dir="$1" file dest
  local -a untracked=()

  while IFS= read -r -d '' file; do
    untracked+=("$file")
  done < <(git -C "$SCRIPT_DIR" ls-files -z --others -- "$dir")

  rm "$HOME/$dir"
  mkdir -p "$HOME/$dir"

  for file in ${untracked[@]+"${untracked[@]}"}; do
    dest="$HOME/$file"
    if [[ -e "$dest" || -L "$dest" ]]; then
      printf 'Cannot unfold %s: %s already exists. Resolve by hand and re-run.\n' "$HOME/$dir" "$dest" >&2
      exit 1
    fi
    mkdir -p "$(dirname "$dest")"
    mv "$SCRIPT_DIR/$file" "$dest"
    printf 'Moved out of the repo: %s\n' "$dest"
  done

  # Drop directories the moves left empty in the repo.
  find "$SCRIPT_DIR/$dir" -mindepth 1 -type d -empty -delete

  printf 'Unfolded: %s\n' "$HOME/$dir"
}

# Find directories an earlier stow (without --no-folding) linked whole into
# the repo, outermost first.
unfold_folded_dirs() {
  local dir link target

  while IFS= read -r dir; do
    dir="${dir#./}"
    link="$HOME/$dir"
    [[ -L "$link" && -d "$link" ]] || continue
    target="$(cd "$link" && pwd -P)"
    [[ "$target" == "$(cd "$SCRIPT_DIR/$dir" && pwd -P)" ]] || continue
    unfold_dir "$dir"
  done < <(cd "$SCRIPT_DIR" && find . -mindepth 1 -type d -not -path './.git' -not -path './.git/*' | sort)
}

stow_dotfiles() {
  (cd "$SCRIPT_DIR" && stow -t "$HOME" --no-folding --restow -v .)
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

unfold_folded_dirs
stow_dotfiles
write_managed_blocks
