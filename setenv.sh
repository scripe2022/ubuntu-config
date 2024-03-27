#!/usr/bin/bash

[ ! -d "$HOME/.local/include" ] && mkdir -p "$HOME/.local/include"
[ ! -d "$HOME/.local/bin" ] && mkdir -p "$HOME/.local/bin"
cat ./bashrc >> $HOME/.bashrc
