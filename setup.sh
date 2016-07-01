#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )
cd "$SCRIPT_DIR"

common_path="${SCRIPT_DIR}/features/common"
workstation_path="${SCRIPT_DIR}/features/workstation"
common_scripts=($(ls "${common_path}"))
workstation_scripts=($(ls "${workstation_path}"))

features_common(){
  for feature in "${common_scripts[@]}"; do
    echo "running ${common_path}/${feature}/install.sh"
    "${common_path}/${feature}/install.sh"
  done
  unset feature
}

features_workstation(){
  for feature in "${workstation_scripts[@]}"; do
    echo "running ${workstation_path}/${feature}/install.sh"
    "${workstation_path}/${feature}/install.sh"
  done
  unset feature
}

pull_updates(){
  git pull
  git submodule update --init --recursive
  cd "${SCRIPT_DIR}/repos"
  for i in $(ls); do
    echo ----------------------------------------------------------------------
    echo "Updating ${i}..."
    cd "${i}"
    git pull
    git submodule update --init --recursive
    echo "Done updating ${i}"
    cd -
  done
  cd "${SCRIPT_DIR}"
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
