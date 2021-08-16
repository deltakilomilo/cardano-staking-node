#!/bin/bash

# Generates KES keys and determines slots per KES Period
# NOTE: Should be run in $NODE_HOME
# NOTE: Copy kes.vkey to cold environment when finished

cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey

slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
echo slotsPerKESPeriod: ${slotsPerKESPeriod}