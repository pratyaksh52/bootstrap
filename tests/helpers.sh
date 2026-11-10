#!/usr/bin/env bash
# Check that Helpers and Shared aliases work the same in every shell.
#
# Installs the dotfiles into a throwaway $HOME, then checks that:
#   - every Helper resolves to its stowed script in sh, bash, zsh and fish,
#     interactive or not, with no function or alias in front of it;
#   - every Shared alias exists in interactive bash, zsh and fish;
#   - a broken link into the repo, left by an earlier install, is removed,
#     and a broken link that isn't the repo's is left alone;
#   - copy, inv and eza-ls behave correctly against fake pbcopy, fzf and eza.
# Shells that aren't installed are skipped.
# See docs/adr/0004-helpers-are-scripts-aliases-are-shared.md.
#
# Usage: tests/helpers.sh

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES="$REPO_DIR/dotfiles"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

HOME_DIR="$TMP/home"
BIN="$HOME_DIR/.local/bin"
BASE_PATH=/usr/bin:/bin:/usr/sbin:/sbin
failures=0

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  failures=$((failures + 1))
}

helpers=()
for script in "$DOTFILES/.local/bin"/*; do
  [[ -f "$script" ]] && helpers+=("$(basename "$script")")
done
((${#helpers[@]})) || { printf 'No Helpers found in %s\n' "$DOTFILES/.local/bin" >&2; exit 1; }

aliases=()
while IFS= read -r name; do
  aliases+=("$name")
done < <(sed -n "s/^alias \([^=]*\)=.*/\1/p" "$DOTFILES/.config/shell/aliases.sh")

# --- Install over a $HOME that an earlier install left a stale link in. ---

mkdir -p "$HOME_DIR/.config/fish/functions" "$BIN"
ln -s "$DOTFILES/.config/fish/functions/copy.fish" "$HOME_DIR/.config/fish/functions/copy.fish"
ln -s /nonexistent/not-the-repo "$HOME_DIR/.config/not-ours"

HOME="$HOME_DIR" "$DOTFILES/install-dotfiles.sh" >"$TMP/install.log" 2>&1 \
  || { cat "$TMP/install.log" >&2; exit 1; }

[[ -L "$HOME_DIR/.config/fish/functions/copy.fish" ]] \
  && fail "stale link into the repo was not removed: ~/.config/fish/functions/copy.fish"
[[ -L "$HOME_DIR/.config/not-ours" ]] \
  || fail "a broken link that isn't the repo's was removed: ~/.config/not-ours"

for name in "${helpers[@]}"; do
  [[ -x "$BIN/$name" ]] || fail "Helper not installed as an executable: ~/.local/bin/$name"
done

# --- Every shell finds the Helper scripts and the Shared aliases. ---

# run_shell NAME COMMAND...
# Runs COMMAND in a clean environment, stdout to $TMP/NAME.out.
run_shell() {
  local name="$1"
  shift
  env -i HOME="$HOME_DIR" USER="${USER:-}" TERM=dumb PATH="$BASE_PATH" MISE_FISH_AUTO_ACTIVATE=0 "$@" \
    >"$TMP/$name.out" 2>/dev/null </dev/null || true
}

# Each probe prints "<name> <kind> <path>" per Helper, then "alias <name>"
# for each Shared alias the shell has.
posix_probe='for n in '"${helpers[*]}"'; do printf "%s file %s\n" "$n" "$(command -v "$n")"; done'
bash_probe='for n in '"${helpers[*]}"'; do printf "%s %s %s\n" "$n" "$(type -t "$n")" "$(type -P "$n")"; done
for a in '"${aliases[*]}"'; do alias "$a" >/dev/null 2>&1 && printf "alias %s\n" "$a"; done'
zsh_probe='for n in '"${helpers[*]}"'; do k="$(whence -w "$n")"; printf "%s %s %s\n" "$n" "${k#*: }" "$(whence -p "$n")"; done
for a in '"${aliases[*]}"'; do alias "$a" >/dev/null 2>&1 && printf "alias %s\n" "$a"; done'
fish_probe='for n in '"${helpers[*]}"'; printf "%s %s %s\n" $n (type -t $n) (command -v $n); end
for a in '"${aliases[*]}"'; functions -q $a; and printf "alias %s\n" $a; end'

