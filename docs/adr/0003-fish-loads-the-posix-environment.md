# Fish loads the Environment from the POSIX definition

The Environment is written once, in POSIX shell (`env.sh`). Fish does not keep its own copy: its `00-env.fish` runs `env.sh` in `sh` and takes the PATH and variables that come out. Keeping two hand-written copies had already let them drift apart (mise shims, finding Homebrew from GUI-launched processes, `BROWSER` on WSL), and nothing caught it.

## Considered Options

- **A data manifest read by both shells.** Rejected: the Environment has conditional parts (finding Homebrew, the WSL Platform, the mise data directory) that a list of paths can't express, so that logic would still be written twice.
- **Generate `00-env.fish` at install time.** Rejected: editing `env.sh` without re-running the install leaves fish stale, so a PATH change would not be a one-place change.

## Consequences

- Every fish shell, interactive or not, starts one extra `sh` process at startup.
- Every shell follows the same rule when adding to PATH: a directory that is already present is left where it is. Fish no longer moves entries to the front.
