#!/bin/bash
# Generates a VRF key pair
# To be run on the block-producer node

mkdir -p $NODE_HOME/hot-keys
cd $NODE_HOME/hot-keys
cardano-cli node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey
chmod 400 vrf.skey