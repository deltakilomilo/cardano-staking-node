#!/bin/bash

# Fetches your relay node buddies and updates your topology file
# NOTE: To be run on relay node(s) ONLY!
# NOTE: Wait at least 4 hours after relay node IP is properly registered
# NOTE: Restart after running

BLOCK_PRODUCER_PORT=6000
if [ $NODE_CONFIG = 'mainnet' ]
then
echo "Running topology pull for mainnet"
URL="https://api.clio.one/htopology/v1/fetch/?max=20&customPeers=${BLOCK_PRODUCER_IP}:${BLOCK_PRODUCER_PORT}:1|relays-new.cardano-mainnet.iohk.io:3001:2"
echo $URL
curl -s -o $NODE_HOME/${NODE_CONFIG}-topology.json $URL
else
echo "Running topology pull for testnet"
URL="https://api.clio.one/htopology/v1/fetch/?max=20&magic=1097911063&customPeers=${BLOCK_PRODUCER_IP}:${BLOCK_PRODUCER_PORT}:1|relays-new.cardano-testnet.iohkdev.io:3001:2"
echo $URL
curl -s -o $NODE_HOME/${NODE_CONFIG}-topology.json $URL
fi
