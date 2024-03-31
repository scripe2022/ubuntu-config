#!/usr/bin/bash -i

if [ "$(id -u)" -eq 0 ]; then
    echo "cannot run as root" >&2
    exit 1
fi

[ ! -d "$HOME/.local/include" ] && mkdir -p "$HOME/.local/include"
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"
[ ! -d "$HOME/.cache/quickrun" ] && mkdir -p "$HOME/.cache/quickrun"
sudo chown -R $USER:$USER $HOME/.local
sudo chown -R $USER:$USER $HOME/.cache
cat ./bashrc >> $HOME/.bashrc
source $HOME/.bashrc

sudo apt update
sudo apt upgrade -y
sudo apt install -y build-essential cmake curl git gnome-tweaks fd-find ripgrep wl-clipboard tree-sitter-cli linux-headers-$(uname -r) gettext libfuse2 gnome-browser-connector tree libnvidia-egl-wayland1 gir1.2-gtk-4.0 python3-nautilus gir1.2-gda-5.0 gir1.2-gsound-1.0 xclip nfs-kernel-server
sudo apt install -y ibus-pinyin vlc webp flameshot solaar
sudo apt remove nautilus-extension-gnome-terminal

. ./asdf/install.sh
. ./kitty/install.sh
. ./nautilus-terminal/install.sh
. ./cpplibs/install.sh
. ./bin/install.sh
. ./nvim/install.sh
. ./nvidia/install.sh
. ./1password/install.sh
. ./utils/install.sh
. ./spotify/install.sh
. ./sublime/install.sh
. ./discord/install.sh
. ./onlyoffice/install.sh
. ./slack/install.sh
. ./upnote/install.sh
. ./todoist/install.sh
. ./postman/install.sh
. ./docker/install.sh


