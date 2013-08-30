#!/bin/sh

PASSWORD='redhat'

echo -e "\n[INFO]:Install hadoop for all clients"

#0.nodes
MANAGER_HOSTS=`cat /etc/edh/manager.csv`
NODES_FILE="/etc/edh/nodes.csv"
if [ -f $NODES_FILE ]; then
    	NODES_LIST="`cat $NODES_FILE`"
else
	echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

#1.ssh nopassword
echo -e "[INFO]:Config ssh nopassword for client"
for node in $NODES_LIST ;do
	./ssh_nopassword.sh $node $PASSWORD >/dev/null 2>&1
done

if [ $MANAGER_HOSTS == $NODES_LIST ]; then
	exit 1
fi

#2.yum
echo -e "[INFO]:Config yum for client"
pscp -h $NODES_FILE /etc/yum.repos.d/edh.repo /etc/yum.repos.d/
pscp -h $NODES_FILE /etc/yum.repos.d/os.repo /etc/yum.repos.d/


#3.config system
echo -e "[INFO]:Config system env"
mussh -m -u -b -t 6 -H $NODES_FILE -C config_system.sh

#4.rpm
echo -e "[INFO]:Installing jdk,expect,ntp,nagios,ssh and other required packages ..."
yum install -y -q install jdk openssh-server openssh-clients ntp
if ! rpm -q jdk openssh-server openssh-clients ntp>/dev/null ; then
    exit 1
fi

#5.JAVA_HOME
echo -e "[INFO]:Config JAVA_HOME for client"
mussh -m -u -b -t 6 -H $NODES_FILE -C config_java.sh

#6.ntp
echo -e "[INFO]:Config ntp for client"
pscp -h $NODES_FILE /etc/localtime /etc/localtime
pscp -h $NODES_FILE /etc/sysconfig/clock /etc/sysconfig/clock
mussh -m -u -b -t 6 -H $NODES_FILE -C config_ntp_client.sh

