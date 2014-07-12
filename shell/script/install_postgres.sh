#!/bin/bash

if [ `id -u` -ne 0 ]; then
   echo "must run as root"
   exit 1
fi


echo -e "\n[INFO]:Install postgresql for hive-metastore"

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
	rm -rf /var/lib/pgsql/data /var/run/postgresql/.s.PGSQL.5432
	service postgresql initdb
}

configure_postgresql_conf(){
	#sed -e '/^port\s*=/d' -i $CONF_FILE
	#sed -e '/^listen_addresses\s*=/d' -i $CONF_FILE
	#sed -e '/^max_connections\s*=/d' -i $CONF_FILE
	#sed -e '/^shared_buffers\s*=/d' -i $CONF_FILE
	sed -i "s/#port = 5432/port = $DB_PORT/" $CONF_FILE
	sed -i "s/max_connections = 100/max_connections = 600/" $CONF_FILE
	sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $CONF_FILE
	sed -i "s/shared_buffers = 32MB/shared_buffers = 256MB/" $CONF_FILE
	
	local SCS=$(get_standard_conforming_strings)
	if [ "$SCS" != "" ]; then
		echo $SCS
		sed -i "s/#standard_conforming_strings = on/standard_conforming_strings = off/" $CONF_FILE
	fi
}

enable_remote_connections(){
	sed -i "s/127.0.0.1\/32/0.0.0.0\/0/" /var/lib/pgsql/data/pg_hba.conf
	sed -i "s/ident/trust/" /var/lib/pgsql/data/pg_hba.conf
}

create_db(){
	DB_NAME=$1
	DB_USER=$2
	DB_PASSWORD=$3
	su -c "cd ; /usr/bin/pg_ctl start -w -m fast -D /var/lib/pgsql/data" postgres
	su -c "cd ; /usr/bin/psql --command \"CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD'; \" " postgres
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
init_hive_metastore metastore hiveuser "/usr/lib/hive/scripts/metastore/upgrade/postgres/hive-schema-0.12.0.postgres.sql"
restart_db


