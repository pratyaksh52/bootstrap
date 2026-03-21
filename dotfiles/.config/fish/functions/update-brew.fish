function update-brew
    if not type -q brew
        printf 'Homebrew not found\n' >&2
        return 1
    end

    brew update
    brew upgrade
    brew upgrade --cask --greedy
    brew cleanup
    brew doctor
end
