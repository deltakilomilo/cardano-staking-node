#!/bin/bash

# Queries unspent transactions (UTXO) for the payment address

if [ $NODE_CONFIG = 'mainnet' ]å
then
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet
else
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 1097911063
fi