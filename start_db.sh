#!/usr/bin/env bash

. ./compile.sh


# start database in background
LICENSE=$VOLTDB_HOME/voltdb/license.xml
nohup voltdb create catalog ${CATALOG_NAME}.jar \
    license $VOLTDB_HOME/voltdb/license.xml host localhost deployment deployment.xml license $LICENSE > log/nohup.log 2>&1 &

echo "VoltDB started"
echo 
echo "to monitor the log:"
echo "  tail -f db/log/volt.log"
echo
echo "to stop the database, use the command:"
echo "  voltadmin shutdown"
