# DotFiles

This is currently only supported for MacOS. Support for Linux (apt and pacman) coming soon.

1. To get started, install stow and git
```sh
brew install git
brew install stow
```

2. Clone this repo
```sh
git clone https://github.com/pratyaksh52/bootstrap.git
```

3. Run `dotfiles/stow-dotfiles.sh`

4. Add the following line to your `.zshrc`
```sh
. "$HOME/.config/zsh/init.sh"
```

4. Open `dotfiles/.config/git/personal/personal.gitconfig` and change the credentials to your own.

5. To install brew packages, run

```sh
brew bundle --file=./Brewfile
```
