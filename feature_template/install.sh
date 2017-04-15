#!/bin/bash
# -----------------------------------------------------------------------------
# Title:        install.sh
# Author:       Jason Carpenter (boweevil)
# Email:        argonaut.linux@gmail.com
# Description:  Script for installing or uninstalling configurator features.
#   This script should be placed in the root of the feature which is to be
#   installed.  The script can be called directly or by configurator.
# -----------------------------------------------------------------------------

# options ---------------------------------------------------------------------
# debug
#set -x

# exit on command errors
set -e

# capture fail exit codes in piped commands
set -o pipefail


# defaults --------------------------------------------------------------------
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}"  )" && pwd  )

declare -A configs

config_files="${SCRIPT_DIR}/config_files.sh"
custom_script="${SCRIPT_DIR}/custom.sh"

todo='install'

# functions -------------------------------------------------------------------
except ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  except
  #   DESCRIPTION:  Print an error message and return and error.
  #    PARAMETERS:  ${LINENO} "message" [EXIT CODE]
  #       RETURNS:  Line number, message, and exit code.
  #-------------------------------------------------------------------------------
  local parent_lineno="Error on or near line $1"
  local message="$2"
  local code="exiting with status ${3:-1}"
  if [[ -n "$message" ]]; then
    echo "${parent_lineno}: ${message}; ${code}"
  else
    echo "${parent_lineno}; ${code}"
  fi
  return "${code}"
}	# ----------  end of function except "$LINENO"  ----------
trap 'except "$LINENO" ${LINENO}' ERR

usage ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  usage
  #   DESCRIPTION:  Print a help message.
  #    PARAMETERS:  None
  #       RETURNS:  Usage information.
  #-------------------------------------------------------------------------------
  echo "Usage: ${SCRIPT_NAME} [ARGUMENTS]..."
  echo
  echo "Run ${SCRIPT_NAME} without any arguments to install the feature."
  echo "The following arguments are available."
  echo "  -h, --help        Print this help and exit."
  echo "  -u, --uninstall   Uninstall the configuration for this feature."
  echo
  echo "Examples:"
  echo "${SCRIPT_NAME} -h"
  echo
  echo "${SCRIPT_NAME} -u"
  echo
}

linker ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  linker
  #   DESCRIPTION:  Create links to configuration files.
  #    PARAMETERS:  --link [LINK_PATH] --target [TARGET_PATH]
  #       RETURNS:  NONE
  #-------------------------------------------------------------------------------
  if [ -z "$1" ]; then
    except "$LINENO" "Invalid argument in function $0." 1
  fi

  while [ -n "$1" ]; do
    case "$1" in
      '--link' )
        shift
        local link_path="$1"
        ;;
      '--target' )
        shift
        local target_path="$1"
        ;;
    esac
    shift
  done

  # If $link_path is a link, remove it.
  if [ -h "$link_path" ]; then
    echo "$link_path is an existing link to $(readlink "$link_path")."
    rm -f "$link_path"
  fi

  # If $link_path is a real file, back it up.
  if [ -f "$link_path" ]; then
    echo "$link_path is an existing file.  Backing it up to $link_path.$(date +%Y%m%d)."
    mv "$link_path" "$link_path.$(date +%Y%m%d)"
  fi

  # If $link_path is a real file, back it up.
  if [ -d "$link_path" ]; then
    echo "$link_path is an existing directory.  Backing it up to $link_path.$(date +%Y%m%d)."
    mv "$link_path" "$link_path.$(date +%Y%m%d)"
  fi

  # If $link_path still exists, exit.
  if [ -e "$link_path" ]; then
    except "$LINENO" "Unable to handle existing files at $link_path." 1
  fi

  ln -s "$target_path" "$link_path"
}	# ----------  end of function linker  ----------

unlinker ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  unlinker
  #   DESCRIPTION:  Remove links to configuration files.
  #    PARAMETERS:  --link [LINK_PATH] --target [TARGET_PATH]
  #       RETURNS:  NONE
  #-------------------------------------------------------------------------------
  if [ -z "$1" ]; then
    except "$LINENO" "Invalid argument in function $0." 1
  fi

  while [ -n "$1" ]; do
    case "$1" in
      '--link' )
        shift
        local link_path="$1"
        ;;
      '--target' )
        shift
        local target_path="$1"
        ;;
    esac
    shift
  done

  # remove the link for the feature.
  if [ "$(readlink "$link_path")" == "$target_path" ]; then
    rm -f "$link_path"
  fi

  # If $link_path still exists, exit.
  if [ -e "$link_path" ]; then
    except "$LINENO" "Unable to handle existing files at $link_path." 1
  fi
}	# ----------  end of function unlinker  ----------

install ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  install
  #   DESCRIPTION:  Install the feature
  #    PARAMETERS:  NONE
  #       RETURNS:  NONE
  #-------------------------------------------------------------------------------
  # Install all required packages for the feature.
  packages

  # link all the configs
  if [ -e "${config_files}" ]; then
    # shellcheck source=./config_files.sh
    source "${config_files}"
    if [ "${#configs[@]}" != 0 ]; then
      for config in "${!configs[@]}"; do
          linker --target "${config}" --link "${configs[$config]}"
          echo -n "Installed "
          readlink "${configs[$config]}"
      done
    fi
  fi

  # do any custom task for the feature.  for instance running vundle for vim.
  if [ -e "${custom_script}" ]; then
    # shellcheck source=./custom.sh
    source "${custom_script}"
  fi
}	# ----------  end of function install  ----------

uninstall ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  uninstall
  #   DESCRIPTION:  Uninstall the feature
  #    PARAMETERS:  NONE
  #       RETURNS:  NONE
  #-------------------------------------------------------------------------------
  # link all the configs
  if [ -e "${config_files}" ]; then
    # shellcheck source=./config_files.sh
    source "${config_files}"
    if [ "${#configs[@]}" != 0 ]; then
      for config in "${!configs[@]}"; do
          unlinker --target "${config}" --link "${configs[$config]}"
          echo "Removed link to ${config}."
      done
    fi
  fi
}	# ----------  end of function uninstall  ----------

packages ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  packages
  #   DESCRIPTION:  Install packages with installPkg
  #    PARAMETERS:  NONE
  #       RETURNS:  NONE
  #-------------------------------------------------------------------------------
  if [[ -n "${CONFIGURATOR}" ]]; then
    "${CONFIGURATOR}/installpkg/installPkg.sh" -c "${SCRIPT_DIR}/packages"
  else
    git clone https://boweevil::@github.com/boweevil/installpkg.git "${SCRIPT_DIR}/installpkg"
    "${SCRIPT_DIR}/installpkg/installPkg.sh" -c "${SCRIPT_DIR}/packages"
  fi
}


# main ------------------------------------------------------------------------
while [ -n "$1" ]; do
  case "$1" in
    '-h' | '--help' )
      usage
      exit 0
      ;;
    '-u' | '--uninstall' )
      todo='uninstall'
      ;;
    * )
      except "$LINENO" "Invalid argument $1." 60
      ;;
  esac
  shift
done

if [ "${todo}" = 'install' ]; then
  install
else
  uninstall
fi

exit 0
