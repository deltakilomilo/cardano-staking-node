#!/bin/bash

# Signs an unsigned raw transaction
# NOTE: Expects tx.raw to be present in the current dir, to be copied over from block producing node
# TODO - do cold key version too! See Ubuntu / RaspPi

if [ $NODE_CONFIG = 'mainnet' ]
then
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --mainnet \
    --out-file tx.signed
else
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file stake.skey \
    --testnet-magic 1097911063 \
    --out-file tx.signed
fi