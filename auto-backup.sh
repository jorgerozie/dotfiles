#!/bin/bash

# $HOME/.config
cp -r ~/.config/kitty ~/Repositories/dotfiles/.config/
cp -r ~/.config/nvim ~/Repositories/dotfiles/.config/
cp -r ~/.config/qtile ~/Repositories/dotfiles/.config/
cp -r ~/.config/rofi ~/Repositories/dotfiles/.config/

# $HOME/.local
cp -r ~/.local/share/rofi/themes/ ~/Repositories/dotfiles/.local/share/rofi/

# $HOME
cp ~/.bashrc ~/Repositories/dotfiles/
