#!/bin/bash
# Author: Daniel Gordi (danitfk)
# Date: 09/Jan/2019
MYSQL_USER="debian-sys-maint"
MYSQL_PASS=$(grep password /etc/mysql/debian.cnf | awk {'print $3'} | head -n1)
function help {
echo "Usage: ./Galera-Monitoring-Tool.sh [cluster_status|cluster_size|wsrep_connection|wsrep_send_queue]"
}


function cluster_size {

MYSQL_QUERY="show global status like 'wsrep_cluster_size'"
RESULT=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -e"$MYSQL_QUERY" | awk {'print $2'} | grep "^[0-9]")
echo $RESULT
}

function cluster_status {

MYSQL_QUERY="show global status like 'wsrep_cluster_status'"
RESULT=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -e"$MYSQL_QUERY" | grep -o Primary)

if [ "$RESULT" == "" ]
then
	echo 0
else
	echo 1
fi

}

function wsrep_connection {
OK="ON"
MYSQL_QUERY="show global status like 'wsrep_connected'"
RESULT=$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASS" -e"$MYSQL_QUERY" | grep -o ON)
if [ "$RESULT" == "$OK" ]; then echo "1" ; else "0" ; fi ;

}

function wsrep_send_queue {
MYSQL_QUERY="show global status like 'wsrep_local_send_queue_avg'"
RESULT=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -e"$MYSQL_QUERY" | awk {'print $2'} | grep "^[0-9]" | sed 's/\.//g' | head -c4 | sed "s/^0*\([1-9]\)/\1/;s/^0*$/0/")
echo $RESULT
}

function mysql_health_check {
RESULT=$(mysql -u$MYSQL_USER -p$MYSQL_PASS -e"show status like 'wsrep_provider_name'" 2> /dev/null | grep -o Galera)
if [ "$RESULT" == "Galera" ]
then
	echo "1"
else
	echo "0"
fi
}

if [ "$1" == "cluster_status" ] || [ "$1" == "cluster_size" ] || [ "$1" == "wsrep_connection" ] || [ "$1" == "wsrep_send_queue" ]
then
	TEST=$(mysql_health_check)
	if [ "$TEST" == "1" ]
	then
		$1
		exit 0
	else
		echo 0
	fi
else
	help
	exit 1
fi
