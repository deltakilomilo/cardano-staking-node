#!/bin/bash
# Substitutes IP addresses with real values in topology files
if [ $NODE_TYPE = "relay" ]
then

cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "<BLOCK PRODUCER NODE PUBLIC IP ADDRESS>",
        "port": 6000,
        "valency": 1
      },
      {
        "addr": "relays-new.cardano-mainnet.iohk.io",
        "port": 3001,
        "valency": 2
      }
    ]
  }
EOF
sed -i ${NODE_HOME}/${NODE_CONFIG}-topology.json -e "s/<BLOCK PRODUCER NODE PUBLIC IP ADDRESS>/${BLOCK_PRODUCER_IP:-0.0.0.0}/g"

elif [ $NODE_TYPE = "block-producer" ]
then

cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "<RELAYNODE PUBLIC IP ADDRESS>",
        "port": 6000,
        "valency": 1
      }
    ]
  }
EOF
sed -i ${NODE_HOME}/${NODE_CONFIG}-topology.json -e "s/<RELAYNODE PUBLIC IP ADDRESS>/${RELAY_IP:-0.0.0.0}/g"

else
echo "This node type does not require IP address substitution. Skipping..."
fi
