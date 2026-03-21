function inv
    if not type -q fzf
        printf 'fzf not found\n' >&2
        return 1
    end

    set file (fzf --preview='bat --color=always {}')
    or return

    realpath_compat $file | string trim -r | copy
end
