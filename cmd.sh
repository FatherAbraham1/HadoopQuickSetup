
NODES_FILE="/etc/edh/conf/nodes"
if [ -f $NODES_FILE ]; then
    	NODES_LIST="`cat $NODES_FILE`"
else
	echo "ERROR: Can not found role configuration file $NODES_FILE"
	exit 1
fi

for node in $NODES_LIST ;do
	echo "----$node----"
	ssh root@$node $1 
done

