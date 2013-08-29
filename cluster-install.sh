#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

cd script
sh config_manager.sh

if [ "$?" != "0" ]; then
	exit 1
fi

sh config_client.sh
sh install_hadoop.sh

sh start.sh stop
sh format.sh
sh install-postgres.sh
sh start.sh start

cd ../patch
sh patch1.sh


if [ $? == 1 ]; then 
	exit 1
fi
echo "[INFO]:Install hadoop on cluster successfully!"
