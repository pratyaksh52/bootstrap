status --is-interactive; or return

# Helpers are scripts on PATH; only aliases are loaded here. The Shared aliases
# are written so the same file parses in fish, zsh and bash.
set -l shared_aliases ~/.config/shell/aliases.sh
test -r $shared_aliases; and source $shared_aliases

alias h="history"

if type -q starship
    starship init fish | source
end

if type -q fzf
    fzf --fish | source
end

if type -q zoxide
    zoxide init --cmd cd fish | source
end

if type -q uv
    uv generate-shell-completion fish | source
end

# Non-interactive shells get mise's shims from the Environment instead.
if command -q mise
    mise activate fish | source
end
