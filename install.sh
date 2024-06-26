#!/usr/bin/env bash

#== Setup ==#
    echo "Updating package list..."
    sudo apt update -y
    
    echo "Upgrading distro..."
    sudo apt dist-upgrade -y
    
    echo "Upgrading existing packages..."
    sudo apt upgrade -y

#== Remove ==#
    echo "Removing unnecessary packages"
    sudo apt remove -y vim

#== Install ==#
    echo "Installing new packages..."
    sudo apt install -y gpg rsync wget curl

    #-- Dotfiles --#
    echo "Copying over dotfiles..."
    rsync -av ./home/ ~

    #-- Keyring tools --#
    sudo apt install -y libsecret-1-0 libsecret-1-dev libsecret-tools seahorse
    if ! grep -q 'pam_gnome_keyring.so' /etc/pam.d/common-auth; then
        echo "auth optional pam_gnome_keyring.so" | sudo tee -a /etc/pam.d/common-auth > /dev/null
    fi
    
    if ! grep -q 'pam_gnome_keyring.so' /etc/pam.d/common-session; then
        echo "session optional pam_gnome_keyring.so auto_start" | sudo tee -a /etc/pam.d/common-session > /dev/null
    fi
    
    if ! grep -q 'pam_gnome_keyring.so' /etc/pam.d/passwd; then
        echo "password optional pam_gnome_keyring.so" | sudo tee -a /etc/pam.d/passwd > /dev/null
    fi

    echo "[Unit]
Description=GNOME Keyring Daemon

[Service]
ExecStart=gnome-keyring-daemon --components=secrets,ssh,pkcs11 --unlock --foreground
KillUserProcesses=no

[Install]
WantedBy=default.target" | sudo tee /etc/systemd/user/gnome-keyring-daemon.service > /dev/null
    systemctl --user daemon-reload
    systemctl --user enable gnome-keyring-daemon.service
    systemctl --user start gnome-keyring-daemon.service
    secret-tool store --label="Login Keyring" key-type=login key-value=initial

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

#== Dev tools ==#

    echo "Installing dev tools..."
    sudo apt install -y build-essential

    #-- Git --#
    echo "Configuring git..."
    sudo apt install -y git-credential-oauth

    git config --global init.defaultBranch main

    git config --global --unset-all credential.helper
    git config --global --add credential.helper "cache --timeout 7200" # two hours
    git config --global --add credential.helper oauth
    git config --global credential.helper /usr/share/doc/git/contrib/credential/libsecret/git-credential-libsecret

    read -p "Enter your email address for Git: " email
    read -p "Enter your Git username: " username

    git config --global user.email "$email"
    git config --global user.name "$username"

    #-- IDE --#
    echo "Adding Microsoft repository..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg

    sudo apt update -y
    sudo apt install -y code
    
    #-- Mise --#
    wget -qO - https://mise.jdx.dev/gpg-key.pub | gpg --dearmor > mise-archive-keyring.gpg
    sudo install -D -o root -g root -m 644 mise-archive-keyring.gpg /etc/apt/keyrings/mise-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/mise-archive-keyring.gpg] https://mise.jdx.dev/deb stable main" | sudo tee /etc/apt/sources.list.d/mise.list > /dev/null
    rm -f mise-archive-keyring.gpg
    
    sudo apt update -y
    sudo apt install -y mise

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

    echo "Restarting Sommelier..."
    systemctl --user daemon-reload
    systemctl --user restart sommelier-x@0.service

    echo -e "\nPlease restart the Linux instance to finish..."
