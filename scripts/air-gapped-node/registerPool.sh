#!/bin/bash

# Create a registration certificate for your stake pool. Update with your metadata URL and your relay node information.
# NOTE: Make sure to address your pledge amount and pool cost, margin params etc. accordingly. 
# NOTE: Be sure to replace --single-host-pool-relay with your relay configuration (Use https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#12-register-your-stake-pool as a guide).
# NOTE: Be sure to enter metadata-url where your poolMetaData.json can be located
if [ $NODE_CONFIG = 'mainnet' ]
then
cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000 \
    --pool-cost 345000000 \
    --pool-margin 0.15 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --mainnet \
    --single-host-pool-relay <dns based relay, example ~ relaynode1.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
    --metadata-url <url where you uploaded poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
else
cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000 \
    --pool-cost 345000000 \
    --pool-margin 0.15 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --testnet-magic 1007911063 \
    --single-host-pool-relay <dns based relay, example ~ relaynode1.myadapoolnamerocks.com> \
    --pool-relay-port 6000 \
    --metadata-url <url where you uploaded poolMetaData.json> \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
fi

# Create cert (Copy pool.cert to the block producing node)
cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --cold-verification-key-file node.vkey \
    --out-file deleg.cert