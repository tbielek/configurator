#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
cd "$SCRIPT_DIR"

repo_url="https://boweevil@bitbucket.org/boweevil/xresources.git"
install_path="../../../repos/xresources"

if [ ! -d "${install_path}" ]; then
  git clone "${repo_url}" "${install_path}"
  cd "${install_path}"
  git submodule update --init --recursive
else
  cd "${install_path}"
fi
./install.sh
