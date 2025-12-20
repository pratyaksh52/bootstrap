# ---------- OS detection ----------
is_macos() {
  [ "$(uname)" = "Darwin" ]
}

is_linux() {
  [ "$(uname)" = "Linux" ]
}

# ---------- Clipboard ----------
copy() {
  if command -v pbcopy >/dev/null 2>&1; then
    pbcopy
  elif command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  elif command -v xclip >/dev/null 2>&1; then
    xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    xsel --clipboard --input
  else
    echo "No clipboard utility found" >&2
    return 1
  fi
}

# ---------- realpath compatibility ----------
realpath_compat() {
  if command -v realpath >/dev/null 2>&1; then
    realpath "$1"
  else
    python3 - <<EOF
import os,sys
print(os.path.realpath(sys.argv[1]))
EOF
  fi
}
