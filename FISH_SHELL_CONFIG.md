# How the Fish Shell Config Works

Fish works differently from bash and zsh, so the most important thing to understand is its startup model.

When fish starts interactively, it reads its main config file `~/.config/fish/config.fish`, and it also automatically loads every `*.fish` file in `~/.config/fish/conf.d/` in sorted order.

In this repo, that means fish will automatically load:

- `~/.config/fish/conf.d/00-env.fish`
- `~/.config/fish/conf.d/10-interactive.fish`

The `00-` and `10-` naming is intentional. It gives you a predictable order:

- `00-env.fish` runs first and sets environment variables and PATH
- `10-interactive.fish` runs after that and sets interactive-only behavior like prompt, aliases, and tool init

## Mental Model

When fish starts:

1. Fish starts up.
2. It loads environment setup from `conf.d`.
3. It loads interactive setup from `conf.d`.
4. When you call a function like `copy` or `inv`, fish autoloads it from `~/.config/fish/functions/`.

That last part is important. Fish has an autoloading function system. You do not need to source every function manually.

If you run `copy`, fish looks for `~/.config/fish/functions/copy.fish` and loads it automatically.

The same applies to:

- `realpath_compat.fish`
- `eza-ls.fish`
- `inv.fish`
- `update-brew.fish`

## File-by-File Explanation

### `config.fish`

File:
`~/.config/fish/config.fish`

What it does:

- Right now it is basically just a placeholder.
- Fish already auto-loads `conf.d`, so there is no manual bootstrap logic here.
- This is a good place only if you later need something truly global that should not live in a `conf.d` fragment.

### `00-env.fish`

File:
`~/.config/fish/conf.d/00-env.fish`

What it does:

- Sets OS detection flags:
  - `BOOTSTRAP_OS`
  - `BOOTSTRAP_IS_WSL`
- Adds common paths with `fish_add_path`
- Detects Homebrew and adds brew paths if available
- Sets `LESS` / `LESSOPEN`
- Adds Cargo path if `~/.cargo/bin` exists

This file should stay focused on environment state, not aliases or prompt logic.

### `10-interactive.fish`

File:
`~/.config/fish/conf.d/10-interactive.fish`

What it does:

- Starts with:

```fish
status --is-interactive; or return
```

That means: if this is not an interactive shell, stop immediately.

Why this matters:

- Non-interactive shells should not waste time loading prompt code or terminal UX features.

Then it sets:

- alias `h`
- aliases `ll` and `lla`
- `starship init fish | source`
- `fzf --fish | source`
- `zoxide init fish | source`
- `uv generate-shell-completion fish | source`

So this is your interactive user-experience file.

## Functions Directory

The functions directory is where reusable commands live.

Examples:

- `~/.config/fish/functions/copy.fish`
- `~/.config/fish/functions/realpath_compat.fish`
- `~/.config/fish/functions/eza-ls.fish`
- `~/.config/fish/functions/inv.fish`
- `~/.config/fish/functions/update-brew.fish`

For example, `copy.fish`:

- checks what clipboard tool exists
- uses `pbcopy` on macOS
- uses `clip.exe` on WSL
- falls back to `wl-copy`, `xclip`, or `xsel` on Linux

Example:

```fish
function copy
    if type -q pbcopy
        pbcopy
    else if test "$BOOTSTRAP_IS_WSL" = 1; and type -q clip.exe
        clip.exe
    end
end
```

## Fish Syntax Basics

Fish syntax is the main thing you need to learn to maintain this comfortably.

### Variables

```fish
set -gx NAME value
```

Meaning:

- `set` defines variables
- `-g` means global
- `-x` means exported to child processes

So this:

```fish
set -gx LESS -R
```

is roughly like this in bash/zsh:

```sh
export LESS="-R"
```

### PATH management

```fish
fish_add_path -m ~/.local/bin
```

This is preferred over manually editing `$PATH`.

Why:

- avoids duplicates
- cleaner than string concatenation
- fish-native

### Conditionals

```fish
if type -q brew
    set -gx BREW_PREFIX (brew --prefix)
end
```

Notes:

- `type -q` quietly checks whether a command exists
- command substitution uses `( ... )`, not `$( ... )`
- blocks end with `end`

### Functions

```fish
function eza-ls
    eza --icons=auto $argv
end
```

Notes:

- function args are in `$argv`
- fish does not use `"$@"` like bash

### Aliases

```fish
alias ll="eza-ls -lh"
```

In fish, `alias` is basically shorthand for creating a function.

## Recommended Structure

A good maintenance structure is:

- `conf.d/00-*.fish`: environment and OS detection
- `conf.d/10-*.fish`: interactive tool initialization
- `functions/*.fish`: reusable commands
- `config.fish`: mostly empty unless absolutely needed

This keeps the setup understandable and scalable.

## Useful Debugging Commands

### Check syntax

```sh
fish -n ~/.config/fish/conf.d/00-env.fish
```

### Start fish

```sh
fish
```

### Inspect variables

```fish
echo $BOOTSTRAP_OS
echo $PATH
```

### Check whether a function exists

```fish
functions copy
functions inv
```

### See where a command comes from

```fish
type copy
type ll
type zoxide
```

## Practical Maintenance Advice

- Put env/path logic in `00-env.fish`
- Put prompt/completions/tool init in `10-interactive.fish`
- Put custom commands in `functions/`
- Avoid putting lots of logic into `config.fish`

## Practical Outcome in This Repo

The current shell model is:

- fish is the supported interactive shell
- bash is used for scripts like `setup.sh`
- zsh still works, but only as a compatibility shim

So if you want to change your day-to-day shell experience, the fish files are now the main place to edit.
