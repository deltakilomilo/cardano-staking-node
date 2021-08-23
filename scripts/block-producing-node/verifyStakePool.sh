#!/bin/bash

# Verifies that stake pool is on blockchain
# NOTE: expects "stakepoolid.txt" to be in current working dir (comes from air gapped env, getStakePoolId.sh)
if [ $NODE_CONFIG = 'mainnet' ]
then
cardano-cli query stake-snapshot --stake-pool-id $(cat stakepoolid.txt) --mainnet 
else
cardano-cli query stake-snapshot --stake-pool-id $(cat stakepoolid.txt) --testnet-magic 1097911063
fi