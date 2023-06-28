#!/bin/bash
set -x

# TODO: handle all lustrep
install_dir="/pfs/lustrep3/appl/local/ood/$1/soft/tmux"

mkdir -p "$install_dir/bin"

cp "$(which tmux)" "$install_dir/bin/tmux"
cp time_helper.sh "$install_dir/time_helper.sh"
chmod +x "$install_dir/time_helper.sh"

