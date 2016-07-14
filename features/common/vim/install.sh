#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
cd "$SCRIPT_DIR"

repo_url="https://boweevil@bitbucket.org/boweevil/vim.git"
install_path="../../../repos/vim"

git clone "${repo_url}" "${install_path}"
cd "${install_path}"
git submodule update --init --recursive
./install.sh
