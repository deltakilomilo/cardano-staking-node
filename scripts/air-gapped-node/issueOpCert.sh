#!/bin/bash

# Issues op certificate to verify that the pool has the authority to run
# NOTE: To be run in $NODE_HOME/cold-keys/$NODE_CONFIG

cardano-cli node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file $HOME/cold-keys/node.skey \
    --operational-certificate-issue-counter $HOME/cold-keys/node.counter \
    --kes-period <startKesPeriod> \
    --out-file node.cert