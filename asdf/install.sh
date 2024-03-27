rf -rf $HOME/.local/asdf.app
git clone https://github.com/asdf-vm/asdf.git $HOME/.local/asdf.app --branch v0.14.0
echo ". \"$HOME/.local/asdf.app/asdf.sh\"" >> $HOME/.bashrc
echo ". \"$HOME/.local/asdf.app/completions/asdf.bash\"" >> $HOME/.bashrc

sudo apt install dirmngr gpg curl gawk
asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
asdf install nodejs latest
asdf global nodejs latest

sudo apt install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev
asdf plugin add ruby https://github.com/asdf-vm/asdf-ruby.git
asdf install ruby latest
asdf global ruby latest

sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev curl libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
asdf plugin add python
asdf install python 3.12.2
asdf global python 3.12.2

asdf plugin-add lua https://github.com/Stratus3D/asdf-lua.git
asdf install lua latest
asdf global lua latest

asdf plugin add perl
asdf install perl latest
asdf global perl latest

