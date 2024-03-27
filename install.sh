#!/usr/bin/bash

if [ "$(id -u)" -eq 0 ]; then
    echo "cannot run as root" >&2
    exit 1
fi

sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential cmake curl git gnome-tweaks fd-find ripgrep wl-clipboard tree-sitter-cli linux-headers-$(uname -r) gettext libfuse2 gnome-browser-connector
sudo apt remove -y nautilus-extension-gnome-terminal 
sudo apt install -y ibus-pinyin vlc webp

# spotify
# https://www.spotify.com/de-en/download/linux/

# lazygit
# https://github.com/jesseduffield/lazygit?tab=readme-ov-file#ubuntu

# sublime-text
# https://www.sublimetext.com/docs/linux_repositories.html#apt

# discord
# https://discord.com/download
# sudo dpkg -i discord.deb

# vmware
# https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html
# chmod +x VMware-Workstation-Full-17.5.0-17198959.x86_64.bundle
# sudo ./VMware-Workstation-Full-17.5.0-17198959.x86_64.bundle

./asdf/install.sh
./nautilus-terminal/install.sh
./nvim/install.sh
./kitty/install.sh
./cpplibs/install.sh
./bin/install.sh
