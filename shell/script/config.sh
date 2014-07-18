#!/bin/sh

function addline {
    line=$1
    file=$2
    tempstr=`grep "$line" $file  2>/dev/null`
    if [ "$tempstr" == "" ]; then
        echo "$line" >>$file
    fi
}

### config system ###
echo -e "[INFO]:Stop firewalls ..."
[ -f /etc/init.d/iptables ] && FIREWALL="iptables"
[ -f /etc/init.d/SuSEfirewall2_setup ] && FIREWALL="SuSEfirewall2_setup"
[ -f /etc/init.d/boot.apparmor ] && SELINUX="boot.apparmor"
[ -f /usr/sbin/setenforce ] && SELINUX="selinux"
service $FIREWALL stop >/dev/null 2>&1
chkconfig $FIREWALL off > /dev/null 2>&1

if [ $SELINUX == "selinux" ]; then
    sed -i "s/.*SELINUX=.*/SELINUX=disabled/g" /etc/selinux/config 
    setenforce 0  >/dev/null 2>&1
elif [ $SELINUX == "boot.apparmor" ]; then
    service boot.apparmor stop >/dev/null 2>&1
    chkconfig boot.apparmor off > /dev/null 2>&1
fi

### JAVA_HOME ###
echo -e "[INFO]:Config JAVA_HOME ..."
if [ -f ~/.bashrc ] ; then
    sed -i '/^export[[:space:]]\{1,\}JAVA_HOME[[:space:]]\{0,\}=/d' ~/.bashrc
    sed -i '/^export[[:space:]]\{1,\}CLASSPATH[[:space:]]\{0,\}=/d' ~/.bashrc
    sed -i '/^export[[:space:]]\{1,\}PATH[[:space:]]\{0,\}=/d' ~/.bashrc
fi
echo "export JAVA_HOME=/usr/java/latest" >> ~/.bashrc
echo "export CLASSPATH=.:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar">>~/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.bashrc

echo  "
export HADOOP_HOME=/usr/lib/hadoop
export HIVE_HOME=/usr/lib/hive
export HBASE_HOME=/usr/lib/hbase
export HADOOP_HDFS_HOME=/usr/lib/hadoop-hdfs
export HADOOP_MAPRED_HOME=/usr/lib/hadoop-mapreduce
export HADOOP_COMMON_HOME=${HADOOP_HOME}
export HADOOP_HDFS_HOME=/usr/lib/hadoop-hdfs
export HADOOP_LIBEXEC_DIR=${HADOOP_HOME}/libexec
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export HDFS_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export YARN_HOME=/usr/lib/hadoop-yarn
export YARN_CONF_DIR=${HADOOP_HOME}/etc/hadoop
">v~/.bashrc

alternatives --install /usr/bin/java java /usr/java/latest 5
alternatives --set java /usr/java/latest 
source ~/.bashrc

### config ssh ###
echo -e "[INFO]:Config ssh"
[ ! -d ~/.ssh ] && ( mkdir ~/.ssh ) && ( chmod 600 ~/.ssh )
yes|ssh-keygen -f ~/.ssh/id_rsa -t rsa -N "" && ( chmod 600 ~/.ssh/id_rsa.pub )

addline "StrictHostKeyChecking no" ~/.ssh/config
addline "UserKnownHostsFile /dev/null" ~/.ssh/config
addline "LogLevel ERROR" ~/.ssh/config

### set global file limit ###
echo -e "[INFO]: Set Global file limit ..."

sysctl -w vm.swappiness=0 

rst=`grep "^fs.file-max" /etc/sysctl.conf`
if [ "x$rst" = "x" ] ; then
	echo "fs.file-max = 727680" >> /etc/sysctl.conf || exit $?
else
	sed -i "s:^fs.file-max.*:fs.file-max = 727680:g" /etc/sysctl.conf
fi

addline "*	soft		nofile	327680" /etc/security/limits.conf
addline "*	hard	nofile	327680" /etc/security/limits.conf
addline "root	soft		nofile	327680" /etc/security/limits.conf
addline "root	hard	nofile	327680" /etc/security/limits.conf

curuser=`whoami`
for user in hdfs mapred hbase zookeeper hive impala flume $curuser ;do
    addline "$user	soft		nproc	131072" /etc/security/limits.conf
    addline "$user	hard	nproc	131072" /etc/security/limits.conf
done

### install basic rpm ###
echo -e "[INFO]:Installing jdk rsync expect openssh-server openssh-clients ntp pssh"
yum install -y -q install jdk postgresql-jdbc hadoop hbase hive zookeeper hadoop-yarn hadoop-debuginfo rsync expect openssh-server openssh-clients ntp pssh
if ! rpm -q hadoop hbase hive zookeeper hadoop-yarn hadoop-debuginfo jdk postgresql-jdbc rsync expect openssh-server openssh-clients ntp pssh>/dev/null ; then
    exit 1
fi
