function eza-ls
    eza \
        --icons=auto \
        --group-directories-first \
        --git \
        --classify=auto \
        --octal-permissions \
        $argv
end
