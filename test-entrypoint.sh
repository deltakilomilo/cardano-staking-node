#!/bin/bash

~/.local/bin/cardano-node run \
   --topology /config/testnet-topology.json \
   --database-path /var/cardano-node/db \
   --socket-path /var/cardano-node/db/node.socket \
   --host-addr 127.0.0.1 \
   --port 3001 \
   --config /config/testnet-config.json