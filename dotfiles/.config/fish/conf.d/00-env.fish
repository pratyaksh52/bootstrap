# Load the Environment from its one definition, ~/.config/shell/env.sh.
# sh prints its environment before and after sourcing env.sh; every entry that
# is new or changed is copied into fish. Nothing here needs editing when
# env.sh changes. See docs/adr/0003-fish-loads-the-posix-environment.md.

set -l env_sh ~/.config/shell/env.sh
test -r $env_sh; or return

set -l marker __bootstrap_env_loaded__
set -l dump (sh -c 'env -0; printf "%s\0" "$2"; . "$1" && env -0' sh $env_sh $marker | string split0)
or return

set -l split (contains -i -- $marker $dump)
or return
# Nothing after the marker means env.sh failed; keep the inherited environment.
test $split -gt 1 -a $split -lt (count $dump); or return

set -l before $dump[1..(math $split - 1)]
for entry in $dump[(math $split + 1)..-1]
    contains -- $entry $before; and continue

    set -l kv (string split -m 1 = -- $entry)
    switch $kv[1]
        case _ SHLVL PWD OLDPWD
            continue
        case '*PATH'
            set -gx $kv[1] (string split : -- $kv[2])
        case '*'
            set -gx $kv[1] $kv[2]
    end
end
