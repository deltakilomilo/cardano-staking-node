#!/bin/bash

# Generates a VRF key pair
# NOTE: To be run in $NODE_HOME directory
# TIP: Run gLiveView after to monitor

cardano-cli node key-gen-VRF \
    --verification-key-file vrf.vkey \
    --signing-key-file vrf.skey

chmod 400 vrf.skey





