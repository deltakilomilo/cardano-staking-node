#!/bin/bash
# Generates the node.cert
# To be run on an air gapped machine
# NOTE: Requires START_KES_PERIOD as input args to be set or will error out

if [ -z "$0" ]
then
    echo "START_KES_PERIOD not set; Exiting..."
    exit 1
else
    cardano-cli node issue-op-cert \
        --kes-verification-key-file kes.vkey \
        --cold-signing-key-file $NODE_HOME/cold-keys/node.skey \
        --operational-certificate-issue-counter $NODE_HOME/cold-keys/node.counter \
        --kes-period $0 \
        --out-file node.cert
fi