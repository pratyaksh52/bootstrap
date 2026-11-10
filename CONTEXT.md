# Bootstrap

Personal machine bootstrap: installs baseline tools and wires a consistent shell and editor setup onto macOS, Linux and WSL machines.

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
The PATH entries and exported variables every shell process should see, interactive or not, including those started by tools and editors.
_Avoid_: env, profile, path setup

**Interactive setup**:
What a shell gets only when a person is typing at it: prompt, completions, aliases, helper commands, tool hooks.
_Avoid_: rc, shell config, init

**Live startup file**:
A shell startup file in the home directory (`.zshrc`, `.bashrc`, `.profile`, fish's `config.fish` and similar) that the user and third-party installers both write to. The bootstrap does not own it.
_Avoid_: dotfile, rc file

**Managed block**:
The marked region the bootstrap owns inside a Live startup file, used to load the Environment and Interactive setup. Everything outside it belongs to the user and their installers.
_Avoid_: hook, snippet, shim

**Stowed dotfile**:
A configuration file the repo owns outright and links into the home directory. Only files are stowed, never directories: the directory around a Stowed dotfile belongs to the home directory, so installers can drop their own files beside it.
_Avoid_: managed file, symlinked config
