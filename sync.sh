rm -rf alacritty
rm -rf nvim
rm -rf bin
sudo cp -r /home/jyh/.config/nvim ./
sudo cp -r /home/jyh/.config/alacritty ./
mkdir bin
sudo cp -r /usr/bin/quickrun ./bin/
sudo cp -r /usr/bin/codemd5 ./bin/
sudo cp -r /usr/bin/backup ./bin/
