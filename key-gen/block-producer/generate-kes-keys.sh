#!/bin/bash
# Stake pool HOT key (keys.skey)
# For generating KES key on the block producing node. Must be run every 90 days

mkdir -p $NODE_HOME/hot-keys
cd $NODE_HOME/hot-keys
cardano-cli node key-gen-KES \
    --verification-key-file kes.vkey \
    --signing-key-file kes.skey