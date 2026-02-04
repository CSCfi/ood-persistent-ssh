#!/bin/bash
set -x

# TODO: handle all lustrep
install_dir="/pfs/lustrep1/appl/local/ood/$1/soft/tmux"

WRK=$(mktemp -d)

cd "$WRK"

curl -L -O https://github.com/tmux/tmux/releases/download/3.6a/tmux-3.6a.tar.gz
tar -xvf tmux-3.6a.tar.gz

curl -L -O https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
tar -xvf libevent-2.1.12-stable.tar.gz

cd libevent-2.1.12-stable

./configure --prefix="$WRK/libevent" --enable-shared
make -j && make install

cd
cd tmux-3.6a
PKG_CONFIG_PATH="$WRK/libevent/lib/pkgconfig" ./configure --prefix="$install_dir"
make -j && make install

cp time_helper.sh "$install_dir/time_helper.sh"
chmod +x "$install_dir/time_helper.sh"

