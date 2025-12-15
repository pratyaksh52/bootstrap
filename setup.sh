#!/usr/bin/env zsh

# This script sets up a new Mac with all the tools and configurations I like to use.
# IMPORTANT: This script is a WIP - do not use it yet!

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set zsh as the default shell
if [ "$SHELL" != "/bin/zsh" ]; then
    echo "Setting zsh as the default shell..."
    chsh -s /bin/zsh
fi

# Run stow-dotfiles.sh to symlink dotfiles
./dotfiles/stow-dotfiles.sh

# Install Homebrew if not installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install homebrew packages from Brewfile
echo "Installing Homebrew packages from Brewfile..."
brew bundle --file ./Brewfile

# Install starship prompt
if ! command -v starship &> /dev/null; then
    echo "Starship not found. Installing Starship..."
    brew install starship
fi

# Install nvm if not installed
if [ ! -d "$HOME/.nvm" ]; then
    echo "nvm not found. Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
fi

# Install git-completion.zsh if not present
if [ ! -f "$HOME/.zsh/_git" ]; then
    echo "git-completion.zsh not found. Downloading git-completion.zsh..."
    mkdir -p ~/.zsh
    curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh -o ~/.zsh/_git
    curl -L https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.zsh/git-completion.bash
fi

echo "Setup complete! Please restart your terminal. Also, install the following manually:"
echo "1. SDKMAN (https://sdkman.io/install)"
echo "2. Rust (https://www.rust-lang.org/tools/install)"
echo "3. Any other tools you may need that are not covered in this script."
# TODO: Manually install SDKMAN, rust
