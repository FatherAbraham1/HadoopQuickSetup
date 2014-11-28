#!/bin/sh

# resolve links - $0 may be a softlink
this="${BASH_SOURCE-$0}"
common_bin=$(cd -P -- "$(dirname -- "$this")" && pwd -P)
script="$(basename -- "$this")"
this="$common_bin/$script"

# convert relative path to absolute path
config_bin=`dirname "$this"`
script=`basename "$this"`
config_bin=`cd "$config_bin"; pwd`
this="$config_bin/$script"

# Begin
echo ""
echo "[INFO]:Install JavaChen(R) Distribution for Apache Hadoop* Software..."
echo "[INFO]:Manager is `hostname -f`, Time is `date +'%F %T'`, TimeZone is `date +'%Z %:z'`"
echo ""

if [ `id -u` -ne 0 ]; then
   echo "[ERROR]:Must run as root";  exit 1
fi

sh $config_bin/bin/config_cluster.sh

echo ""
sh $config_bin/bin/install_hadoop.sh

echo ""
sh $config_bin/bin/postinstall_hadoop.sh

exit

echo ""
sh $config_bin/bin/install_postgres.sh




sh $config_bin/script/cluster.sh hive stop
sh $config_bin/script/cluster.sh hbase stop
sh $config_bin/script/cluster.sh zookeeper stop
sh $config_bin/script/cluster.sh hadoop stop

sh $config_bin/format_cluster.sh

sh $config_bin/script/cluster.sh hadoop start
sh $config_bin/script/cluster.sh zookeeper start
sh $config_bin/script/cluster.sh hbase start
sh $config_bin/script/cluster.sh hive start

echo "[INFO]:Install hadoop on cluster complete!"
