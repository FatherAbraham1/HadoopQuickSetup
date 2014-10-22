#!/bin/sh

CONFIG_PATH=/etc/edh/conf
NODES_FILE=$CONFIG_PATH/nodes
MANAGER_FILE=$CONFIG_PATH/manager
HOSTNAME=`hostname`
PASSWORD='redhat'

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

echo -e "\n[INFO]:Install JavaChen(R) Distribution for Apache Hadoop* Software..."
echo -e "[INFO]:Hostname is $HOSTNAME, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`"
echo -e "\n[INFO]:Install hadoop for all nodes:$NODES_LIST"

\cp -r edh /etc/
cd script

ALL_HOSTS="`cat $NODES_FILE $MANAGER_FILE  |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"
NODES_ONLY=`grep -vf $MANAGER_FILE $NODES_FILE |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'` #获取去掉manager的所有节点

sh config.sh

echo "[INFO]:Config ssh nopassword"
for node in $ALL_HOSTS ;do
	./ssh_nopassword.expect $node $PASSWORD
done	

pscp -H "$ALL_HOSTS" /etc/yum.repos.d/*.repo /etc/yum.repos.d/
pscp -H "$ALL_HOSTS" /etc/localtime /etc/localtime
pscp -H "$ALL_HOSTS" /etc/sysconfig/clock /etc/sysconfig/clock

pssh -P -i -H "$NODES_ONLY"  "`cat config.sh`" 


### ntp ###
echo "[INFO]:Config ntp"
\cp /etc/edh/template/ntp.conf /etc/ntp.conf
sed -i "/^driftfile/ s:^driftfile.*:driftfile /var/lib/ntp/ntp.drift:g" /etc/ntp.conf
service ntpd start

echo "[INFO]:Synchronizing time and timezone to $HOSTNAME"
pssh -P -i -h $NODES_ONLY '
	echo "[INFO]:Synchronizing the node'\''s timezone and clock with the management node'\''s time and timezone."
	echo "[INFO]:Waiting for ['${node}'] to update it clock to the clock on ['$HOSTNAME']..."

	if service ntpd status >/dev/null 2>&1; then
		service ntpd stop
	fi

	echo "[INFO]:Synchronizing the node'\''s time with the NTP server..." 
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

sh install_hadoop.sh

sh rsync_file.sh

sh install_postgres.sh

sh /etc/edh/cluster.sh hive stop
sh /etc/edh/cluster.sh hbase stop
sh /etc/edh/cluster.sh zookeeper stop
sh /etc/edh/cluster.sh hadoop stop

sh format_cluster.sh

sh /etc/edh/cluster.sh hadoop start
sh /etc/edh/cluster.sh zookeeper start
sh /etc/edh/cluster.sh hbase start
sh /etc/edh/cluster.sh hive start

echo "[INFO]:Install hadoop on cluster complete!"
