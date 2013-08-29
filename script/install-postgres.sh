#!/bin/bash

if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi

echo "[INFO]:install postgres"

get_postgresql_major_version()
{
  local psql_output=`psql --version`
  local regex="^psql \(PostgreSQL\) ([[:digit:]]+)\..*"

  if [[ $psql_output =~ $regex ]]; then
    echo ${BASH_REMATCH[1]}
  fi
}

get_standard_conforming_strings()
{
  local psql_version=$(get_postgresql_major_version)
  if [[ $psql_version -gt 8 ]]; then
    echo "# This is needed to make Hive work with Postgresql 9.1 and above"
    echo "# See OPSAPS-11795"
    echo "standard_conforming_strings=off"
  fi
}

check_postgresql_installed(){
	if ! rpm -q postgresql-server >/dev/null ; then
	    	yum install postgresql-server postgresql-jdbc -y
		chkconfig postgresql on
	fi

	service postgresql stop
	pkill -9 postgres
	rm -rf /var/lib/pgsql/data
	rm -rf /var/run/postgresql/.s.PGSQL.5432
	service postgresql initdb
}

configure_postgresql_conf(){
	sed -e '/^port\s*=/d' -i $CONF_FILE
	sed -e '/^listen_addresses\s*=/d' -i $CONF_FILE
	sed -e '/^max_connections\s*=/d' -i $CONF_FILE
	sed -e '/^standard_conforming_strings\s*=/d' $CONF_FILE
	sed -e '/^shared_buffers\s*=/d' -i $CONF_FILE

	local TMPFILE=$(mktemp /tmp/XXXXXXXX)
	cat $CONF_FILE >> $TMPFILE >/dev/null
	 
	echo "Adding configs"
	sed -i "1a port = $DB_PORT" $TMPFILE
	sed -i "2a listen_addresses = '*'" $TMPFILE
	sed -i "3a max_connections = 600" $TMPFILE
	sed -i "4a shared_buffers = 256MB" $TMPFILE
	local SCS="$(get_standard_conforming_strings)"
	if [ "$SCS" != "" ]; then
	sed -i "5a $(get_standard_conforming_strings)" $TMPFILE
	fi

	cat $TMPFILE > $CONF_FILE >/dev/null
}

enable_remote_connections(){
	echo "local    all             all             		               trust" > /var/lib/pgsql/data/pg_hba.conf
	echo "host     all             all             0.0.0.0/0	       trust" >> /var/lib/pgsql/data/pg_hba.conf
}

create_db(){
	DB_NAME=$1
	DB_USER=$2
	DB_PASSWORD=$3
	su -c "cd ; /usr/bin/pg_ctl start -w -m fast -D /var/lib/pgsql/data" postgres
	su -c "cd ; /usr/bin/psql --command \"create user $DB_USER with password '$DB_PASSWORD'; \" " postgres
	su -c "cd ; /usr/bin/psql --command \"CREATE DATABASE $DB_NAME owner=$DB_USER;\" " postgres
	su -c "cd ; /usr/bin/psql --command \"GRANT ALL privileges ON DATABASE $DB_NAME TO $DB_USER;\" " postgres
}

init_hive_metastore(){
	DB_NAME=$1
	DB_USER=$2
	DB_FILE=$3
	su -c "cd ; /usr/bin/psql -U $DB_USER -d $DB_NAME -f $DB_FILE" postgres
}

restart_db(){
	su -c "cd ; /usr/bin/pg_ctl restart -w -m fast -D /var/lib/pgsql/data" postgres
}

DB_HOST=$(hostname -f)
DB_PORT=${DB_PORT:-5432}
DB_HOSTPORT="$DB_HOST:$DB_PORT"
CONF_FILE="/var/lib/pgsql/data/postgresql.conf"

check_postgresql_installed
configure_postgresql_conf
enable_remote_connections
create_db metastore hiveuser redhat
init_hive_metastore metastore hiveuser "/usr/lib/hive/scripts/metastore/upgrade/postgres/hive-schema-0.10.0.postgres.sql"
restart_db


