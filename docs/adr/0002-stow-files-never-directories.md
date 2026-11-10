# Stow files, never directories

The repo stows with `--no-folding`, so every directory under `$HOME` (`~/.config/fish`, `~/.config/git` and the rest) is a real directory, and only each Stowed dotfile inside it is a link into the repo. Without it, stow links a whole directory into the repo when the directory doesn't exist yet, and then anything an installer or the tool itself writes there (rustup's `conf.d/rustup.fish`, envman's lines in `config.fish`, fish's `fish_variables`, completions) lands in the repo. This is the problem ADR-0001 solved for the POSIX startup files, one directory level down.

For the same reason, fish's `config.fish` is a Live file, not a Stowed dotfile. The repo's fish setup lives only in its own `conf.d/` fragments, and installers get `config.fish` and their own fragments next to the repo's.

## Considered Options

- **Let stow fold, hide installer output with `.gitignore`.** Rejected: every new installer needs a new ignore line, and files the repo already tracks (like `config.fish`) can't be ignored at all.
- **Fold only directories nobody writes into.** Rejected: you can't know ahead of time which tools will write where, and `--no-folding` costs nothing for directories that stay quiet.

## Consequences

- `install-dotfiles.sh` unfolds directories that an earlier stow already folded: it moves untracked files out of the repo directory into a new real directory in `$HOME`, then restows. If the real path already exists, it stops instead of merging.
- Files that are specific to one machine or written by an installer (`rustup.fish`, `~/go/bin` on PATH, the envman lines) are not in the repo. A fresh machine gets them back from its installers, or by hand.
