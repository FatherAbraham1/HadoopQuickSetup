CONFIG_PATH=/etc/edh/conf
NODES_FILE=$CONFIG_PATH/nodes
MANAGER_FILE=$CONFIG_PATH/manager


if [ ! -f $NODES_FILE ]; then
    echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

HOSTS="`cat $NODES_FILE $MANAGER_FILE  |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"

echo "nodes: $HOSTS"
for node in $HOSTS;do
	echo "----$node----"
	ssh root@$node 'for src in `ls /etc/init.d|grep '$1'`;do service $src '$2'; done' 
done

