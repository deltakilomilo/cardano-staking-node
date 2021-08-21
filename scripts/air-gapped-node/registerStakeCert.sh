#!/bin/bash

# Creates a certificate based on stake.vkey

cardano-cli stake-address registration-certificate \
    --stake-verification-key-file stake.vkey \
    --out-file stake.cert