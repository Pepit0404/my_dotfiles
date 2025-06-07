#!/bin/bash

# Define paths
DOTFILES_DIR="$HOME/my_dotfiles/config"
BACKUP_DIR="$HOME/my_dotfiles/backup"

# Verification of the shell
if [[ $SHELL != *"/zsh" ]]; then
   chsh -s $(which zsh)
fi

repo = "$HOME/my_dotfiles/config/.zsh/plugins/fast-syntax-highlighting"
if [ ! -d $repo ]; then 
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git $repo
fi

repo = "$HOME/my_dotfiles/config/.zsh/plugins/zsh-autosuggestions"
if [ ! -d $repo ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $repo
fi

repo = "$HOME/my_dotfiles/config/.zsh/plugins/zsh-completions"
if [ ! -d $repo ]; then
    git clone https://github.com/zsh-users/zsh-completions.git $repo
fi

# Create a backup directory
if [ ! -d "$DIRECTORY" ]; then
    mkdir -p "$BACKUP_DIR"
fi

cd $DOTFILES_DIR
# Loop through each file and create a symlink
for file in .* ; do
    dest=$HOME/$file

    if [ -L $dest ]; then
	rm -rf $dest
    fi

    # Create symlink
    echo "Linking $file to $dest"
    ln -s $PWD/$file $dest
done

cd - > /dev/null

echo "Dotfile installation complete!"
