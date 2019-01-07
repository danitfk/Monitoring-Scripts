#!/bin/bash
# Author: Daniel Gordi (danitfk)
# Date: 31/Dec/2018

function help {
echo "Usage: ./deskpro_health-check.sh [test_db,test_web]"
exit 1

}


function test_db {
export deskpro_dbconf="/path/to/deskpro/config/config.database.php"
export MYSQL_PASS=$(grep "^\$DB_CONFIG\['password'" $deskpro_dbconf | cut -d"'" -f4)
export MYSQL_HOST=$(grep "^\$DB_CONFIG\['host'" $deskpro_dbconf | cut -d"'" -f4)
export MYSQL_USER=$(grep "^\$DB_CONFIG\['user'" $deskpro_dbconf | cut -d"'" -f4)
export QUERY="use deskpro; select agent_id from agent_activity limit 1;"
TEST_DB=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e"$QUERY"  | awk {'print $1'} | head -n1)
if [ "$TEST_DB" == "agent_id" ]
then
	echo "1"
else
	echo "0"
fi
}

function test_web {
STRING="پشتیبانی"
URL="https://support.cafebazaar.ir/en/new-ticket"
TEST_WEB=$(curl -s -XGET $URL | grep -o "$STRING" | head -n1)
if [ "$TEST_WEB" == "$STRING" ]
then
	echo "1"
else
	echo "0"

fi
}

if [ "$1" == "test_db" ]
then
	# Run Function
	test_db
fi

if [ "$1" == "test_web" ]
then
        # Run Function
	test_web
fi

if [ "$1" == "" ]
then
        # Run Function
	help
fi


unset MYSQL_PASS
