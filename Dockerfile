FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH "~/.local/bin:$PATH"

# Dependencies
RUN apt-get update
RUN apt-get install -y automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf 

# Downloading, unpacking, installing and updating Cabal
# RUN apt-get install -y cabal-install
RUN wget https://downloads.haskell.org/~cabal/cabal-install-3.4.0.0/cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz
RUN tar -xf cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz
RUN rm cabal-install-3.4.0.0-x86_64-ubuntu-16.04.tar.xz
RUN mkdir -p ~/.local/bin
RUN mv cabal ~/.local/bin/
RUN ls -lau ~/.local/bin/
RUN echo $PATH
RUN ~/.local/bin/cabal update
RUN ~/.local/bin/cabal --version

# # # Downloading and installing GHC
# # RUN apt-get install -y ghc ghc-prof ghc-doc
RUN wget https://downloads.haskell.org/~ghc/8.10.2/ghc-8.10.2-x86_64-deb9-linux.tar.xz
RUN tar -xf ghc-8.10.2-x86_64-deb9-linux.tar.xz
RUN rm ghc-8.10.2-x86_64-deb9-linux.tar.xz
WORKDIR /ghc-8.10.2
RUN ls /
# TODO - problem line
RUN ./configure 
RUN make install

# # Install Libsodium
WORKDIR /
RUN git clone https://github.com/input-output-hk/libsodium
WORKDIR /libsodium
RUN pwd
RUN ls -lau
RUN git checkout 66f017f1
RUN ./autogen.sh
RUN ./configure
RUN make
RUN make install

# Add paths to ENV
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH"

# Downloading the source code for cardano-node
RUN mkdir -p /src
WORKDIR /src
RUN git clone https://github.com/input-output-hk/cardano-node.git
WORKDIR /src/cardano-node
RUN git fetch --all --recurse-submodules --tags
# RUN echo "about to run git tag"
# RUN git tag
RUN git checkout tags/1.26.1

# Explicitly set GHC version
RUN ~/.local/bin/cabal configure --with-compiler=ghc-8.10.2
# Update the local project file to use the VRF library that you installed earlier.
RUN echo "package cardano-crypto-praos" >>  cabal.project.local
RUN echo "flags: -external-libsodium-vrf" >>  cabal.project.local

# Building and installing the node
RUN ls -la
RUN echo "printing LD_LIBRARY_PATH and PKG_CONFIG_PATH"
RUN echo $LD_LIBRARY_PATH
RUN echo $PKG_CONFIG_PATH
# RUN cabal build cardano-cli cardano-node
RUN ~/.local/bin/cabal install --installdir ~/.local/bin cardano-cli cardano-node

# Check master node installation 
RUN ~/.local/bin/cardano-cli --version