FROM ubuntu:18.04

# Args
## Should be set to the result of $(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')
ARG NODE_BUILD_NUM="7926804"

# Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="$HOME/.local/bin:$HOME/.cabal/bin:/root/.ghcup/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
# Node config
ENV NODE_HOME=$HOME/cardano-node-home
ENV NODE_BUILD_NUM=${NODE_BUILD_NUM}
# Set credentials locations
ENV KES="${NODE_HOME}/kes.skey"
ENV VRF="${NODE_HOME}/vrf.skey"
ENV CERT="${NODE_HOME}/node.cert"

# Dependencies
RUN apt-get update -y 
RUN apt-get upgrade -y 
RUN apt-get install git jq bc make automake rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf -y
RUN apt-get install lsof iproute2 nano -y

# Install Libsodium
WORKDIR /src
RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR /src/libsodium
RUN git checkout 66f017f1
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# Downloading, unpacking, installing and updating Cabal
RUN apt-get -y install libncurses-dev libtinfo5
WORKDIR /src/cabal
RUN curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# Downloading and installing GHC
RUN ghcup install ghc 8.10.4
RUN ghcup set ghc 8.10.4

# Update Cabal
RUN cabal update
RUN cabal --version
RUN ghc --version

# Downloading the source code for cardano-node
WORKDIR /src
RUN git clone https://github.com/input-output-hk/cardano-node.git
WORKDIR /src/cardano-node
RUN git fetch --all --recurse-submodules --tags
RUN git checkout $(curl -s https://api.github.com/repos/input-output-hk/cardano-node/releases/latest | jq -r .tag_name)

# Configure Cabal build options
## Explicitly set GHC version
RUN cabal configure --with-compiler=ghc-8.10.4
## Update the cabal config, project settings, and reset build folder.
RUN echo -e "package cardano-crypto-praos\n flags: -external-libsodium-vrf" > cabal.project.local
RUN sed -i $HOME/.cabal/config -e "s/overwrite-policy:/overwrite-policy: always/g"
RUN rm -rf $HOME/git/cardano-node/dist-newstyle/build/x86_64-linux/ghc-8.10.4
## Build the cardano node from source
RUN cabal build cardano-cli cardano-node
# ## Copy cardano-cli and cardano-node files into bin directory.
RUN cp $(find dist-newstyle/build -type f -name "cardano-cli") /usr/local/bin/cardano-cli
RUN cp $(find dist-newstyle/build -type f -name "cardano-node") /usr/local/bin/cardano-node
## Check master node installation 
RUN cardano-node --version
RUN cardano-cli --version

# # Configuration
WORKDIR ${NODE_HOME}
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-config.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-byron-genesis.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-shelley-genesis.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-alonzo-genesis.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/testnet-topology.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-config.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-byron-genesis.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-shelley-genesis.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-alonzo-genesis.json
RUN wget -N https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/mainnet-topology.json

# Edit config file
RUN sed -i testnet-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
RUN sed -i mainnet-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
# Set DB socket path
ENV CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket"

# Configure topology
WORKDIR /
COPY config.sh . 
RUN chmod +x config.sh

# Install gLiveView for monitoring
WORKDIR ${NODE_HOME}
RUN apt install bc tcptraceroute -y
RUN curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
RUN curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
RUN chmod 755 gLiveView.sh


# Entrypoints
WORKDIR /
COPY services/startBlockProducingNode.sh . 
COPY services/startRelayNode1.sh .
RUN chmod +x startBlockProducingNode.sh 
RUN chmod +x startRelayNode1.sh 


# Expose ports for relay node, block producer node, prometheus
EXPOSE 6000 3001 12798

# Scripts
WORKDIR ${NODE_HOME}
COPY scripts/block-producing-node . 
COPY scripts/relay-node . 
RUN chmod +x *.sh