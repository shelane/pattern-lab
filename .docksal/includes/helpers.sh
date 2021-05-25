#!/usr/bin/env bash

#-------------------------- Helper functions --------------------------------

source "${PROJECT_ROOT}/.docksal/includes/colors.sh"

# Check whether shell is interactive (otherwise we are running in a non-interactive script environment)
is_tty ()
{
	[[ "$(/usr/bin/tty || true)" != "not a tty" ]]
}

is_windows ()
{
	local res=$(uname | grep 'CYGWIN_NT')
	if [[ "$res" != "" ]]; then
		return 0
	else
		return 1
	fi
}

# Yes/no confirmation dialog with an optional message
# @param $1 confirmation message
_confirm ()
{
	# Skip checks if not a tty
	if ! is_tty ; then return 0; fi

	while true; do
		read -p "$1 [y/n]: " answer
		case $answer in
			[Yy]|[Yy][Ee][Ss] )
				break
				;;
			[Nn]|[Nn][Oo] )
				exit 1
				;;
			* )
				echo 'Please answer yes or no.'
		esac
	done
}

# Copy a settings file.
# Skips if the destination file already exists.
# @param $1 source file
# @param $2 destination file
copy_settings_file()
{
	local source="$1"
	local dest="$2"

	if [[ (-f $dest) || (-d $dest) ]]; then
		echo-yellow "${dest} already in place."
	elif [[ -d $source ]]; then
		echo "Copying to ${dest}..."
		cp -r $source $dest
    else
        echo "Copying to ${dest}..."
		cp $source $dest
	fi
}

# Fix file/folder permissions
fix_permissions ()
{
    if [[ "${1}" != "" ]]; then
        echo "Making site directory writable..."
        chmod 755 "${1}"
	fi
}

# Set the start time.
START_TIME=`date +%s`

# Calculate and display the total time.
function displayTime {

  if [ "${2}" != "" ] ; then
    CUR_START=${2}
  else
    CUR_START=${START_TIME}
  fi

  local END_TIME=`date +%s`
  local T=$((${END_TIME}-${CUR_START}))
  local MESSAGE="${1} completed in"
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  local endtime=`date +%T`

  printf "${green}\n"
  echo "-------------------------------------------------------------------"
  printf "| ${MESSAGE} "
  (( ${D} > 0 )) && printf '%d days ' ${D}
  (( ${H} > 0 )) && printf '%d hours ' ${H}
  (( ${M} > 0 )) && printf '%d minutes ' ${M}
  (( ${D} > 0 || ${H} > 0 || ${M} > 0 )) && printf 'and '
  printf "%d seconds!\n" ${S}
  echo "| Complete at ${endtime}"
  echo "-------------------------------------------------------------------"
  printf "${NC}\n"
}

#-------------------------- END: Helper functions --------------------------------