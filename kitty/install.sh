SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
sudo ln -s $HOME/.local/kitty.app/bin/kitty /usr/bin/kitty
sudo ln -s $HOME/.local/kitty.app/bin/kitten /usr/bin/kitten
sudo cp $HOME/.local/kitty.app/share/applications/kitty.desktop /usr/share/applications/
sudo cp $HOME/.local/kitty.app/share/applications/kitty-open.desktop /usr/share/applications/
sudo sed -i "s|Icon=kitty|Icon=org.gnome.Terminal|g" /usr/share/applications/kitty*.desktop
sudo sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" /usr/share/applications/kitty*.desktop

sudo cp $SCRIPT_DIR/fonts/* /usr/local/share/fonts/
sudo fc-cache -f -v

sudo rm -rf $HOME/.config/kitty
sudo cp -r $SCRIPT_DIR/config $HOME/.config/kitty
sudo chown -R $USER:$USER $HOME/.config/kitty

sed -i '/xterm-color|.*-256color/s/)/|xterm-kitty)/' $HOME/.bashrc
cat $SCRIPT_DIR/bash_integration >> $HOME/.bashrc

sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50
sudo update-alternatives --config x-terminal-emulator
