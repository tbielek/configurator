#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
cd "$SCRIPT_DIR"

repo_url="https://boweevil@bitbucket.org/boweevil/pkgs_gui.git"
install_path="../../../repos/pkgs_gui"

if [ ! -d "${install_path}" ]; then
  git clone "${repo_url}" "${install_path}"
  cd "${install_path}"
  git submodule update --init --recursive
else
  cd "${install_path}"
fi
./install.sh
