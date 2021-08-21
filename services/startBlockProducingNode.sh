#!/bin/bash
# Starts a Cardano block-producer node service

echo "Run configuration..."
/config.sh

# Set variables
DIRECTORY=$NODE_HOME
PORT=6000
HOSTADDR=0.0.0.0
TOPOLOGY="${DIRECTORY}/${NODE_CONFIG}-topology.json"
DB_PATH="${DIRECTORY}/db"
SOCKET_PATH="${DIRECTORY}/db/socket"
CONFIG="${DIRECTORY}/${NODE_CONFIG}-config.json"

if [[ -e "$KES" && -e "$VRF" && -e "$CERT" ]]
then
    echo "Keys/certs found. Starting Cardano node with full configuration"
    /usr/local/bin/cardano-node run --topology $TOPOLOGY --database-path $DB_PATH --socket-path $SOCKET_PATH --host-addr $HOSTADDR --port $PORT --config $CONFIG --shelley-kes-key $KES --shelley-vrf-key $VRF --shelley-operational-certificate $CERT
else
    echo "No keys/certs present yet. Starting Cardano node with minimal configuration"
    /usr/local/bin/cardano-node run --topology $TOPOLOGY --database-path $DB_PATH --socket-path $SOCKET_PATH --host-addr $HOSTADDR --port $PORT --config $CONFIG
fi