#!/usr/bin/env bash

#== Setup ==#
    echo "Updating package list..."
    sudo apt-get update -y
    
    echo "Upgrading distro..."
    sudo apt dist-upgrade -y
    
    echo "Upgrading existing packages..."
    sudo apt-get upgrade -y

    echo "Copying over dotfiles..."
    sudo apt install -y rsync
    rsync -av ./home ~

    echo "Adding Microsoft repository..."
    sudo apt install -y wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg

#== Remove ==#
    echo "Removing unnecessary packages"
    sudo apt remove -y vim

#== Install ==#
    echo "Installing new packages..."

    #-- Keyring tools --#
    sudo apt install -y libsecret-tool seahorse
    #TODO set up default keyring

    #-- Terminal apps --#
    sudo apt install -y nano

    #-- System apps --#
    sudo apt install -y synaptic thunar mousepad

    #-- Theming --#
    sudo apt install -y lxappearance gnome-tweaks
    sudo apt install -y gnome-themes-extra orchis-gtk-theme papirus-icon-theme
    sudo apt install -y fonts-noto fonts-roboto fonts-firacode

    gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
    gsettings set org.gnome.desktop.interface gtk-theme "Orchis-Dark"
    gsettings set org.gnome.desktop.wm.preferences theme "Orchis-Dark"

    #-- Git --#
    git config --global init.defaultBranch main

    #-- IDE --#
    sudo apt install -y code

#== Flatpak ==#
    #TODO make this all quiet
    #sudo apt install -y flatpak
    #sudo flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
    #flatpak install flathub io.github.flattool.Warehouse
    #flatpak install flathub com.github.tchx84.Flatseal
    
#== Cleanup ==#
    echo "Cleaning up..."
    sudo apt autoremove -y
    sudo apt clean

    echo "\nPlease restart the Linux instance to finish..."
