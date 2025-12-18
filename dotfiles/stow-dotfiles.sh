#!/usr/bin/env zsh

CWD="$PWD"
SCRIPT_PATH="${0:A:h}"

cd "$SCRIPT_PATH" || exit 1
stow -t "$HOME" --restow -v .
cd "$CWD" || exit 1
