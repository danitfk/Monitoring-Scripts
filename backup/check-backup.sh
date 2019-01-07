#!/bin/bash
# Author: Daniel Gordi (danitfk)
# Date: 24/Dec/2018
#
#
export BACKUP_DIR="/path/to/NFS"
export DB_BACKUP_DIR="/path/to/NFS/DB"

function help {
echo "Usage: ./check_backup [check_access|check_db_backup_size|check_backup_health]"
echo "                       check_access -> Check access to the BACKUP_DIR to findout NFS connectivity issues (Response: 0 FAILED, 1 OK)"
echo "                       check_db_backup_size -> Check current and previous backup size (Response: Size in MB)"
echo "                       check_backup_health -> Check latest backup belongs to last 24 hours then Compare two latest backup file (Response: 0 FAILED, 2 OK)"
}


function check_access {
if [[ "$(mount | grep $BACKUP_DIR)" == "" ]]
then
	echo "0"
else
        if [[ "$(sudo touch $BACKUP_DIR/test | echo $?)" == "1" ]]
        then
                echo "1"
        else
                echo "0"

	fi
fi
}

function db_backup_integrity_check {
LATEST_DB_BACKUP=$(find $DB_BACKUP_DIR -printf '%T+ %p\n' | sort -r | head -n1 | awk {'print $2'})
TMP_DIR=$(date +%s)
mkdir /tmp/S_$TMP_DIR
cp $LATEST_DB_BACKUP /tmp/S_$TMP_DIR/
cd /tmp/S_$TMP_DIR
FILENAME_COMPRESSED=$(ls -f1 | grep gz)
FILENAME=$(echo $FILENAME_COMPRESSED | sed 's/.gz//g')
CURRENT_BACKUP_SIZE_COMPRESSED=$(du -s $FILENAME_COMPRESSED | awk {'print $1'} )
gunzip $FILENAME_COMPRESSED
CURRENT_BACKUP_SIZE=$(du -s $FILENAME | awk {'print $1'})

if [[ "$1" == "check_db_backup_size" ]]
then
	echo $CURRENT_BACKUP_SIZE
	rm -rf /tmp/S_$TMP_DIR
	exit
fi
if [[ "$1" == "check_backup_health" ]]
then
	if [[ "$(find $DB_BACKUP_DIR -ctime -1 | grep gz)" == "" ]]
	then
		echo "0"
		rm -rf /tmp/S_$TMP_DIR && exit
	else
		PREVIOUS_BACKUP_NAME=$(find $DB_BACKUP_DIR -ctime -2 | grep gz | head -n2 | tail -n1)
		PREVIOUS_BACKUP_SIZE_COMPRESSED=$(du -s $PREVIOUS_BACKUP_NAME | awk {'print $1'} )
		if [[ "$CURRENT_BACKUP_SIZE_COMPRESSED" -lt "$PREVIOUS_BACKUP_SIZE_COMPRESSED" ]]
		then
			echo "0"
			rm -rf /tmp/S_$TMP_DIR && exit
		else
			echo "1"
			rm -rf /tmp/S_$TMP_DIR && exit
		fi

	fi


fi

}


if [[ "$1" == "check_access" ]]
then
	check_access
	exit
fi

if [[ "$1" == "check_db_backup_size" ]]
then
	db_backup_integrity_check check_db_backup_size
	exit
fi

if [[ "$1" == "check_backup_health" ]]
then
	db_backup_integrity_check check_backup_health
	exit
fi

help
