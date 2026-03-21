function copy
    if type -q pbcopy
        pbcopy
    else if test "$BOOTSTRAP_IS_WSL" = 1; and type -q clip.exe
        clip.exe
    else if type -q wl-copy
        wl-copy
    else if type -q xclip
        xclip -selection clipboard
    else if type -q xsel
        xsel --clipboard --input
    else
        printf 'No clipboard utility found\n' >&2
        return 1
    end
end
