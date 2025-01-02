#!/bin/bash

# Vars
TEMP_DIR=$(mktemp -d) || { echo "Failed to create temp directory"; exit 1; }
YAY_URL="https://aur.archlinux.org/yay-git.git"
DOTFILES_URL="https://github.com/jrubcor/dotfiles"


# Function to install pacman packages
install_pacman_packages() {
    for package in "$@"; do
        if ! pacman -Q "$package" &>/dev/null; then
            echo "Installing $package..."
            sudo pacman -S --noconfirm "$package"
        else
            echo "$package is already installed"
        fi
    done
}

# Function to install pacman packages
install_yay_packages() {
    for package in "$@"; do
        if ! yay -Q "$package" &>/dev/null; then
            echo "Installing $package..."
            yay -S --noconfirm "$package"
        else
            echo "$package is already installed"
        fi
    done
}

# Install required pacman packages
install_pacman_packages alsa-utils discord git gtk3 kitty libnotify lxappearance neofetch neovim notification-daemon obsidian pipewire pipewire-alsa pipewire-pulse wireplumber pavucontrol python-psutil rofi scrot tree ttf-jetbrains-mono-nerd unzip xclip xorg-server-xephyr yazi udiskie ntfs-3g network-manager-applet

# Install yay
if ! pacman -Q "yay"; then
    git clone "$YAY_URL" "$TEMP_DIR/yay-git/" || { echo "Failed to clone repo"; exit 1; }
    cd "$TEMP_DIR/yay-git/" || { echo "Failed to enter directory"; exit 1; }
    makepkg -si || { echo "Build and install failed"; exit 1; }
else
    echo "yay is already installed"
fi

# Install required yay packages
install_yay_packages spotify


# Set up dotfiles
git clone --depth 1  "$DOTFILES_URL" "$TEMP_DIR/dotfiles"

if [ ! -d "$HOME/.config/qtile/" ]; then
    mkdir "$HOME/.config/qtile/"
else
    echo "~/.config/qtile directory already exists"
fi

if [ ! -d "$HOME/.config/kitty/" ]; then
    mkdir "$HOME/.config/kitty/"
else
    echo "~/.config/kitty's directory already exists"
fi

if [ ! -d "$HOME/.config/rofi/" ]; then
    mkdir "$HOME/.config/rofi/"
else
    echo "~/.config/rofi directory already exists"
fi

if [ ! -d "$HOME/.local/share/rofi/" ]; then
    mkdir "$HOME/.local/share/rofi/"
else
    echo "~/.local/share/rofi/ directory already exists"
fi

if [ ! -d "$HOME/.local/share/rofi/themes" ]; then
    mkdir "$HOME/.local/share/rofi/themes"
else
    echo "~/.local/share/rofi/themes's directory already exists"
fi

cp -r "$TEMP_DIR/dotfiles/.config/qtile/"* "$HOME/.config/qtile/"
cp -r "$TEMP_DIR/dotfiles/.config/rofi/"* "$HOME/.config/rofi/"
cp -r "$TEMP_DIR/dotfiles/.local/share/rofi/themes/"* "$HOME/.local/share/rofi/themes/"
cp -r "$TEMP_DIR/dotfiles/.config/kitty/"* "$HOME/.config/kitty/"

read -p "Do you want to replace .bashrc and .xprofile with the new config? (y/n): " user_choice
case "$user_choice" in
    y|Y|yes|YES)
        cp "$TEMP_DIR/dotfiles/.bashrc" "$HOME"
        cp "$TEMP_DIR/dotfiles/.xprofile" "$HOME"
        ;;
    n|N|no|NO)
        echo "Not replacing..."
        ;;
esac 

# Prompt the user
read -p "Do you want to download and install AstroNvim? (y/n): " user_choice

case "$user_choice" in
    y|Y|yes|YES)
        rm -r "$HOME/.config/nvim/"
        mkdir "$HOME/.config/nvim/"
        echo "Installing AstroNvim..."
        # Clone the AstroNvim template repository
        git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim || {
            echo "Failed to clone AstroNvim template repository.";
            exit 1;
        }

        # Remove the template's Git connection
        rm -rf ~/.config/nvim/.git || {
            echo "Failed to remove Git history from AstroNvim template.";
            exit 1;
        }

        # Copy user dotfiles into AstroNvim's configuration directory
        if [ -d "$TEMP_DIR/dotfiles/.config/nvim/" ]; then
            cp -r "$TEMP_DIR/dotfiles/.config/nvim/"* "$HOME/.config/nvim/" || {
                echo "Failed to copy dotfiles into AstroNvim configuration.";
                exit 1;
            }
        else
            echo "Dotfiles directory not found: $TEMP_DIR/dotfiles/.config/nvim/";
        fi
        echo "AstroNvim has been successfully installed and configured."
        ;;
    n|N|no|NO)
        echo "Not installing/reinstalling Astronvim..."
        ;;
    *)
        echo "Invalid input. Please enter 'y' or 'n'."
        ;;
esac

# Clean up temporary directory
rm -rf "$TEMP_DIR"

# Git config
echo "Write your git user name: "
read -r name
echo "Write your git user email: "
read -r email

# Configure git
git config --global user.name "$name"
git config --global user.email "$email"

# Confirmation message
echo "Git configuration updated successfully!"
echo "User Name: $(git config --global user.name)"
echo "User Email: $(git config --global user.email)"

echo "Let's go!"
