# Git config is the XDG file; ~/.gitconfig is a Live file

The repo owns git's settings as one Stowed dotfile at `~/.config/git/config`, which git reads on its own. `~/.gitconfig` is a Live file: `gh auth setup-git`, `git lfs install`, `git config --global` and the user write to it, and git reads it after the XDG file, so anything set there wins. The git identity (`user.name`, `user.email`) and anything work-specific (other identities, `includeIf` rules, Azure DevOps credential settings) live only in the Live file, never in the repo. Stowing `~/.gitconfig` had sent every tool's `--global` write into tracked repo files, the problem ADR-0001 solved for the shell startup files.

`install-dotfiles.sh` makes sure `~/.gitconfig` exists, even when empty, and asks for the identity once if none is set. The empty file matters: when `~/.gitconfig` is missing and the XDG file exists, `git config --global` writes to the XDG file, which is the repo's.

## Considered Options

- **Keep stowing `~/.gitconfig`.** Rejected: tool writes land in the repo, and identity and work settings had to be pulled in through gitignored include files that failed silently when missing.
- **A Managed block inside `~/.gitconfig`.** Rejected: git already reads the XDG file without being told to, so a block would add install-time machinery for nothing.

## Consequences

- Deleting the "create an empty `~/.gitconfig`" step looks like a harmless cleanup but sends `--global` writes back into the repo.
- A new machine has no identity until the install script asks for it or the user sets it.
- Machines set up before this change lose the settings that came from the old stowed files (the Azure `useHttpPath` setting) and need them re-added by hand.
