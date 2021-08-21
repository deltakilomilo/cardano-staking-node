#!/bin/bash

# Registers pool with the Cardano network
# NOTE: ticker must be 3-5 chars [A-z0-9], description length must be < 255 chars
# NOTE: customize the below to your liking

# Create metadata json (upload this to your website for public viewing)
cat > poolMetaData.json << EOF
{
"name": "MyPoolName",
"description": "My pool description",
"ticker": "MPN",
"homepage": "https://myadapoolnamerocks.com"
}
EOF

# Create hash (copy output file to air gapped env)
cardano-cli stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt

# Find the min pool cost
minPoolCost=$(cat $NODE_HOME/params.json | jq -r .minPoolCost)
echo minPoolCost: ${minPoolCost}







