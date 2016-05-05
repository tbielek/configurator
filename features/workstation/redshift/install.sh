#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
cd "$SCRIPT_DIR"

install_path="../../../repos/redshift"

git clone git@bitbucket.org:boweevil/redshift.git "${install_path}"
cd "${install_path}"
git submodule update --init --recursive
./install.sh
