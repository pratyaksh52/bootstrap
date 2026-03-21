#!/usr/bin/env bash

set -euo pipefail

CWD="$PWD"
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_PATH"
stow -t "$HOME" --restow -v .
cd "$CWD"
