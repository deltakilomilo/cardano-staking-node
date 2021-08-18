# Cardano Staking Pool Automation
This repo provides a means to automate the steps of setting up and maintaining a Cardano staking node, outlined 
by [CoinCashew](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node). Special credits
to all the contributors of CoinCashew.

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

# Host steps

## Harden Ubuntu server

## Install key dependencies

```bash
apt-get update -y 
apt-get upgrade -y 
apt-get install -y git curl systemd
```

Install Docker for Ubuntu: https://docs.docker.com/engine/install/ubuntu/ (or use image that comes with your cloud platform)

```bash
 curl -fsSL https://get.docker.com -o get-docker.sh
 sh get-docker.sh
```

## Create volume

`docker create volume cardano_node`

## Set env variables

### Network config

```bash
# For testnet: 
export NODE_CONFIG=testnet
# For mainnet:
export NODE_CONFIG=mainnet
```

### Node type and IPs
```bash
# For relay node
export NODE_TYPE=relay
# Put in the external IP address of your relay node
#TODO - should be put in unit file
export RELAY_IP=1.2.3.4

# OR...

# For block-producing node
export NODE_TYPE=block-producing
# Put in the external IP address of your block-producing node
5.6.7.8
```

## Set up systemctl 
```bash
cd /etc/systemd/system
** wget service files from github **
COPY services/cardano-block-producing-node.service .
COPY services/cardano-relay-node.service .
RUN chmod 644 /etc/systemd/system/cardano-block-producing-node.service
RUN chmod 644 /etc/systemd/system/cardano-relay-node.service

# TODO - need to hard code the IPs in .service files
sudo systemctl daemon-reload
sudo systemctl enable cardano-${NODE_TYPE}-node
sudo systemctl start cardano-${NODE_TYPE}-node
sudo systemctl status cardano-${NODE_TYPE}-node
```


# Notes

Only works for 1 relay. 

# TODO - create docker volume

sudo docker exec -it 

Within Docker
`apt-get install iproute2`
`apt-get install lsof`

apt-get install lsof iprouter2 -y