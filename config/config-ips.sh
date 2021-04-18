#!/bin/bash
# Substitutes IP addresses with real values in topology files
if [ $NODE_TYPE = "relay" ]
then
    sed -i ${NODE_HOME}/config/${NODE_CONFIG}-topology.json -e "s/<BLOCK PRODUCER NODE PUBLIC IP ADDRESS>/${BLOCK_PRODUCER_IP:-0.0.0.0}/g"
elif [ $NODE_TYPE = "block-producer" ]
then
    sed -i ${NODE_HOME}/config/${NODE_CONFIG}-topology.json -e "s/<RELAYNODE PUBLIC IP ADDRESS>/${RELAY_IP:-0.0.0.0}/g"
else
    echo "This node type does not require IP address substitution. Skipping..."
fi
