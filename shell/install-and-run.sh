#!/bin/sh

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

CONFIG_PATH=/etc/edh/conf
NODES_FILE=$CONFIG_PATH/nodes
MANAGER_FILE=$CONFIG_PATH/manager
TMP_FILE=/tmp/edh_tmp
HOSTNAME=`hostname`
PASSWORD='redhat'

echo -e "\n[INFO]:Install JavaChen(R) Distribution for Apache Hadoop* Software..."
echo -e "[INFO]:Hostname is $HOSTNAME, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`"

### copy edh ###
\cp -r edh /etc/
cd script

echo -e "\n[INFO]:Install hadoop for all nodes:$NODES_LIST"

if [ ! -f $NODES_FILE ]; then
	echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

if [ ! -f $MANAGER_FILE ]; then
	echo "ERROR: Can not found manager configuration file $MANAGER_FILE"
	exit 1
fi

NODES_LIST="`cat $NODES_FILE`"
MANAGER_LIST="`cat $MANAGER_FILE`"
grep -vf $MANAGER_FILE $NODES_FILE >$TMP_FILE #获取去掉manager的所有节点

sh config.sh
for node in $NODES_LIST ;do
	echo -e "[INFO]:Config ssh nopassword for $node"
	./ssh_nopassword.sh $node $PASSWORD
done

if [ -s $TMP_FILE ] ;then
	# sync yum
	pscp -h $TMP_FILE /etc/yum.repos.d/*.repo /etc/yum.repos.d/
	# config nodes
	mussh -m -u -b -t 6 -H $TMP_FILE -C config.sh
	pscp -h $TMP_FILE /etc/localtime /etc/localtime
	pscp -h $TMP_FILE /etc/sysconfig/clock /etc/sysconfig/clock
fi

### ntp ###
echo -e "[INFO]:Config ntp"
\cp /etc/edh/template/ntp.conf /etc/ntp.conf
sed -i "/^driftfile/ s:^driftfile.*:driftfile /var/lib/ntp/ntp.drift:g" /etc/ntp.conf

service ntpd start

for node in `cat $TMP_FILE` ;do
	if [ "${node}" == "" ] ; then
		continue
	fi
	ssh ${node} '
	echo "Synchronizing the node'\''s timezone and clock with the management node'\''s time and timezone."
	echo "Waiting for ['${node}'] to update it clock to the clock on ['$HOSTNAME']..."

	if service ntpd status >/dev/null 2>&1; then
		service ntpd stop
	fi

	echo "Synchronizing the node'\''s time with the NTP server..." 
	waiting_time=30
	while ! ntpdate '$HOSTNAME' 2>&1 ; do
		if [ $waiting_time -eq 0 ]; then
		    echo "[ERROR]: Please check whether the ntpd service is running on ntp server '$HOSTNAME'." 
		    exit 1
		fi

		mod=`expr $waiting_time % 3`
		if [[ $mod -eq 0 ]]; then
		    echo "."
		fi

		sleep 1
		let waiting_time=$waiting_time-1
	done

	for x in 1 2 3 4 5 ; do
		echo -n ""
		ntpdate '$HOSTNAME'
		sleep 1
	done
	# write system clock to hardware clock.
	hwclock --systohc || true
'
done

sh install_hadoop.sh
sh rsync_file.sh

sh install_postgres.sh

sh cluster.sh stop
sh format_cluster.sh
sh cluster.sh start

echo "[INFO]:Install hadoop on cluster complete!"
