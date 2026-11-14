# The Environment: the one definition, loaded by every shell.
# zsh, bash and sh source it from their Managed blocks; fish runs it in sh
# and imports the result (see docs/adr/0003-fish-loads-the-posix-environment.md).
# Only entries the repo chooses belong here; installers add their own.

# Add a directory to the front of PATH, unless it is missing or already on
# PATH (then it stays where it is, so later installer lines can override).
shell_prepend_path() {
    [ -n "${1:-}" ] || return 0
    [ -d "$1" ] || return 0

    case ":${PATH:-}:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
    esac
}

if [ -f "$HOME/.config/shell/platform.sh" ]; then
    . "$HOME/.config/shell/platform.sh"
    BOOTSTRAP_PLATFORM="$(bootstrap_platform)"
    export BOOTSTRAP_PLATFORM
fi

shell_prepend_path "$HOME/.local/bin"
shell_prepend_path "$HOME/.lmstudio/bin"
shell_prepend_path "$HOME/jetbrains"

# GUI-launched processes start with a minimal PATH, so look in the standard
# Homebrew locations too rather than relying on brew already being on PATH.
for _brew in "$(command -v brew 2>/dev/null)" /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [ -n "$_brew" ] && [ -x "$_brew" ] && break
    _brew=""
done

if [ -n "$_brew" ]; then
    # The prefix is the directory above bin/; asking `brew --prefix` costs
    # every shell a slow process start.
    case "$_brew" in
    */bin/brew) BREW_PREFIX="${_brew%/bin/brew}" ;;
    *) BREW_PREFIX="$("$_brew" --prefix)" ;;
    esac
    export BREW_PREFIX
    shell_prepend_path "$BREW_PREFIX/bin"
    shell_prepend_path "$BREW_PREFIX/sbin"

    if [ -x "$BREW_PREFIX/bin/lesspipe.sh" ]; then
        export LESSOPEN="|$BREW_PREFIX/bin/lesspipe.sh %s"
    fi
fi
unset _brew

# mise shims give non-interactive shells (tools, editors, scripts) the
# mise-managed tool versions. Interactive shells switch to full activation
# in their interactive setup.
shell_prepend_path "${MISE_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/mise}/shims"

if [ "$BOOTSTRAP_PLATFORM" = wsl ]; then
    export BROWSER="${BROWSER:-wslview}"
fi

export LESS="${LESS:--R}"
export PATH
