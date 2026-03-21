status --is-interactive; or return

alias h="history"

if functions -q eza-ls
    alias ll="eza-ls -lh"
    alias lla="eza-ls -alh"
end

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
