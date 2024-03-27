#!/usr/bin/bash

sudo apt install -y python3-pynvim
npm install -g neovim
gem install neovim
cpanm -n App::cpanminus
cpanm -n Neovim::Ext

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
rm -rf $HOME/.local/neovim.app
rm -rf $HOME/.local/nvim-linux64
tar -C $HOME/.local -xzf nvim-linux64.tar.gz
mv $HOME/.local/nvim-linux64 $HOME/.local/neovim.app
rm -f nvim-linux64.tar.gz

sudo ln -s $HOME/.local/neovim.app/bin/nvim /usr/bin/vim

sudo rm -rf $HOME/.config/nvim
sudo cp -r $SCRIPT_DIR/config $HOME/.config/nvim
sudo chown -R $USER:$USER $HOME/.config/nvim
