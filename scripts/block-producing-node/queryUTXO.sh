#!/bin/bash

# Queries unspent transactions (UTXO) for the payment address

cardano-cli query utxo \
    --address $(cat payment.addr) \
    --${NODE_CONFIG}