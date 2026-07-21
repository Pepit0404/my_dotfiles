#!/bin/bash
speed=0

# ─── Color helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}$*${RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$(dirname "$SCRIPT_DIR")/packages.txt"

parse_packages_file() {
  if [[ ! -f "$PACKAGES_FILE" ]]; then
    error "Package file not found: $PACKAGES_FILE"
    exit 1
  fi

  PACKAGES=()
  NAME_OVERRIDES=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    # clean inline comments and space
    line="${line%%#*}"
    line="${line//[$'\t' ]}"
    [[ -z "$line" ]] && continue

    local generic="${line%% *}"
    PACKAGES+=("$generic")

    local rest="${line#"$generic"}"
    while [[ "$rest" =~ \[([a-z_-]+):([^]]+)\] ]]; do
      NAME_OVERRIDES+=("${generic}:${BASH_REMATCH[1]}:${BASH_REMATCH[2]}")
      rest="${rest#*"${BASH_REMATCH[0]}"}"
    done
  done < "$PACKAGES_FILE"
}

detect_manager() {
  local managers=("apt-get" "apt" "dnf" "yum" "pacman" "zypper" "apk" "brew" "pkg")
  for mgr in "${managers[@]}"; do
    if command -v "$mgr" &>/dev/null; then
      echo "$mgr"; return
    fi
  done
  echo "unknown"
}

update_index() {
  info "Updating package index…"
  case "$MANAGER" in
    apt-get|apt) $SUDO apt-get update -qq ;;
    dnf)         $SUDO dnf check-update -q || true ;;
    yum)         $SUDO yum check-update -q || true ;;
    pacman)      $SUDO pacman -Sy --noconfirm ;;
    zypper)      $SUDO zypper refresh -q ;;
    apk)         $SUDO apk update -q ;;
    brew)        brew update -q ;;
    pkg)         $SUDO pkg update -q ;;
  esac
}

resolve_name() {
  local pkg="$1" mgr="$2"
  for override in "${NAME_OVERRIDES[@]}"; do
    local g="${override%%:*}" rest="${override#*:}"
    local m="${rest%%:*}" n="${rest#*:}"
    [[ "$g" == "$pkg" && "$m" == "$mgr" ]] && echo "$n" && return
  done
  echo "$pkg"
}

install_package() {
  local pkg
  pkg=$(resolve_name "$1" "$MANAGER")

  info "Installing ${BOLD}$pkg${RESET}…"
  case "$MANAGER" in
    apt-get|apt) $SUDO apt-get install -y -qq "$pkg" ;;
    dnf)         $SUDO dnf install -y -q   "$pkg" ;;
    yum)         $SUDO yum install -y -q   "$pkg" ;;
    pacman)      $SUDO pacman -S --noconfirm --needed "$pkg" ;;
    zypper)      $SUDO zypper install -y -q "$pkg" ;;
    apk)         $SUDO apk add -q           "$pkg" ;;
    brew)        brew install -q             "$pkg" ;;
    pkg)         $SUDO pkg install -y        "$pkg" ;;
  esac
}

main() {
  header "=== Package Installer ==="

  info "Package file: ${BOLD}$PACKAGES_FILE${RESET}"

  parse_packages_file
  info "Found ${#PACKAGES[@]} package(s) to install."

  # Detect manager
  MANAGER=$(detect_manager)
  if [[ "$MANAGER" == "unknown" ]]; then
    error "No supported package manager found."
    error "Supported: apt, dnf, yum, pacman, zypper, apk, brew, pkg"
    exit 1
  fi
  success "Detected package manager: ${BOLD}$MANAGER${RESET}"

  # Set sudo prefix (brew and some others don't need it)
  if [[ "$MANAGER" == "brew" ]]; then
    SUDO=""
  else
    if [[ $EUID -ne 0 ]]; then
      if command -v sudo &>/dev/null; then
        SUDO="sudo"
        warn "Not running as root — will use sudo."
      else
        error "Please run as root or install sudo."
        exit 1
      fi
    else
      SUDO=""
    fi
  fi

  # Update index
  if [[ $speed == 0 ]]; then
    info 'Update index'
    update_index
  fi

  # Install loop
  header "Installing ${#PACKAGES[@]} packages…"
  FAILED=()
  for pkg in "${PACKAGES[@]}"; do
    if install_package "$pkg"; then
      success "$pkg"
    else
      error "Failed to install: $pkg"
      FAILED+=("$pkg")
    fi
  done

  # Summary
  header "─── Summary ───────────────────────────────"
  local ok=$(( ${#PACKAGES[@]} - ${#FAILED[@]} ))
  echo -e "  Installed : ${GREEN}${ok}${RESET} / ${#PACKAGES[@]}"
  if [[ ${#FAILED[@]} -gt 0 ]]; then
    echo -e "  Failed    : ${RED}${FAILED[*]}${RESET}"
    exit 1
  else
    success "All packages installed successfully."
  fi
}

# Load parameters
while [[ $# > 0 ]]
do
  case "$1" in
    -s|--speed)
      speed=1
      shift
      ;;

    -p|--packages)
      PACKAGES_FILE=$2
      shift
      shift
      ;;

    -h|--help|*)
      echo "Usage:"
      echo "    -s,  --speed     \"does not execute package upgrade\""
      echo "    -p,  --packages  \"set packages files path\""
      echo "    -h,  --help"
      exit 1
      ;;
  esac
done

main "$@"
