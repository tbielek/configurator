#!/bin/bash
# -----------------------------------------------------------------------------
# Title: Configurator
# Author: Jason Carpenter (boweevil)
# Email: argonaut.linux@gmail.com
# Description: A script for installing configuration files for various tools and
# utilities. Each feature will require an install.sh script to deploy it.
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
export SCRIPT_DIR
SCRIPT_NAME="$( basename "$0" )"
SCRIPT_VERSION='1.0.0'

todo=''
features_file="${SCRIPT_DIR}/features.txt"
configurator_dir="$HOME/.configurator"
installed_features="${configurator_dir}/installed_features.txt"


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


version ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  version
  #   DESCRIPTION:  Print the script version and exit.
  #    PARAMETERS:  None
  #       RETURNS:  Version number.
  #-------------------------------------------------------------------------------
  echo "${SCRIPT_NAME}, version: ${SCRIPT_VERSION}"
  echo
}

usage ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  usage
  #   DESCRIPTION:  Print a help message.
  #    PARAMETERS:  None
  #       RETURNS:  Usage information.
  #-------------------------------------------------------------------------------
  version
  echo "Usage: ${SCRIPT_NAME} [ARGUMENTS]..."
  echo
  echo "The following arguments are available."
  echo "  -h, --help        Print this help and exit."
  echo "  -v, --version     Print the version and exit."
  echo "  -i, --install     Install features from ${features_file}."
  echo "                    Cannot be used with -u."
  echo "  -u, --update      Update all repositories."
  echo "                    Cannot be used with -i."
  echo
  echo "Examples:"
  echo "${SCRIPT_NAME} -h"
  echo
  echo "${SCRIPT_NAME} -v"
  echo
  echo "${SCRIPT_NAME} -i"
  echo
  echo "${SCRIPT_NAME} -u"
  echo
  if [ -e "${features_file}" ]; then
    echo "The following features are configured to be installed."
    cat "${features_file}"
  else
    echo "No features are currently available to install.  See README.md."
  fi
}

separator ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  separator
  #   DESCRIPTION:  Print the character "-" to column 80.
  #    PARAMETERS:  None
  #       RETURNS:  A separator.
  #-------------------------------------------------------------------------------
  s=$(printf "%-80s" "-")
  echo "${s// /-}"
}

installFeatures ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  installFeatures
  #   DESCRIPTION:  Installed the features in ${features_file}.
  #    PARAMETERS:  None
  #       RETURNS:  None
  #-------------------------------------------------------------------------------
  for feature in ${features[*]}; do
    echo "Cloning ${feature}."
    git clone "${feature}"
    # Get the directory name from the feature URL.  This should work for
    # http, https, or git URLs.
    feature_dir="$(sed 's/^.*\///g' <<< "${feature}" | cut -f 1 -d '.')"
    cd "${feature_dir}" \
    	|| except "$LINENO"  "Unable to change directory to ${feature_dir}." 71
    if [ ! -e 'install.sh' ]; then
      except "$LINENO" "Unable to find install script for ${feature}." 72
    fi
    bash ./install.sh \
      || except "$LINENO" "Install failed for ${feature}." 1
    cd "${configurator_dir}" \
      || except "$LINENO" "Unable to change directory to ${configurator_dir}." 71
    markInstalled "${feature_dir}"
    echo "Finished installing ${feature}."
  done
}

markInstalled ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  markInstalled
  #   DESCRIPTION:  Add an entry to ${installed_features}.  Requires a feature
  #                 as an argument.  The feature will undergo some validation
  #                 before being marked as installed.
  #    PARAMETERS:  "${feature_dir}"
  #       RETURNS:  None
  #-------------------------------------------------------------------------------
  if [ -z "$1" ]; then
    except "$LINENO" "Invalid argument $1." 60
  fi
  if [ ! -d "$1" ]; then
    except "$LINENO" "Directory, $1 not found." 72
  fi
  if grep "^$1$" "${installed_features}"; then
    except "$LINENO" "$1 already exists in ${installed_features}." 1
  fi
  echo "$1" >> "${installed_features}" \
    || except "$LINENO" "Unable to write to ${installed_features}." 1
}

pullUpdates ()
{
  #---  FUNCTION  ----------------------------------------------------------------
  #          NAME:  pullUpdates
  #   DESCRIPTION:  Parse installed features and pull updates for each of them,
  #                 then run the install script for each.
  #    PARAMETERS:  None
  #       RETURNS:  None
  #-------------------------------------------------------------------------------
  # Update all installed features.
  for installed_feature in ${features[*]}; do
    separator
    cd "${configurator_dir}/${installed_feature}" \
      || except "$LINENO" "Unable to change directory to ${installed_feature}." 71
    echo "Updating ${installed_feature}..."
    git fetch --all
    git pull
    git submodule update --init --recursive
    bash ./install.sh
    echo "Finished updating ${installed_feature}."
  done
}


# MAIN ########################################################################
if [ ! -e "${features_file}" ]; then
  except "$LINENO" "Please, create ${features_file}. Use features_example.txt as a reference." 1
fi

if [ ! -d "${configurator_dir}" ]; then
  mkdir "${configurator_dir}"
fi

cd "${configurator_dir}" \
  || except "$LINENO" "Unable to change directory to ${configurator_dir}." 71

if [ -z "$1" ]; then
  except "$LINENO" "Invalid argument $1." 60
fi

while [ -n "$1" ]; do
  case "$1" in
    '-h' | '--help' )
      usage
      exit 0
      ;;
    '-v' | '--version' )
      version
      exit 0
      ;;
    '-i' | '--install' )
      if [ -n "${todo}" ]; then
        echo "Install and update are mutually exclusive arguments."
        except "$LINENO" "Invalid argument $1." 60
      fi
      readarray features < "${features_file}"
      todo='install'
      ;;
    '-u' | '--update' )
      if [ -n "${todo}" ]; then
        echo "Install and update are mutually exclusive arguments."
        except "$LINENO" "Invalid argument $1." 60
      fi
      readarray features < "${installed_features}"
      todo='update'
      ;;
    * )
      except "$LINENO" "Invalid argument $1." 60
      ;;
  esac
  shift
done

if [ "${todo}" = 'install' ] ; then
  installFeatures
elif [ "${todo}" = 'update' ] ; then
  pullUpdates
fi

exit 0
