# Platform detection for POSIX shells: macos, linux or wsl.
# Defines functions only, so setup.sh can load it straight from the repo
# before anything is stowed, and env.sh can load it from $HOME.

bootstrap_is_wsl() {
  [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null
}

bootstrap_platform() {
  case "$(uname -s)" in
    Darwin) printf 'macos\n' ;;
    Linux)
      if bootstrap_is_wsl; then
        printf 'wsl\n'
      else
        printf 'linux\n'
      fi
      ;;
    *) printf 'unsupported\n' ;;
  esac
}
