#!/usr/bin/env bash

. ./compile.sh

HOST=localhost

# start database in background
LICENSE=$VOLTDB_HOME/voltdb/license.xml
if [ -f $VOLTDB_HOME/bin/voltdb3 ]; then
    echo "using voltdb3 interface"
    nohup voltdb3 create catalog ${CATALOG_NAME}.jar \
        license $VOLTDB_HOME/voltdb/license.xml host $HOST deployment deployment.xml license $LICENSE > log/nohup.log 2>&1 &
else
    nohup voltdb create catalog ${CATALOG_NAME}.jar \
        license $VOLTDB_HOME/voltdb/license.xml host $HOST deployment deployment.xml license $LICENSE > log/nohup.log 2>&1 &
fi

echo "VoltDB started"
echo 
echo "to monitor the log:"
echo "  tail -f db/log/volt.log"
echo
echo "to stop the database, use the command:"
echo "  voltadmin shutdown"
