# POSIX startup files use managed blocks, not stow

The repo does not stow `.zshrc`, `.zshenv`, `.bashrc`, `.bash_profile` or `.profile`. Instead, `setup.sh` writes a Managed block at the top of each Live startup file that sources the repo's Environment and Interactive setup. Third-party installers (jcode, LM Studio, OrbStack, rbenv, JetBrains Toolbox, and others) keep appending to these files. If the files were stowed, those appends would land in tracked repo files and show up in every `git status`. Keeping the files unmanaged, except for one block, lets installers keep writing to them while the repo still controls what loads.

## Considered Options

- **Stow the startup files.** Rejected: installer lines end up inside the repo.
- **Own nothing on the POSIX side.** Rejected: zsh and bash are still used interactively, and tools started from the GUI run non-interactive zsh, which needs the Environment.

## Consequences

- The block goes at the top so installer lines that come after it can still override PATH. The Environment skips adding PATH directories that are already present.
- `setup.sh` only ever touches its own block. It never edits or removes installer lines.
