# Generate block producer node keys
## On block-producer node
1. Run `$NODE_HOME/key-gen/generate-kes-keys.sh`
2. Run `$NODE_HOME/key-gen/calculate-kes-period.sh`. Note the output value for the next step. NOTE: Before continuing, your node must be fully synchronized to the blockchain. Otherwise, you won't calculate the latest KES period. Your node is synchronized when the epoch and slot# is equal to that found on a block explorer such as https://pooltool.io/

## On air-gapped node
1. Run `$NODE_HOME/key-gen/generate-cold-keys.sh`
2. Back up all keys and the .counter file generated to another secure storage device.
3. Run `$NODE_HOME/key-gen/generate-cert.sh <START_KES_PERIOD>`, where <START_KES_PERIOD> is the value from the previous section. 
4. Copy **node.cert** to the block-producer node environment (specifically to $NODE_HOME/certs)

## Again on block-producer node
1. Run `$NODE_HOME/key-gen/generate-vrf-key-pair.sh`
2. Set the following env variables. 
```bash
export KES=$NODE_HOME/hot-keys/kes.skey;
export VRF=$NODE_HOME/hot-keys/vrf.skey;
export CERT=$NODE_HOME/hot-keys/node.cert;
``` 
3. Restart the server: `systemctl stop cardano-block-producer-node` and then `systemctl start cardano-block-producer-node`
4. Monitor with gLiveView: `./gLiveView.sh`


# Credits
[CoinCashew](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node#9-generate-block-producer-keys)

# Notes
- Need to run dockerfile with a volume that maps to the host, for db, and for the /hot-keys locations
- Need to make sure logs (journalctl?) go to stdout

# Chart
- BLOCK_PRODUCER_IP, RELAY_IP - will load upon redeploy of chart (fetches from values.yaml)
- Servies. One service each for relay and block-producer, each w/ external load balancer IP. NOTE: Should use static LB IP
- K8s cluster should be configured to be private
- Consider eventually having topology as a Helm values file configmap (allows for more than one)

# Questions
- Is it ok to just redeploy, or do we need a safe container shutdown procedure?
- Should we have a single Docker image for all node types? Y
- How big of a bootdisk is needed in the node pool? 256GB

# Next steps
- Cloudbuild CICD to build and push the docker image
- Deployment: block-producer
- Service: Load Balancer IP
- Deployment: relay
- Service: relay - use static IP
- Service account - use static IP
