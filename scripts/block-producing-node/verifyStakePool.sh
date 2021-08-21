#!/bin/bash

# Verifies that stake pool is on blockchain
# NOTE: expects "stakepoolid.txt" to be in current working dir (comes from air gapped env, getStakePoolId.sh)
# TODO testnet/mainnet
cardano-cli query stake-snapshot --stake-pool-id $(cat stakepoolid.txt) --mainnet 