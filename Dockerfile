FROM ubuntu:18.04

# Args
## Should be set to the result of $(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e "build" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')
ARG NODE_BUILD_NUM="7189190"

# Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="$HOME/.local/bin:$HOME/.cabal/bin:/root/.ghcup/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
# Set credentials locations
ENV KES="${NODE_HOME}/kes.skey"
ENV VRF="${NODE_HOME}/vrf.skey"
ENV CERT="${NODE_HOME}/node.cert"
# Node config
ENV NODE_HOME=$HOME/cardano-node-home
ENV NODE_BUILD_NUM=${NODE_BUILD_NUM}

# Dependencies
RUN apt-get update -y 
RUN apt-get upgrade -y 
RUN apt-get install git jq bc make automake rsync htop curl build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ wget libncursesw5 libtool autoconf -y

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
RUN wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/testnet-byron-genesis.json
RUN wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/testnet-topology.json
RUN wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/testnet-shelley-genesis.json
RUN wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/testnet-config.json
RUN wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-byron-genesis.json
RUN wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-topology.json
RUN wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-shelley-genesis.json
RUN wget -N https://hydra.iohk.io/build/${NODE_BUILD_NUM}/download/1/mainnet-config.json

# Edit config file
RUN sed -i testnet-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
RUN sed -i mainnet-config.json -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"
# Set DB socket path
ENV CARDANO_NODE_SOCKET_PATH="$NODE_HOME/db/socket"

# Configure topology
WORKDIR ${NODE_HOME}/config
COPY config .
RUN chmod +x configIPs.sh

# Install gLiveView for monitoring
WORKDIR ${NODE_HOME}
RUN apt install bc tcptraceroute -y
RUN curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
RUN curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
RUN chmod 755 gLiveView.sh
# Change env
RUN sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/testnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
RUN sed -i env \
    -e "s/\#CONFIG=\"\${CNODE_HOME}\/files\/config.json\"/CONFIG=\"\${NODE_HOME}\/mainnet-config.json\"/g" \
    -e "s/\#SOCKET=\"\${CNODE_HOME}\/sockets\/node0.socket\"/SOCKET=\"\${NODE_HOME}\/db\/socket\"/g"
# TODO: Remove this
# # Configure db location and create socket
# RUN mkdir -p /var/cardano-node/db/socket
# RUN touch /var/cardano-node/db/socket/node.socket

# Entrypoints
WORKDIR /
COPY services/startBlockProducingNode.sh . 
COPY services/startRelayNode1.sh .
RUN chmod +x startBlockProducingNode.sh 
RUN chmod +x startRelayNode1.sh 


# Expose ports for relay node and block producer node
EXPOSE 6000 3001