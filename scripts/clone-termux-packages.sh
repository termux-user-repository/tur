#!/usr/bin/env bash
set -e

repo_root=$1
cd $repo_root
## It will clone termux-packages then ./packages  as termux-packages/packages
test ! -d termux-packages && git clone --depth=1 https://github.com/termux/termux-packages
test ! -L packages && ln -s ./termux-packages/packages && echo "termux-packages/packages link with ./packages successfully"

test ! -L x11-packages && ln -s ./termux-packages/x11-packages && echo "termux-packages/packages link with ./x11-packages successfully"
test ! -L root-packages && ln -s ./termux-packages/root-packages && echo "termux-packages/packages link with ./root-packages successfully"
