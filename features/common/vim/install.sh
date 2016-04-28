#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
cd "$SCRIPT_DIR"

install_path="../../../repos/vim"

git clone git@bitbucket.org:boweevil/vim.git "${install_path}"
cd "${install_path}"
git submodule update --init --recursive
./install.sh