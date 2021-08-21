#!/bin/bash

# Queries protocol params and outputs to params.json
# NOTE: To be run in $NODE_HOME directory

if [ $NODE_CONFIG = 'mainnet' ]
then
cardano-cli query protocol-parameters \
    --mainnet \
    --out-file params.json
else
cardano-cli query protocol-parameters \
    --testnet-magic 1097911063 \
    --out-file params.json
fi