probes=()

run_shell sh /bin/sh -c '. "$HOME/.profile"; '"$posix_probe"
probes+=(sh)

if command -v bash >/dev/null 2>&1; then
  run_shell bash "$(command -v bash)" --noprofile --norc -c '. "$HOME/.bash_profile"; '"$bash_probe"
  run_shell bash-i "$(command -v bash)" -i -c "$bash_probe"
  probes+=(bash bash-i)
fi

if command -v zsh >/dev/null 2>&1; then
  run_shell zsh "$(command -v zsh)" -c "$zsh_probe"
  run_shell zsh-i "$(command -v zsh)" -i -c "$zsh_probe"
  probes+=(zsh zsh-i)
fi

if command -v fish >/dev/null 2>&1; then
  run_shell fish "$(command -v fish)" -c "$fish_probe"
  run_shell fish-i "$(command -v fish)" -i -c "$fish_probe"
  probes+=(fish fish-i)
else
  fail "fish not found"
fi

for probe in "${probes[@]}"; do
  for name in "${helpers[@]}"; do
    line="$(grep -E "^$name " "$TMP/$probe.out" || true)"
    read -r _ kind path <<<"$line"
    case "$kind" in
      file | command) ;;
      *) fail "$probe: '$name' is a ${kind:-missing}, not the Helper script" ;;
    esac
    [[ "${path:-}" == "$BIN/$name" ]] || fail "$probe: '$name' resolves to '${path:-nothing}', not $BIN/$name"
  done

  case "$probe" in
    *-i)
      for name in "${aliases[@]}"; do
        grep -qx "alias $name" "$TMP/$probe.out" || fail "$probe: Shared alias '$name' is not defined"
      done
      ;;
  esac
done

# --- Helper behaviour, from a bare sh with fakes first on PATH. ---

FAKE="$TMP/fake"
WORK="$TMP/work"
mkdir -p "$FAKE" "$WORK/sub"
: >"$WORK/sub/file.txt"

cat >"$FAKE/pbcopy" <<EOF
#!/bin/sh
cat >"$TMP/clipboard"
EOF
cat >"$FAKE/fzf" <<'EOF'
#!/bin/sh
printf 'sub/file.txt\n'
EOF
cat >"$FAKE/eza" <<'EOF'
#!/bin/sh
printf '%s\n' "$*"
EOF
chmod +x "$FAKE"/*

# helper_sh COMMAND: run COMMAND in a non-interactive sh that loaded nothing.
helper_sh() {
  (cd "$WORK" && env -i HOME="$HOME_DIR" PATH="$FAKE:$BIN:$BASE_PATH" /bin/sh -c "$1")
}

rm -f "$TMP/clipboard"
helper_sh 'printf "hello\nworld" | copy' || fail "copy exited non-zero"
[[ "$(cat "$TMP/clipboard" 2>/dev/null)" == $'hello\nworld' ]] \
  || fail "copy did not pass stdin to pbcopy unchanged"

rm -f "$TMP/clipboard"
helper_sh inv || fail "inv exited non-zero"
expected="$(cd "$WORK/sub" && pwd -P)/file.txt"
[[ "$(cat "$TMP/clipboard" 2>/dev/null)" == "$expected" ]] \
  || fail "inv copied '$(cat "$TMP/clipboard" 2>/dev/null)', expected '$expected' with no newline"

out="$(helper_sh 'eza-ls -lh "a b"')" || fail "eza-ls exited non-zero"
[[ "$out" == "--icons=auto --group-directories-first --git --classify=auto --octal-permissions -lh a b" ]] \
  || fail "eza-ls passed unexpected arguments to eza: $out"

if ((failures)); then
  printf '%d check(s) failed.\n' "$failures" >&2
  exit 1
fi

printf 'Helpers (%s) and Shared aliases (%s) work in: %s\n' "${helpers[*]}" "${aliases[*]}" "${probes[*]}"
