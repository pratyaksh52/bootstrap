set -gx BOOTSTRAP_OS unknown
set -gx BOOTSTRAP_IS_WSL 0

if test (uname -s) = Darwin
    set -gx BOOTSTRAP_OS macos
else if test (uname -s) = Linux
    set -gx BOOTSTRAP_OS linux
end

if set -q WSL_DISTRO_NAME
    set -gx BOOTSTRAP_IS_WSL 1
    set -gx BROWSER wslview
else if test -r /proc/sys/kernel/osrelease
    if string match -qi "*microsoft*" -- (cat /proc/sys/kernel/osrelease)
        set -gx BOOTSTRAP_IS_WSL 1
    end
end

if test -d ~/.cargo/bin
    fish_add_path -m ~/.cargo/bin
end

fish_add_path -m ~/.local/bin ~/.lmstudio/bin ~/jetbrains

if type -q brew
    set -gx BREW_PREFIX (brew --prefix)
    fish_add_path -m "$BREW_PREFIX/bin" "$BREW_PREFIX/sbin"

    if test -x "$BREW_PREFIX/bin/lesspipe.sh"
        set -gx LESSOPEN "|$BREW_PREFIX/bin/lesspipe.sh %s"
    end
end

if not set -q LESS
    set -gx LESS -R
end
