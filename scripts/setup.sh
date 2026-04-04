#!/bin/bash

# ─── Color helpers ────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
header()  { echo -e "\n${BOLD}$*${RESET}"; }

# Define paths
DOTFILES_DIR="$HOME/my_dotfiles/dots"
BACKUP_DIR="$HOME/my_dotfiles/backup"
CONFIG_DIR="$HOME/my_dotfiles/config"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_DIR="$REPO_DIR/scripts"
PLUGINS_FILE="$REPO_DIR/zsh_plugins.txt"
PLUGINS_DIR="$REPO_DIR/config/zsh/plugins"

while IFS=' ' read -r name url || [[ -n "$name" ]]; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  repo="$PLUGINS_DIR/$name"
  if [ ! -d "$repo" ]; then
    info "Cloning $name plugins"
    git clone "$url" "$repo" || { error "Failed to clone $name"; exit 1; }
  fi
done < "$PLUGINS_FILE"

# Create a backup directory
if [ ! -d "$BACKUP_DIR" ]; then
  mkdir -p "$BACKUP_DIR"
fi

cd $DOTFILES_DIR
# Loop through each file and create a symlink
for file in .* ; do
  [[ "$file" == "." || "$file" == ".." ]] && continue
  dest=$HOME/$file

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
     warn "Backing up existing $dest"
     mv "$dest" "$BACKUP_DIR/dots/"
   fi

  if [ -L $dest ]; then
    rm -f $dest
  fi

  # Create symlink
  info "Linking $file to $dest"
  ln -s $PWD/$file $dest
done

cd $CONFIG_DIR
for conf in * ; do
  [[ "$conf" == "." || "$conf" == ".." ]] && continue
  dest=$HOME/.config/$conf

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
     warn "Backing up existing $dest"
     mv "$dest" "$BACKUP_DIR/config/"
  fi

  if [ -L $dest ]; then
    rm -f $dest
  fi

  # Create symlink
  info "Linking $conf to $dest"
  ln -s $PWD/$conf $dest
done

cd - > /dev/null

success "Dotfile installation complete!"
