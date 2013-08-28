if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

HOSTNAME=`hostname`
PASSWORD='redhat'

mkdir -p /etc/edh
cp -r edh/* /etc/edh/
echo $HOSTNAME >/etc/edh/role.csv 

iptables -F

echo "[INFO]:config yum"

#yum-config-manager --add-repo=http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/cloudera-cdh4.repo
#sudo rpm --import http://archive.cloudera.com/cdh4/redhat/6/x86_64/cdh/RPM-GPG-KEY-cloudera

echo "[cloudera-cdh4]" >/etc/yum.repos.d/edh.repo
echo "name=cdh4" >>/etc/yum.repos.d/edh.repo
#echo "baseurl=ftp://192.168.0.70/pub/tmp/cdh/4.3.0/" >>/etc/yum.repos.d/edh.repo
echo "baseurl=ftp://192.168.56.101/pub/cdh/4.3.0/" >>/etc/yum.repos.d/edh.repo
echo "gpgcheck = 0" >>/etc/yum.repos.d/edh.repo
yum clean all 

echo "[INFO]:install hadoop"

yum install -y hadoop  hadoop-debuginfo hadoop-hdfs-namenode hadoop-hdfs-datanode hadoop-hdfs-secondarynamenode hadoop-mapreduce-historyserver hadoop-yarn hadoop-yarn-resourcemanager  hadoop-yarn-nodemanager hive hive-metastore hive-server2 hive-jdbc zookeeper-server zookeeper hbase hbase-master hbase-regionserver 

#wget ftp://192.168.0.30/pub/idh/hadoop_related/common/jdk-1.6.0_31-fcs.x86_64.rpm
#yum install jdk-1.6.0_31-fcs.x86_64.rpm

expect scripts/ssh_nopassword.exp $HOSTNAME $PASSWORD >/dev/null 2>&1

echo "[INFO]:config java"

if [ -f /root/.bashrc ] ; then
    sed -i '/^export[[:space:]]\{1,\}JAVA_HOME[[:space:]]\{0,\}=/d' /root/.bashrc
    sed -i '/^export[[:space:]]\{1,\}CLASSPATH[[:space:]]\{0,\}=/d' /root/.bashrc
    sed -i '/^export[[:space:]]\{1,\}PATH[[:space:]]\{0,\}=/d' /root/.bashrc
fi
echo "" >>/root/.bashrc
echo "export JAVA_HOME=/usr/java/latest" >>/root/.bashrc
echo "export CLASSPATH=.:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar">>/root/.bashrc
echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /root/.bashrc
alternatives --install /usr/bin/java java /usr/java/latest 5
alternatives --set java /usr/java/latest 
source /root/.bashrc

rm -rf /etc/{hadoop,hive,hbase,zookeeper}/{conf,conf.edh}
mkdir -p /etc/{hadoop,hive,hbase,zookeeper}/conf.edh


alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.edh 50
alternatives --set hadoop-conf /etc/hadoop/conf.edh

alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.edh 50
alternatives --set hive-conf /etc/hive/conf.edh

alternatives --install /etc/hbase/conf hbase-conf /etc/hbase/conf.edh 50
alternatives --set hbase-conf /etc/hbase/conf.edh

alternatives --install /etc/zookeeper/conf zookeeper-conf /etc/zookeeper/conf.edh 50
alternatives --set zookeeper-conf /etc/zookeeper/conf.edh

touch /var/lib/hive/.hivehistory
chown -R hive:hive  /var/lib/hive/.hivehistory

ln -s /usr/lib/hive/lib/hive-hbase-handler-0.10.0-cdh4.3.0.jar /usr/lib/hive/lib/hive-hbase-handler.jar


echo "[INFO]:update conf"

cp -u conf-template/hadoop/conf/* /etc/hadoop/conf
cp -u conf-template/hive/conf/* /etc/hive/conf
cp -u conf-template/hbase/conf/* /etc/hbase/conf
cp -u conf-template/zookeeper/conf/* /etc/zookeeper/conf

sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/core-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/hdfs-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/mapred-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hadoop/conf/yarn-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hive/conf/hive-site.xml
sed -i "s|localhost|$HOSTNAME|g" /etc/hbase/conf/hbase-site.xml

sh format.sh

cd patch
sh patch1.sh

cd ..
sh install-postgres.sh

sh start.sh start

if [ $? == 1 ]; then 
	exit 1
fi
echo "[INFO]:Install hadoop on single node successfully!"


