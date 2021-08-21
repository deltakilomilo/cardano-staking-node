#!/bin/bash

# Takes signed transaction from air-gapped node and submits it
if [ $NODE_CONFIG = 'mainnet' ]
then
cardano-cli transaction submit \
    --tx-file tx.signed \
    --mainnet
else
cardano-cli transaction submit \
    --tx-file tx.signed \
    --testnet-magic 1097911063
fi