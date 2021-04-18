#!/bin/bash
# Starts up Cardano Node
# Requires NODE_TYPE env variable, which takes one of "block-producer"|"relay"
systemctl daemon-reload
systemctl enable cardano-${NODE_TYPE}-node
systemctl status cardano-${NODE_TYPE}-node