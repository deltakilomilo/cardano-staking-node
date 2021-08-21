#!/bin/bash
# Substitutes IP addresses with real values in topology files, other config (gLiveView.sh)
if [ $NODE_TYPE = "relay" ]
then

if [ $NODE_CONFIG = "mainnet" ]
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
else
cat > $NODE_HOME/${NODE_CONFIG}-topology.json << EOF 
 {
    "Producers": [
      {
        "addr": "<BLOCK PRODUCER NODE PUBLIC IP ADDRESS>",
        "port": 6000,
        "valency": 1
      },
      {
        "addr": "relays-new.cardano-testnet.iohkdev.io",
        "port": 3001,
        "valency": 2
      }
    ]
  }
EOF
fi
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

# Configure gLiveView
sed -i $NODE_HOME/env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/\${NODE_CONFIG}-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g" \
    -e "s/\#TOPOLOGY=\"\${CNODE_HOME}\/files\/topology.json\"/TOPOLOGY=\"\${NODE_HOME}\/testnet-config.json\"/g"
