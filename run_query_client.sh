#!/usr/bin/env bash

SERVERS=localhost

# This script assumes voltdb/bin is in your path
VOLTDB_HOME=$(dirname $(dirname "$(which voltdb)"))

# entire script runs within this directory:
cd client

# clean
rm -rf obj log loader_logs

# set the classpath
CLASSPATH=`ls -1 $VOLTDB_HOME/voltdb/voltdb-*.jar`
if [ ! -f $CLASSPATH ]; then
    echo "voltdb-*.jar file not found for CLASSPATH, edit this script to provide the correct path"
    exit
fi
# the VoltDB client uses google guava
CLASSPATH="$CLASSPATH:`ls -1 $VOLTDB_HOME/lib/guava-*.jar`"
# the benchmark uses Apache commons CLI
CLASSPATH="$CLASSPATH:`ls -1 $VOLTDB_HOME/lib/commons-cli-*.jar`"

# compile
mkdir -p obj
SRC=`find src -name "*.java"`
javac -classpath $CLASSPATH -d obj $SRC
# stop if compilation fails
if [ $? != 0 ]; then exit; fi

# run the benchmark application
echo "running benchmark..."
java -classpath obj:$CLASSPATH:obj -Dlog4j.configuration=file://$VOLTDB_HOME/voltdb/log4j.xml \
    client.QueryBenchmark \
    --displayinterval=5 \
    --warmup=5 \
    --duration=60 \
    --servers=$SERVERS \
    --ratelimit=10000 \
    --autotune=true \
    --latencytarget=1 \
    --queryname=AdvertiserSummary
#    --queryname=advertiser_summary

