#!/bin/bash

# Issues op certificate to verify that the pool has the authority to run

cardano-cli node issue-op-cert \
    --kes-verification-key-file kes.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter \
    --kes-period <startKesPeriod> \
    --out-file node.cert