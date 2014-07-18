CONFIG_PATH=/etc/edh/conf
NODES_FILE=$CONFIG_PATH/nodes
MANAGER_FILE=$CONFIG_PATH/manager


if [ ! -f $NODES_FILE ]; then
    echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

HOSTS="`cat $NODES_FILE $MANAGER_FILE  |sort -n | uniq | tr '\n' ' '|  sed 's/,$//'`"


for node in $HOSTS;do
	echo "----$node----"
	scp -r $1 root@$node:$2 
done

