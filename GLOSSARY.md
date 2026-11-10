# Bootstrap

Personal machine bootstrap: wires a consistent shell and editor setup onto macOS, Linux and WSL machines. It lists baseline tools for each Platform, but package installation is not automated yet.

## Language

### Machines

**Platform**:
The kind of machine being bootstrapped: macOS, Linux, or WSL. WSL is its own platform, not a flavour of Linux.
_Avoid_: OS, target, system

**Manual installer**:
A tool or application that the bootstrap lists but does not install, because it needs its own installer.
_Avoid_: non-brew package

### Shell setup

**Environment**:
The PATH entries and exported variables every shell process should see, interactive or not, including those started by tools and editors. It holds only what the repo chooses; entries a tool's own installer adds (Cargo, Go and the like) are not part of it. It is defined once and every shell loads that one definition.
_Avoid_: env, profile, path setup

**Interactive setup**:
What a shell gets only when a person is typing at it: prompt, completions, tool hooks, the Shared aliases, and the few aliases or wrappers that must differ per shell.
_Avoid_: rc, shell config, init

**Helper**:
A small command the repo owns, kept once as a Stowed dotfile on PATH, so it works the same from fish, zsh, bash, scripts and editors. Anything that does not need to change the calling shell's state is a Helper.
_Avoid_: function, util, shell helper

**Shared alias**:
An alias defined once and loaded into every interactive fish, zsh and bash shell. An alias that cannot be written the same way for all three is not a Shared alias; it lives in that shell's Interactive setup.
_Avoid_: abbreviation, shortcut

**Live file**:
A file in the home directory that the user and their tools both write to, so the bootstrap does not own it: the shell startup files (`.zshrc`, `.bashrc`, `.profile`, fish's `config.fish` and similar) and `~/.gitconfig`. Anything that differs per machine, such as the git identity, lives in a Live file.
_Avoid_: Live startup file, dotfile, rc file

**Managed block**:
The marked region the bootstrap owns inside a shell's Live file, used to load the Environment and Interactive setup. Everything outside it belongs to the user and their installers.
_Avoid_: hook, snippet, shim

**Stowed dotfile**:
A configuration file the repo owns outright and links into the home directory. Only files are stowed, never directories: the directory around a Stowed dotfile belongs to the home directory, so installers can drop their own files beside it.
_Avoid_: managed file, symlinked config
