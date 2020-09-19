#!bin/bash

# Script will print drectory tree structure
# Optional output:
# 	1) size of each directory
#	2) print only directories


# function to display usage of script
function display_usage()
{
	echo ''
	echo "Script ${0} is used to display directory tree"
	echo "${0} [-sd] PATH_NAME"
	echo '	-s	Display size of each directory.'
	echo '	-d	Print only directories.' 
	exit 1
}

# parse the arguments
while getopts sd OPTION
do
        case ${OPTION} in
                s)      DISPLAY_SIZE='true'     ;;
                d)      DIRECTORIES='true'      ;;
                ?)      display_usage           ;;
        esac
done

# make sure user provide at least one argument
shift "$(( OPTIND - 1))"
if [[ "${#}" -lt 1 ]]
then
        display_usage
fi

# make sure last argument is directory
if [[ ! -d "${1}" ]]
then
	display_usage
fi



# function to display a file
function display_file()
{
	# first argument is path, second is indentation, third depth
	local FILE_NAME="${1}"
	local INDENT="${2}"

	# remove path to file, leave only a file name
	FILE_NAME=`echo "${FILE_NAME}" | cut -d '/' -f "${DEPTH}"`
	echo "${INDENT}├──${FILE_NAME}"
}

# recursive function to display directory
function recursive_tree()
{
	for ITEM in ${1}/*
	do
		# calculate depth
		DEPTH=$(("${3}" +1 ))

		# check if item is a file or directory
		# if directory display it and call recursive tree
		if [[ -d "${ITEM}" ]] 
		then
			display_file "${ITEM}" "${2}" "${DEPTH}"
			
			# display size of directory if it was requested
			if [[ "${DISPLAY_SIZE}" = 'true' ]]
			then
				echo "${2}└──Size: $(du -ch "${ITEM}" | grep total | cut -d 't' -f 1)"

			fi

			# call recursive tree
			recursive_tree "${ITEM}" "${2}│  " "${DEPTH}"

		else
			# display only directories if it was requested
			if [[ ! "${DIRECTORIES}" = 'true' ]]
			then
				display_file "${ITEM}"  "${2}" "${DEPTH}"
		 	fi
		fi	
	done
}

# listing all elements in main directory
echo "${1}"
recursive_tree "${1}" "   " "1"
