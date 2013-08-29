#!/bin/sh

if [ "$#" != "0" ]; then
    echo "USAGE: 
    ./config_manager.sh"
    exit 1
fi

umask 022
PASSWORD="redhat"
SCRIPT_DIR=`dirname $0`
export LD_LIBRARY_PATH=$path:$LD_LIBRARY_PATH

echo -e "\nInstall Embrace(R) Distribution for Apache Hadoop* Software..."
echo -e "Hostname is $HOSTNAME, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`"

#0.config system
echo -e "config system for manager"
sh config_system.sh

#1.init
echo -e "init for manager"
sh init.sh

#2.yum
echo -e "config yum for manager"
sh config_yum_server.sh $HOSTNAME

#3.rpm
echo -e "Installing jdk,rsync,expect,ntp,nagios,ssh and other required packages ..."
yum install -y -q install jdk rsync expect openssh-server openssh-clients ntp nagios nagios-plugins
if ! rpm -q jdk rsync expect openssh-server openssh-clients ntp>/dev/null ; then
    exit 1
fi

#4.JAVA_HOME
echo -e "Config JAVA_HOME"
sh config_java.sh

#5.ssh
echo -e "Config ssh for manager"
if [ ! -f /root/.ssh/id_rsa ] ; then
	yes|ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""
	[ ! -d /root/.ssh ] && ( mkdir /root/.ssh ) && ( chmod 700 /root/.ssh )
fi

./ssh_nopassword.sh $HOSTNAME $PASSWORD >/dev/null

#6.ntp
echo -e "Config ntp for manager"
cp /etc/edh/conf-template/ntp.conf /etc/ntp.conf
sed -i "/^driftfile/ s:^driftfile.*:driftfile /var/lib/ntp/ntp.drift:g" /etc/ntp.conf
if service ntpd status >/dev/null 2>&1; then
    service ntpd stop
fi
service ntpd start

echo -e "\nInstall Embrace(R) Manager for Apache Hadoop Software successfully\n"
