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
4. When you run `copy` or `inv`, fish finds it on PATH in `~/.local/bin`, like any other program.

That last part is important. The repo's own commands (the Helpers) are not fish functions. They are POSIX `sh` scripts, so zsh, bash, editors and other scripts can run them too, and there is only one copy of each to maintain. See [ADR-0004](docs/adr/0004-helpers-are-scripts-aliases-are-shared.md).

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

- Loads the Environment from `~/.config/shell/env.sh`, its one definition. It runs `env.sh` in `sh` and copies every PATH entry and variable that `env.sh` added or changed into fish.
- Holds no paths or variables of its own. To add a PATH entry or a variable, edit `env.sh`; every shell picks it up. See [ADR-0003](docs/adr/0003-fish-loads-the-posix-environment.md).

Tools that add their own paths (rustup, Go and the like) do it in their own `conf.d` fragments next to the repo's, not here.

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

- the Shared aliases (`ll`, `lla`), by sourcing `~/.config/shell/aliases.sh`, the same file zsh and bash load
- alias `h`, which stays fish-only because zsh's version is different
- `starship init fish | source`
- `fzf --fish | source`
- `zoxide init fish | source`
- `uv generate-shell-completion fish | source`
- `mise activate fish | source` (non-interactive fish gets mise's shims from the Environment instead)

So this is your interactive user-experience file.

## Helpers and Shared aliases

Reusable commands live in `~/.local/bin` as POSIX `sh` scripts, not in `~/.config/fish/functions/`:

- `copy`: sends stdin to the first clipboard tool it finds (`pbcopy`, `clip.exe` on WSL, `wl-copy`, `xclip`, `xsel`)
- `inv`: pick a file with fzf and copy its absolute path
- `eza-ls`: eza with the repo's default flags
- `update-brew`: update, upgrade and clean up Homebrew

Aliases that read the same in every shell live in `~/.config/shell/aliases.sh`. Fish sources that file directly, because `alias ll='eza-ls -lh'` is valid fish as well as valid zsh and bash.

To add your own, see "Adding a command or alias" in the README. `~/.config/fish/functions/` is still fish's to use, for example for functions installers or you add on one machine, but the repo puts nothing there.

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

The repo's PATH entries live in `~/.config/shell/env.sh`, not in fish. For a one-off entry of your own, `fish_add_path` is the fish-native way:

```fish
fish_add_path ~/some/bin
```

### Conditionals

```fish
if type -q starship
    starship init fish | source
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

- `conf.d/00-*.fish`: loading the Environment from `env.sh`
- `conf.d/10-*.fish`: interactive tool initialization
- `~/.local/bin`: reusable commands (Helpers), shared with every shell
- `~/.config/shell/aliases.sh`: aliases, shared with every shell
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
echo $BOOTSTRAP_PLATFORM
echo $PATH
```

### Check whether an alias exists

```fish
functions ll
```

### See where a command comes from

```fish
type copy
type ll
type zoxide
```

## Practical Maintenance Advice

- Put PATH entries and variables in `~/.config/shell/env.sh`, never in fish
- Put prompt/completions/tool init in `10-interactive.fish`
- Put custom commands in `dotfiles/.local/bin/` and aliases in `dotfiles/.config/shell/aliases.sh`, so zsh and bash get them too
- Avoid putting lots of logic into `config.fish`

## Practical Outcome in This Repo

The current shell model is:

- fish is the supported interactive shell
- bash is used for scripts like `setup.sh`
- every shell loads the Environment from `~/.config/shell/env.sh`; zsh and bash load it, and `interactive.sh`, through a managed block (see the README)

So if you want to change your day-to-day shell experience, the fish files are now the main place to edit.
