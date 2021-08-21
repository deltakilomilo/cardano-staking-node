#!/bin/bash

# Gets current slot

if [ $NODE_CONFIG = 'mainnet' ]
then
echo $(cardano-cli query tip --mainnet | jq -r '.slot')
else
echo $(cardano-cli query tip --testnet-magic 1097911063 | jq -r '.slot')
fi