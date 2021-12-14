#!/bin/bash

# TODO - this doesn't work because there will always be the initial topology file
if [ -f ${NODE_HOME}/${NODE_CONFIG}-topology.json ]
then
echo "Skipping topology configuration..."
else
echo "Run configuration..."
/config.sh
fi

DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY="${DIRECTORY}/${NODE_CONFIG}-topology.json"
DB_PATH="${DIRECTORY}/db"
SOCKET_PATH="${DIRECTORY}/db/socket"
CONFIG="${DIRECTORY}/${NODE_CONFIG}-config.json"
/usr/local/bin/cardano-node run +RTS -N -A16m -qg -qb -RTS --topology $TOPOLOGY --database-path $DB_PATH --socket-path $SOCKET_PATH --host-addr $HOSTADDR --port $PORT --config $CONFIG