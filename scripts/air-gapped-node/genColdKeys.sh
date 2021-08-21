#!/bin/bash

# Generates cold keys
# NOTE: Back up all keys on multiple storage devices (not connected to internet)

cardano-cli node key-gen \
    --cold-verification-key-file node.vkey \
    --cold-signing-key-file node.skey \
    --operational-certificate-issue-counter node.counter