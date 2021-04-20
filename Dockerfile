FROM ubuntu:18.04
#TODO - use alpine or smaller Ubuntu installation

# Build args
## Can be mainnet|testnet
ARG NODE_CONFIG=testnet
ARG HOME_DIR=/root
## Can be block-producer|relay|air-gapped
ARG NODE_TYPE=block-producer
# TODO - args for versions of software (ghc version, cabal version, etc.)

# Environment
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="$HOME_DIR/.local/bin:$PATH"
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"
ENV NODE_HOME="$HOME_DIR/cardano-node-home"
ENV NODE_CONFIG=${NODE_CONFIG}
ENV NODE_TYPE=${NODE_TYPE}
ENV NODE_BUILD_NUM="$(curl https://hydra.iohk.io/job/Cardano/iohk-nix/cardano-deployment/latest-finished/download/1/index.html | grep -e \"build\" | sed 's/.*build\/\([0-9]*\)\/download.*/\1/g')"

# Dependencies
RUN apt-get update
RUN apt-get install -y automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf 
# TODO: add curl to list above 

# Downloading, unpacking, installing and updating Cabal
WORKDIR /src/cabal
RUN wget https://downloads.haskell.org/~cabal/cabal-install-3.4.0.0/cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz
RUN tar -xf cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz
RUN rm cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz
RUN mkdir -p $HOME/.local/bin
RUN mv cabal $HOME/.local/bin/
RUN ls -la $HOME/.local/bin/
RUN echo $PATH
RUN cabal update
RUN cabal --version

# Downloading and installing GHC
WORKDIR /src/ghc
RUN wget https://downloads.haskell.org/~ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz
RUN tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz
RUN rm ghc-8.10.2-x86_64-deb9-linux.tar.xz
WORKDIR /src/ghc/ghc-8.10.2
RUN ./configure 
RUN make install

# Install Libsodium
WORKDIR /src
RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR /src/libsodium
RUN pwd
RUN ls -lau
RUN git checkout 66f017f1
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# Downloading the source code for cardano-node
WORKDIR /src
RUN git clone https://github.com/input-output-hk/cardano-node.git
WORKDIR /src/cardano-node
RUN git fetch --all --recurse-submodules --tags
RUN git checkout tags/1.26.1

# Explicitly set GHC version
RUN cabal configure --with-compiler=ghc-8.10.2
# Update the local project file to use the VRF library that you installed earlier.
RUN echo "package cardano-crypto-praos" >>  cabal.project.local
RUN echo "flags: -external-libsodium-vrf" >>  cabal.project.local

# Building and installing the node
## RUN cabal build cardano-cli cardano-node
RUN cabal install --installdir $HOME/.local/bin cardano-cli cardano-node
## Check master node installation 
RUN cardano-cli --version

# Configuration
WORKDIR ${NODE_HOME}
RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-config.json
RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-byron-genesis.json
RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-shelley-genesis.json
RUN wget https://hydra.iohk.io/job/Cardano/cardano-node/cardano-deployment/latest-finished/download/1/${NODE_CONFIG}-topology.json

# Edit config file
RUN sed -i ${NODE_CONFIG}-config.json \
    -e "s/TraceBlockFetchDecisions\": false/TraceBlockFetchDecisions\": true/g"

# Install gLiveView for monitoring
WORKDIR /src/gLiveView
RUN apt install bc tcptraceroute curl -y
RUN curl -s -o gLiveView.sh https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/gLiveView.sh
RUN curl -s -o env https://raw.githubusercontent.com/cardano-community/guild-operators/master/scripts/cnode-helper-scripts/env
RUN chmod 755 gLiveView.sh

# Configure daemons
WORKDIR /etc/systemd/system/
COPY daemons/services .
RUN chmod 644 .
COPY daemons/${NODE_TYPE}-node.service /etc/systemd/system/cardano-${NODE_TYPE}-node.service

# Configure db location and create socket
RUN mkdir -p /var/cardano-node/db
RUN touch /var/cardano-node/db/socket/node.socket

# Configure topology
WORKDIR ${NODE_HOME}/config
COPY config .
RUN chmod +x config-ips.sh

# Copy over key gen and cert scripts
WORKDIR ${NODE_HOME}/key-gen
COPY key-gen .
RUN chmod +x .

# Expose ports for relay node and block producer node
EXPOSE 6000 3001