#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

cd script
sh config_manager.sh

if [ "$?" != "0" ]; then
	exit 1
fi

#setup for single node installtion
echo `hostname` >/etc/edh/manager.csv
echo `hostname` >/etc/edh/nodes.csv

sh config_client.sh
sh install_hadoop.sh
sh rsync_file.sh

sh install_postgres.sh

sh start.sh stop
sh format_cluster.sh
sh format_namenode.sh
sh start.sh start

cd ../patch
sh patch1.sh


if [ $? == 1 ]; then 
	exit 1
fi
echo "[INFO]:Install hadoop on single node successfully!"


