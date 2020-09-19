#!/bin/bash
#
# The script disable or delete users on the local system.
# Account can be deleted with archive home folder 

# default path to archive folder
ARCHIVE_DIR='/archive'

# function to display usage of the script
function display_usage()
{
	echo "Usage: ${0} [-dra] USER [USERS]..." >&2
	echo 'Disable a local account.' >&2
	echo '	-d 	Deletes accounts instead of disabling them.' >&2
	echo '	-r	Removes the home directory associated with account' >&2
	echo '	-a 	Creaets an archive of home directory associated with account' >&2
	exit 1
}

# make sure the script is running as root
if [[ "${UID}" -ne 0 ]]
then
	echo 'Please run with sudo or as root.' >&2
	exit 1
fi

# parse arguments from command line
while getopts dra OPTION
do
	case ${OPTION} in
		d) DELETE_USER='true' 	;;
		r) REMOVE_OPTION='-r' 	;;
		a) ARCHIVE='true' 		;;
		?) display_usage		;;
	esac
done

# remove options while leaving the remaining arguments
shift "$(( OPTIND - 1 ))"

# and help if user does not provide at least one argument
if [[ "${#}" -lt 1 ]]
then 
	display_usage
fi

# Loop through all usernames supplied as arguments
for USER_NAME in "${@}"
do
	# make sure the user is not a system account
	USER_ID=$(id -u ${USER_NAME})
	if [[ "${USER_ID}" -lt 1000 ]]
	then
		echo "Refusing to remove the ${USER_NAME} account with UID ${USER_ID}." >&2
		exit 1
	fi
	
	# create archive if requested to do
	if [[ "${ARCHIVE}" = 'true' ]]
	then
		# if ARCHIVE_DIR directory dont exist, create it 
		if [[ ! -d "${ARCHIVE_DIR}" ]]
		then
			mkdir -p ${ARCHIVE_DIR}
			# check if creating was successful
			if [[ "${?}" -ne 0 ]]
			then
				echo "The archive directory ${ARCHIVE_DIR} could not be created." >&2
				exit 1
			fi
		fi
		
		# archive user's home directory and move to ARCHIVE_DIR
		HOME_DIR="/home/${USERNAME}"
		ARCHIVE_FILE="${ARCHIVE_DIR}/${USER_NAME}.tgz"
		
		# check if home is a directory 
		if [[ -d "${HOME_DIR}"]]
		then
			tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
			
			# make sure archiving was successful
			if [[ "${?}" -ne 0 ]]
			then
				echo "Could not create ${ARCHIVE_FILE}." >&2
				exit 1
			fi
		else
			echo "${HOME_DIR} does not exist or is not a directory." >&2
			exit 1
		fi
	fi
	
	# delete or disable user 
	if [[ "${DELETE_USER}" = 'true' ]]
	then
		# delete the user
		userdel ${REMOVE_OPTION} ${USER_NAME}
		
		# make sure userdel command was successful
		if [[ "${?}" -ne 0 ]]
		then
			echo "Could not delete account ${USER_NAME}." >&2
			exit 1
		fi
	else
		# disable the user
		chage -E 0 ${USER_NAME}
		
		# make sure chage command was successful
		if [[ "${?}" -ne 0 ]]
		then
			echo "Could not disable account ${USER_NAME}." >&2
			exit 1
		fi
	fi
done
exit 0
