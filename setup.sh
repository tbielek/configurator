#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )

common_path="${SCRIPT_DIR}/features/common"
workstation_path="${SCRIPT_DIR}/features/workstation"
common_scripts=($(ls "${common_path}"))
workstation_scripts=($(ls "${workstation_path}"))

exception(){
  echo -n "Error: "
  echo "$@"
  exit 1
}

features_common(){
  for feature in "${common_scripts[@]}"; do
    echo "running ${common_path}/${feature}/install.sh"
    "${common_path}/${feature}/install.sh"
  done
  unset feature
  echo
}

features_workstation(){
  for feature in "${workstation_scripts[@]}"; do
    echo "running ${workstation_path}/${feature}/install.sh"
    "${workstation_path}/${feature}/install.sh"
  done
  unset feature
  echo
}

pull_updates(){
  echo "Updating configurator"
  git pull
  git submodule update --init --recursive
  echo "Done updating configurator"
  cd "${SCRIPT_DIR}/repos" || exception "Unable to change directory to $SCRIPT_DIR."
  for i in *; do
    echo ----------------------------------------------------------------------
    echo "Updating ${i}..."
    cd "${i}" || exception "Unable to change directory to ${i}."
    git fetch --all
    git pull
    git submodule update --init --recursive
    ./install.sh
    echo "Done updating ${i}"
    cd - || exception "Unable to return to previous directory."
  done
  cd "${SCRIPT_DIR}/repos" || exception "Unable to change directory to $SCRIPT_DIR."
  echo
}

usage(){
  echo ""
  echo "Usage: $0 [[-c] | [-w] | [-u] | [-h]]"
  echo ""
  echo "  -c, --common        Install common features."
  echo ""
  echo "  -w, --workstation   Install common and workstation features."
  echo ""
  echo "  -u, --update        Update all repositories."
  echo ""
  echo "  -h, --help          Print this help."
  echo ""
  echo "Common features: ${common_scripts[*]}"
  echo ""
  echo "Workstation features: ${workstation_scripts[*]}"
}

#==== MAIN =====================================================================
cd "$SCRIPT_DIR" || exception "Unable to change directory to $SCRIPT_DIR."
if [ ! -d "${SCRIPT_DIR}/repos" ]; then
  mkdir "${SCRIPT_DIR}/repos"
fi

if [ "${1}" = "" ]; then
  features_common
  features_workstation
  exit 0
else
  while [ "${1}" != "" ]; do
    case "${1}" in
      -c | --common )
        features_common
        exit 0
        ;;
      -w | --workstation )
        features_common
        features_workstation
        exit 0
        ;;
      -u | --update )
        pull_updates
        exit 0
        ;;
      -h | --help )
        usage
        exit 0
        ;;
      * )
        echo "Invalid argument."
        usage
        exit 1
    esac
    shift
  done
fi
