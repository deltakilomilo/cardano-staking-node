#!/bin/bash

# Checks rewards for this node
# To be run after the end of an epoch, assuming you minted rewards

if [ $NODE_CONFIG = 'mainnet' ]
then
cardano-cli query stake-address-info \
 --address $(cat stake.addr) \
 --mainnet
else
cardano-cli query stake-address-info \
 --address $(cat stake.addr) \
 --testnet-magic 1097911063
fi