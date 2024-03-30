#!/usr/bin/bash -i

if [ "$(id -u)" -eq 0 ]; then
    echo "cannot run as root" >&2
    exit 1
fi

[ ! -d "$HOME/.local/include" ] && mkdir -p "$HOME/.local/include"
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"
[ ! -d "$HOME/.cache/quickrun" ] && mkdir -p "$HOME/.cache/quickrun"
cat ./bashrc >> $HOME/.bashrc
source $HOME/.bashrc

sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential cmake curl git gnome-tweaks fd-find ripgrep wl-clipboard tree-sitter-cli linux-headers-$(uname -r) gettext libfuse2 gnome-browser-connector tree
sudo apt remove -y nautilus-extension-gnome-terminal 
sudo apt install -y ibus-pinyin vlc webp flameshot solaar

# slack
# discord
# https://discord.com/download
# sudo dpkg -i discord.deb

# vmware
# https://www.vmware.com/products/workstation-pro/workstation-pro-evaluation.html
# chmod +x VMware-Workstation-Full-17.5.0-17198959.x86_64.bundle
# sudo ./VMware-Workstation-Full-17.5.0-17198959.x86_64.bundle

# nvidia drivers
# sudo apt-get remove --purge nvidia-*
# sudo apt-get remove '^nvidia'
# sudo apt autoremove
# sudo reboot

# sudo apt update && sudo apt upgrade -y
# sudo add-apt-repository ppa:graphics-drivers/ppa -y
# sudo apt update
# sudo apt install nvidia-driver-550 -y
# sudo apt install libnvidia-egl-wayland1
# sudo reboot

# pano
# https://extensions.gnome.org/extension/5278/pano/

. ./asdf/install.sh
. ./nautilus-terminal/install.sh
. ./kitty/install.sh
. ./cpplibs/install.sh
. ./bin/install.sh
. ./nvim/install.sh
. ./1password/install.sh
. ./utils/install.sh
. ./spotify/install.sh
. ./docker/install.sh
. ./sublime/install.sh
. ./discord/install.sh
. ./onlyoffice/install.sh
. ./slack/install.sh
. ./update/install.sh
. ./todoist/install.sh
. ./postman/install.sh
. ./flameshot/install.sh
