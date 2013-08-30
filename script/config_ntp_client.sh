#!/bin/sh

MANAGER_LIST=`cat /etc/edh/manager.csv`
NODES_FILE="/etc/edh/nodes.csv"
if [ -f $NODES_FILE ]; then
    	NODES_LIST="`cat $NODES_FILE`"
else
	echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

if [ $MANAGER_LIST == $NODES_LIST ]; then
	exit 1
fi

script_dir=`dirname $0`
execmsg=`yum -y -q install ntp 2>&1`
export config_log='node-config.log'


echo "Synchronize time and timezone ..." | tee -a $config_log
echo "Waiting for [`hostname`] update time to [$MANAGER_LIST]..." | tee -a $config_log
echo "Installing ntp ..." | tee -a $config_log

if [[ $? -ne 0 ]]; then
	echo "[ERROR]: $execmsg" | tee -a $config_log
else
	echo "Finish Installing ntp ..." | tee -a $config_log
fi

if service ntpd status >/dev/null 2>&1; then
	service ntpd stop
fi

echo "Synchronizing time with ntp server ..." | tee -a $config_log
waiting_time=9
while ! ntpdate $MANAGER_LIST  >> $config_log 2>&1
do
	if [ $waiting_time -eq 0 ]; then
	    echo "[ERROR]: Please check whether the ntpd service is running on ntp server $MANAGER_LIST." | tee -a $config_log
	    exit 1
	fi

	mod=`expr $waiting_time % 3`
	if [[ $mod -eq 0 ]]; then
	    echo "." | tee -a $config_log
	fi

	sleep 1
	let waiting_time=$waiting_time-1
done

for x in 1 2 3 4 5
do
	echo -n "" | tee -a $config_log
	ntpdate $MANAGER_LIST | tee -a $config_log
	sleep 1
done
# write system clock to hardware clock.
hwclock --systohc
echo "Config ntp finish ..." | tee -a $config_log
