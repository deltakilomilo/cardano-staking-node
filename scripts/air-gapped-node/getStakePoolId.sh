#!/bin/bash

# Gets the stake pool ID
# NOTE: Expects to be in the directory that contains node.vkey
cardano-cli stake-pool id --cold-verification-key-file node.vkey --output-format hex > stakepoolid.txt
cat stakepoolid.txt