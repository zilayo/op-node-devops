# Build the op-reth layers
FROM rust:1.82 AS reth-builder
WORKDIR /app
RUN apt-get update && apt-get -y upgrade && apt-get install -y git libclang-dev pkg-config curl build-essential
ENV REPO=https://github.com/paradigmxyz/reth.git
ENV VERSION=v1.1.0
ENV COMMIT=1ba631ba9581973e7c6cadeea92cfe1802aceb4a
RUN git clone $REPO --branch $VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
ENV RUSTFLAGS="-C target-cpu=native"
RUN cargo build --profile maxperf --bin op-reth --features "optimism,jemalloc,asm-keccak" --manifest-path crates/optimism/bin/Cargo.toml

# Build the op-node layer
FROM golang:1.23.2 AS op-node
WORKDIR /app
ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.9.4
ENV COMMIT=2c24e652161187f3e30045eac1e176e6b53c469d
RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
RUN cd op-node && \
  make VERSION=$VERSION op-node

# Build the final layer & copy node binaries
FROM golang:1.23.2
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
COPY --from=op-node /app/op-node/bin/op-node /usr/local/bin
COPY --from=reth-builder /app/target/maxperf/op-reth /usr/local/bin