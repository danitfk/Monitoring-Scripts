### Galera Monitoring Tool
It's a simple bash script to get status from MySQL/MariaDB node about Galera Cluster.
Currently it supports these options:
- `cluster_status`: 1 -> OK , 0 -> NOT OK
Shows the primary status of the cluster component that the node is in, which you can use in determining whether your cluster is experiencing a partition.
- `cluster_size`: Print number of Galera nodes in cluster.
Shows the number of nodes in the cluster, which you can use to determine if any are missing.
- `wsrep_connection`: 1 -> OK , 0 -> NOT OK
Shows whether the node has network connectivity with any other nodes.
- `wsrep_send_queue`: Print number in Millisecond unit.
Shows the average size of the local received queue since the last status query.

# Requirements:
In Debian/Ubuntu distro's mysql credentials can find in `/etc/mysql/debian.cnf` but in other distro's you have to modify the script, in top of script which variables located. You have to declare MySQL Username and Password to run the script.

# Example:

```
dani@GaleraNode01:/etc/zabbix/scripts$ ./Galera-Monitoring-Toolkit.sh 
Usage: ./Galera-Monitoring-Toolkit.sh [cluster_status|cluster_size|wsrep_connection|wsrep_send_queue]
dani@GaleraNode01:/etc/zabbix/scripts$ ./Galera-Monitoring-Toolkit.sh cluster_status
1
dani@GaleraNode01:/etc/zabbix/scripts$ ./Galera-Monitoring-Toolkit.sh cluster_size
3
dani@GaleraNode01:/etc/zabbix/scripts$ ./Galera-Monitoring-Toolkit.sh wsrep_connection
1
dani@GaleraNode01:/etc/zabbix/scripts$ ./Galera-Monitoring-Toolkit.sh wsrep_send_queue
71

```

# Zabbix Integration:
** Zabbix Template with Graph / Item / Triggers Included **

You can use this script in Zabbix to produce items. There is an example for userparameter:

```
UserParameter=galera.cluster_status, /etc/zabbix/scripts/Galera-Monitoring-Toolkit.sh cluster_status
UserParameter=galera.cluster_size, /etc/zabbix/scripts/Galera-Monitoring-Toolkit.sh cluster_size  
UserParameter=galera.wsrep_connection, /etc/zabbix/scripts/Galera-Monitoring-Toolkit.sh wsrep_connection
UserParameter=galera.wsrep_send_queue, /etc/zabbix/scripts/Galera-Monitoring-Toolkit.sh wsrep_send_queue

```
