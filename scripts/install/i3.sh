#!/bin/bash

cd $HOME/.dotfiles/external/i3-gaps
autoreconf --force --install

mkdir -p /tmp/i3-gaps-build
cd /tmp/i3-gaps-build
$HOME/.dotfiles/external/i3-gaps/configure --prefix=/usr --sysconfdir=/etc

make
make install

mkdir -p $HOME/.config/i3
ln -sf $HOME/.dotfiles/config/i3/config $HOME/.config/i3/config