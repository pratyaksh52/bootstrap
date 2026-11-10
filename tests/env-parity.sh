#!/usr/bin/env bash
# Check that every shell loads the same Environment.
#
# Installs the dotfiles into a throwaway $HOME (no installer lines, no user
# edits), starts sh, bash, zsh and fish non-interactively from a minimal
# GUI-like environment, and compares the PATH and exported variables each one
# ends up with. Also checks that non-interactive fish gets mise shims and
# Homebrew. Shells that aren't installed are skipped.
#
# Usage: tests/env-parity.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

HOME_DIR="$TMP/home"
mkdir -p "$HOME_DIR/.local/bin" "$HOME_DIR/.local/share/mise/shims"

# Install with the real PATH (stow lives in Homebrew); everything below runs
# from the minimal one.
HOME="$HOME_DIR" "$REPO_DIR/dotfiles/install-dotfiles.sh" >"$TMP/install.log" 2>&1 \
  || { cat "$TMP/install.log" >&2; exit 1; }

BASE_PATH=/usr/bin:/bin:/usr/sbin:/sbin
failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

# run_shell NAME COMMAND...
# Runs COMMAND in a clean environment and writes its `env` to $TMP/NAME.env,
# leaving out variables each shell sets for itself.
run_shell() {
  local name="$1"
  shift
  # MISE_FISH_AUTO_ACTIVATE=0 turns off the vendor_conf.d file Homebrew's mise
  # ships, which activates mise in every fish; it isn't part of the Environment.
  env -i HOME="$HOME_DIR" USER="${USER:-}" TERM=dumb PATH="$BASE_PATH" MISE_FISH_AUTO_ACTIVATE=0 "$@" \
    | grep -Ev '^(_|SHLVL|PWD|OLDPWD|LOGNAME|XPC_[A-Z_]+|__CF_[A-Z_]+)=' \
    | sort >"$TMP/$name.env"
}

shells=()

# sh and bash don't read anything when run with -c, so load the files their
# login shells read. Skipping /etc/profile keeps macOS's path_helper out.
run_shell sh /bin/sh -c '. "$HOME/.profile"; env'
shells+=(sh)

if command -v bash >/dev/null 2>&1; then
  run_shell bash "$(command -v bash)" --noprofile --norc -c '. "$HOME/.bash_profile"; env'
  shells+=(bash)
fi

if command -v zsh >/dev/null 2>&1; then
  run_shell zsh "$(command -v zsh)" -c env
  shells+=(zsh)
fi

if command -v fish >/dev/null 2>&1; then
  run_shell fish "$(command -v fish)" -c env
  shells+=(fish)
else
  fail "fish not found"
fi

reference="${shells[0]}"
for name in "${shells[@]:1}"; do
  if ! diff -u --label "$reference" --label "$name" "$TMP/$reference.env" "$TMP/$name.env" >"$TMP/diff"; then
    fail "$name's environment differs from $reference's:"
    cat "$TMP/diff" >&2
  fi
done

if [[ -f "$TMP/fish.env" ]]; then
  fish_path="$(sed -n 's/^PATH=//p' "$TMP/fish.env")"

  case ":$fish_path:" in
    *":$HOME_DIR/.local/share/mise/shims:"*) ;;
    *) fail "non-interactive fish is missing mise shims: $fish_path" ;;
  esac

  for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x "$brew" ]] || continue
    case ":$fish_path:" in
      *":${brew%/brew}:"*) ;;
      *) fail "non-interactive fish is missing Homebrew (${brew%/brew}): $fish_path" ;;
    esac
    break
  done
fi

if ((failures)); then
  printf '%d check(s) failed.\n' "$failures" >&2
  exit 1
fi

printf 'Environment matches across: %s\n' "${shells[*]}"
