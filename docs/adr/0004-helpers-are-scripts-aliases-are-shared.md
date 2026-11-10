# Helpers are scripts on PATH; aliases are shared

Custom commands are written once and work in fish, zsh and bash, interactive or not. Each new one goes in the first of these places that fits:

1. **A Helper**: an executable POSIX `sh` script in `dotfiles/.local/bin/`, stowed into `~/.local/bin`, which the Environment puts on PATH. This is the default for anything that doesn't need to change the calling shell.
2. **A Shared alias**: one `alias name='...'` line in a single file that both `interactive.sh` and fish's Interactive setup source. `alias name='...'` means the same thing in all three shells, so that one line is the whole definition. The file holds only single-quoted alias lines, nothing else.
3. **A Helper plus a one-line wrapper in each shell**: only for something that must change the calling shell (`cd`, exporting a variable, activating an environment). The Helper does the work and prints the result. Each shell's Interactive setup has a wrapper that applies it, for example `cd "$(pick-dir)"` / `cd (pick-dir)`.

Before this, every helper was written twice, as a POSIX function and as a fish function, and had to be kept in sync by hand. Being functions, they also didn't exist in non-interactive shells, so editors and scripts couldn't call them.

## Considered Options

- **Keep shell functions, written twice.** Rejected: the two copies drift (the same problem ADR-0003 solved for the Environment), and functions don't reach non-interactive shells.
- **Turn aliases into scripts too.** Rejected: zsh and fish complete an alias using the target command's completions, and a script loses that.
- **A cross-shell alias manager (aliae and similar).** Rejected: it's another dependency, and it overlaps with the Environment, which already has one definition.
- **Run bash functions inside fish (bass, foreign_env).** Rejected: slow on every call, and only reliable for setting variables.

## Consequences

- Helpers cost a process start per call, which doesn't matter for interactive commands.
- A Shared alias has to parse in all three shells, and the tests check that it does. An alias that needs different text per shell (`h`, which is `history 0` in zsh) stays in that shell's own Interactive setup.
- Removing or renaming a Stowed dotfile leaves a broken link in `$HOME`, so `install-dotfiles.sh` removes broken links that point into the repo.
