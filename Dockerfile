# Build the op-reth layer
FROM rust:1.82 AS reth
WORKDIR /app
RUN apt-get update && apt-get -y upgrade && apt-get install -y git libclang-dev pkg-config curl build-essential
ENV REPO=https://github.com/zilayo/reth.git
ENV VERSION=zil-dev
ENV RUSTFLAGS="-C target-cpu=native"
RUN git clone $REPO --branch $VERSION --single-branch . && \
  cargo build --bin op-reth --features "optimism,jemalloc,asm-keccak" --manifest-path crates/optimism/bin/Cargo.toml && \
  mv /app/target/debug/op-reth /usr/local/bin/op-reth

# Build the op-node layer
FROM us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:v1.9.4 AS op-node

# Build the final layer & copy node binaries
FROM ubuntu:22.04
RUN apt-get update && \
  apt-get install -y jq curl openssl bash ca-certificates lsof && \
  rm -rf /var/lib/apt/lists
COPY ./op-node-entrypoint.sh .
RUN chmod +x op-node-entrypoint.sh
COPY ./reth-entrypoint.sh .
RUN chmod +x reth-entrypoint.sh
COPY ./genesis.json .
COPY ./rollup.json .
COPY ./reth.toml .
COPY --from=op-node /usr/local/bin/op-node /usr/local/bin/op-node
COPY --from=reth /usr/local/bin/op-reth /usr/local/bin/op-reth