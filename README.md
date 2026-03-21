# Bootstrap

This repo manages a fish-first shell setup across macOS, Linux, and WSL. Fish is the supported interactive shell. Bash is kept for repo scripts and as a lightweight fallback. Zsh remains available only as a compatibility shim.

## Supported targets

- macOS with Homebrew
- Linux with `apt` or `pacman`
- Windows via WSL

Native Windows shell bootstrap is out of scope.

## Bootstrap

1. Clone the repo.

```sh
git clone https://github.com/pratyaksh52/bootstrap.git
cd bootstrap
```

2. Run the bootstrap script.

```sh
bash ./setup.sh
```

The script installs baseline packages for the current platform, stows the dotfiles into `$HOME`, and prints the command you can run later to switch your login shell to fish. It does not run `chsh` automatically.

## Manual installers

`non-brew-packages.yaml` is reserved for tools that still need their own installers, such as `nvm`, `rustup`, and `sdkman`.

## Shell layout

- `dotfiles/.config/fish/`: primary interactive shell configuration
- `dotfiles/.config/shell/`: shared OS detection, environment, path setup, and portable helpers
- `dotfiles/.zshrc`: transitional zsh shim
- `dotfiles/.bashrc`: minimal bash startup file without a custom prompt layer

## Notes

- macOS detects Homebrew dynamically with `brew --prefix`.
- Linux and WSL clipboard helpers prefer `wl-copy`, `xclip`, `xsel`, or `clip.exe` depending on what exists.
- Open [`dotfiles/.config/git/personal/personal.gitconfig`](/Users/pratyakshchoudhary/bootstrap/dotfiles/.config/git/personal/personal.gitconfig) and replace the personal credentials with your own.
