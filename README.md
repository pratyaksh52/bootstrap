# Bootstrap

This repo manages a fish-first shell setup across macOS, Linux, and WSL. Fish is the login shell. Zsh and bash are still set up for occasional interactive use, and they share one environment and one interactive setup.

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

`non-brew-packages.yaml` is reserved for tools and applications that still need their own installers or do not work well with homebrew, such as `rustup`, `bitwarden`, etc.

## Shell layout

- `dotfiles/.config/fish/`: primary interactive shell configuration
- `dotfiles/.config/shell/`: shared OS detection, environment, path setup, and portable helpers
- `dotfiles/.config/shell/env.sh`: the Environment for zsh, bash and `sh` (PATH, exported vars, mise shims); loaded by every POSIX shell, interactive or not
- `dotfiles/.config/shell/interactive.sh`: Interactive setup shared by zsh and bash (prompt, completions, aliases, helpers, tool hooks)

The repo does not own `~/.zshrc`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile` or `~/.profile`, because installers keep appending to them. Instead, `dotfiles/install-dotfiles.sh` writes a managed block between `# >>> bootstrap >>>` and `# <<< bootstrap <<<` at the top of each one. That block loads the files above, and everything outside it is left alone. See [ADR-0001](docs/adr/0001-posix-startup-files-use-managed-blocks.md).

To re-apply the dotfiles without reinstalling packages:

```sh
./dotfiles/install-dotfiles.sh
```

## Notes

- macOS detects Homebrew dynamically with `brew --prefix`.
- Linux and WSL clipboard helpers prefer `wl-copy`, `xclip`, `xsel`, or `clip.exe` depending on what exists.
- Open [`dotfiles/.config/git/personal/personal.gitconfig`](/Users/pratyakshchoudhary/bootstrap/dotfiles/.config/git/personal/personal.gitconfig) and replace the personal credentials with your own.
