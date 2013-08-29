#!/bin/sh

MANAGER_HOSTS=`cat /etc/edh/manager.csv`

NODES_FILE="/etc/edh/nodes.csv"
if [ -f $NODES_FILE ]; then
    	NODES_LIST="`cat $NODES_FILE`"
else
	echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

function continue_ask {
	continue_flag="undef"
	while [ "$continue_flag" != "yes" -a "$continue_flag" != "no" ]
	do
		echo -n "Type yes to continue or no to exit uninstallation...[yes|no]: "
		read continue_flag
		if [ "$continue_flag" == "no" ]; then
		  	return 1
		fi
	done
	return 0
}

echo -e "\n************************************************************************************************************"
echo "Clean hadoop hbase hive zookeeper sqoop mahout flume pig ganglia puppet nginx intel-manager for `hostname`?"
echo "************************************************************************************************************"
continue_ask

services="hadoop-namenode hadoop-datanode hadoop-resourcemanager hadoop-nodemanager hadoop-secondarynamenode hbase-master hbase-regionserver hbase-thrift hive-metastore hive-server hive-server2 postgresql zookeeper-server oozie"

for srvc in $services ; do
	if service $srvc status >/dev/null 2>&1; then
		echo "Service $srvc is running. Begin to stop it."
		service $srvc stop >/dev/null 2>&1
	fi
done

services="puppet puppetmaster nginx pacemaker corosync gmond gmetad nagios"
for srvc in $services ; do
	service $srvc stop >/dev/null 2>&1
done


yum-complete-transaction >/dev/null 2>&1
yum clean all >/dev/null 2>&1
if [ "$?" != "0"  ]; then 
	echo -e "\nERROR: Cannot connect to the EDH or OS repository. "
	echo "Please check the repo files in /etc/yum.repos.d on `hostname`"
	echo "And make sure the IDH and OS  repository availabe. "
	exit 1
fi

echo "Uninstalling other related packages"
yum -y -q remove hadoop-doc hbase-doc hadoop-debuginfo oozie-client libganglia ganglia-gmetad ganglia-gmond ganglia-web ganglia-gmond-modules-python nagios-plugins >/dev/null 2>&1

echo "Uninstalling Embrace Manager for Apache Hadoop"
echo "Removing related directories ..."
rm -rf /etc/edh
rm -rf /etc/default
rm -rf /usr/lib64/ganglia
rm -rf /var/zookeeper
rm -rf /var/spool/nagios/nagios.cmd
rm -rf /var/cache/yum

echo "recovery repo files"
cd /etc/yum.repos.d
rm -rf os.repo* idh.repo*
rename .repo.bak .repo *
cd - >/dev/null

echo "Uninstallation for `hostname` finished."

for comp in pacemaker corosync hadoop hbase hive zookeeper sqoop pig ganglia nagios puppet nginx ftpoverhdfs
do
	echo "Uninstalling $comp ..."
	yum -y -q remove $comp >/dev/null 2>&1
	rm -rf /etc/$comp /usr/lib/$comp /var/log/$comp /var/lib/$comp
done
