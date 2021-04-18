#!/bin/bash
# Create cold keys. To be run on air-gapped machine
# Be sure to back up your all your keys to another secure storage device. Make multiple copies.
mkdir -p $NODE_HOME/cold-keys
cd $NODE_HOME/cold-keys
cardano-cli node key-gen \
    --cold-verification-key-file node.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter