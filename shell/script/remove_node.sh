#!/bin/sh

echo "[INFO]:Stop hadoop services for `hostname`?"

services="hadoop-namenode hadoop-datanode hadoop-resourcemanager hadoop-nodemanager 
hadoop-secondarynamenode hbase-master hbase-regionserver hbase-thrift hive-metastore 
hive-server hive-server2 postgresql zookeeper-server oozie puppet puppetmaster nginx 
pacemaker corosync gmond gmetad nagios"

for srvc in $services ; do
	if service $srvc status >/dev/null 2>&1; then
		echo "[INFO]:Stop service: $srvc ..."
		service $srvc stop >/dev/null 2>&1
	fi
done

services="puppet puppetmaster nginx pacemaker corosync gmond gmetad nagios"
for srvc in $services ; do
	service $srvc stop >/dev/null 2>&1
done


for comp in pacemaker corosync hadoop hbase hive zookeeper sqoop pig ganglia nagios puppet nginx ftpoverhdfs
do
	echo "[INFO]:Uninstalling $comp ..."
	yum -y -q remove $comp >/dev/null 2>&1
	rm -rf /etc/$comp /usr/lib/$comp /var/log/$comp /var/lib/$comp
done

echo "[INFO]:Uninstalling other related packages"
yum -y -q remove hadoop-doc hbase-doc hadoop-debuginfo oozie-client libganglia ganglia-gmetad ganglia-gmond ganglia-web ganglia-gmond-modules-python nagios-plugins >/dev/null 2>&1

echo "[INFO]:Remove related directories ..."
rm -rf /etc/edh
rm -rf /etc/default
rm -rf /usr/lib64/ganglia
rm -rf /var/spool/nagios/nagios.cmd

echo "[INFO]:Recovery repo files"
cd /etc/yum.repos.d
rm -rf os.repo* idh.repo*
rename .repo.bak .repo *
cd - >/dev/null

yum-complete-transaction >/dev/null 2>&1

echo "[INFO]:Uninstallation for `hostname` finished."


