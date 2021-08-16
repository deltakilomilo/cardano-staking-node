#!/bin/bash
# Starts a Cardano block-producer node service

echo "Configuring IPs in topology files..."
${NODE_HOME}/config/configIPs.sh

if [ (-e "$KES") && (-e "$VRF") && (-e "$CERT") ]
then
    echo "Keys/certs found. Starting Cardano node with full configuration"
    DIRECTORY=$NODE_HOME
    PORT=6000
    HOSTADDR=0.0.0.0
    TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
    DB_PATH=\${DIRECTORY}/db
    SOCKET_PATH=\${DIRECTORY}/db/socket
    CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
    /usr/local/bin/cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG} --shelley-kes-key \${KES} --shelley-vrf-key \${VRF} --shelley-operational-certificate \${CERT}
else
    echo "No keys/certs present yet. Starting Cardano node with minimal configuration"
    DIRECTORY=$NODE_HOME
    PORT=6000
    HOSTADDR=0.0.0.0
    TOPOLOGY=\${DIRECTORY}/${NODE_CONFIG}-topology.json
    DB_PATH=\${DIRECTORY}/db
    SOCKET_PATH=\${DIRECTORY}/db/socket
    CONFIG=\${DIRECTORY}/${NODE_CONFIG}-config.json
    /usr/local/bin/cardano-node run --topology \${TOPOLOGY} --database-path \${DB_PATH} --socket-path \${SOCKET_PATH} --host-addr \${HOSTADDR} --port \${PORT} --config \${CONFIG}
fi