rm -rf $HOME/.local/nautilus-terminal
git clone https://github.com/Stunkymonkey/nautilus-open-any-terminal.git $HOME/.local/nautilus-terminal
cd $HOME/.local/nautilus-terminal
make
sudo make install-nautilus schema
gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal kitty
nautilus -q
