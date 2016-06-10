#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
cd "$SCRIPT_DIR"

install_path="../../../repos/pkgs_gui"

git clone git@bitbucket.org:boweevil/pkgs_gui.git "${install_path}"
cd "${install_path}"
git submodule update --init --recursive
./install.sh
