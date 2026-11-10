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

2. Install the baseline packages yourself. Automated package installation is being rewritten, so for now the package lists are reference only:

   - macOS: `brew bundle --file ./Brewfile` (install [Homebrew](https://brew.sh) first)
   - Debian/Ubuntu/WSL: the packages in `packages/apt-packages.txt`
   - Arch: the packages in `packages/pacman-packages.txt`

   `stow` must be installed before the next step.

3. Install the dotfiles.

```sh
./dotfiles/install-dotfiles.sh
```

This stows the dotfiles into `$HOME` and writes the Managed blocks into your shell startup files.

4. Switch your login shell to fish when ready:

```sh
chsh -s "$(command -v fish)"
```

## Manual installers

`non-brew-packages.yaml` is reserved for tools and applications that still need their own installers or do not work well with homebrew, such as `rustup`, `bitwarden`, etc.

## Shell layout

- `dotfiles/.config/fish/`: primary interactive shell configuration
- `dotfiles/.config/shell/`: shared Platform detection, the Environment, and the Shared aliases
- `dotfiles/.config/shell/env.sh`: the Environment (PATH, exported vars, mise shims), defined once for every shell, interactive or not. zsh, bash and `sh` source it; fish imports it ([ADR-0003](docs/adr/0003-fish-loads-the-posix-environment.md))
- `dotfiles/.config/shell/platform.sh`: Platform detection (macos, linux or wsl)
- `dotfiles/.config/shell/interactive.sh`: Interactive setup shared by zsh and bash (prompt, completions, tool hooks, loading the Shared aliases)
- `dotfiles/.config/shell/aliases.sh`: the Shared aliases, loaded by interactive fish, zsh and bash
- `dotfiles/.local/bin/`: the Helpers (`copy`, `inv`, `eza-ls`, `update-brew`), scripts on PATH for every shell and tool

The repo does not own `~/.zshrc`, `~/.zshenv`, `~/.bashrc`, `~/.bash_profile` or `~/.profile`, because installers keep appending to them. Instead, `dotfiles/install-dotfiles.sh` writes a managed block between `# >>> bootstrap >>>` and `# <<< bootstrap <<<` at the top of each one. That block loads the files above, and everything outside it is left alone. See [ADR-0001](docs/adr/0001-posix-startup-files-use-managed-blocks.md).

## Adding a command or alias

Write it once, in the first place that fits, and it works in fish, zsh and bash ([ADR-0004](docs/adr/0004-helpers-are-scripts-aliases-are-shared.md)):

1. **A Helper.** An executable POSIX `sh` script in `dotfiles/.local/bin/`. This is the default for anything that doesn't need to change your current shell. Scripts, editors and `sh -c` can call it too.
2. **A Shared alias.** One `alias name='command args'` line in `dotfiles/.config/shell/aliases.sh`. Use single quotes and nothing else on the line: the same line has to parse in all three shells.
3. **A Helper plus a one-line wrapper per shell.** Only for something that must change your current shell (`cd`, `export`). The Helper prints the result, and a wrapper in `interactive.sh` and `10-interactive.fish` applies it, for example `cd "$(pick-dir)"` and `cd (pick-dir)`.

Then re-run the install below so stow links the new file.

To re-apply the dotfiles:

```sh
./dotfiles/install-dotfiles.sh
```

## Notes

- The Environment finds Homebrew in its standard locations even when it isn't on PATH yet, as in GUI-launched processes.
- `tests/env-parity.sh` checks that sh, bash, zsh and fish all end up with the same Environment. Run it after changing `env.sh` or the fish setup.
- `tests/helpers.sh` checks that every Helper and Shared alias works in sh, bash, zsh and fish, and that the install removes links to files the repo no longer has. Run it after adding a Helper or alias.
- Re-running the install removes links in `$HOME` to Stowed dotfiles the repo has since deleted or renamed. Broken links that don't point into the repo are left alone.
- Tools that add their own PATH entries (rustup's Cargo, Go) are not part of the repo. If one of them didn't set up a shell for you, add its line to that shell's startup file outside the bootstrap block.
- `copy` uses the first clipboard tool it finds: `pbcopy`, `clip.exe` (WSL), `wl-copy`, `xclip`, then `xsel`.
- Open [`dotfiles/.config/git/personal/personal.gitconfig`](/Users/pratyakshchoudhary/bootstrap/dotfiles/.config/git/personal/personal.gitconfig) and replace the personal credentials with your own.
