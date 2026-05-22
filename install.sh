#!/bin/bash

set -xeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

WRK=$(mktemp -d)
cd "$WRK"

curl -L -O https://github.com/tmux/tmux/releases/download/3.6b/tmux-3.6b.tar.gz
tar -xvf tmux-3.6b.tar.gz

cd tmux-3.6b
./configure --prefix="$SCRIPT_DIR"
make -j && make install

