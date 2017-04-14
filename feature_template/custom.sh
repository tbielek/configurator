#!/bin/bash

# the following are the additions steps needed by my vim configuration.  this custom.sh script should be used to execute
# additional steps other than the linking of configuration files.
#plugins_dir="${SCRIPT_DIR}/bundle"
#
#if [ ! -d "${plugins_dir}" ]; then
#  mkdir "${plugins_dir}"
#fi
#
#if [ ! -d "${plugins_dir}/Vundle.vim" ]; then
#  cd "${plugins_dir}" \
#    && git clone https://github.com/VundleVim/Vundle.vim.git
#
#  cd "${SCRIPT_DIR}"
#fi
#
#vim +PluginInstall +qall

echo "Finished running custom.sh for ${SCRIPT_DIR}."
