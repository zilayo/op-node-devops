# Build the op-reth layers
FROM debian:bullseye-slim as base
RUN apt-get update && apt-get install -y libudev-dev build-essential ca-certificates clang curl git libpq-dev libssl-dev pkg-config lsof lld gcc
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

FROM base as reth-builder
WORKDIR /app
ENV REPO=https://github.com/paradigmxyz/reth.git
ENV VERSION=v0.2.0-beta.5
ENV COMMIT=54f75cdcc82125a97ffd82952c2a8bc8ed324b48
RUN git clone $REPO --branch $VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
ENV RUSTFLAGS="-C target-cpu=native"
RUN cargo build --profile maxperf --bin op-reth --features "optimism,jemalloc,asm-keccak"
RUN cp ./target/maxperf/op-reth /reth/op-reth

# Build the op-node layer
FROM golang:1.21 as op-node
WORKDIR /app
ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.7.1
ENV COMMIT=c87a469d7d679e8a4efbace56c3646b925bcc009
RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
RUN cd op-node && \
  make VERSION=$VERSION op-node

# Build the final layer & copy node binaries
FROM debian:bullseye-slim
RUN apt-get update && \
  apt-get install -y jq curl openssl bash ca-certificates lsof && \
  rm -rf /var/lib/apt/lists
COPY ./op-node-entrypoint.sh .
RUN chmod +x op-node-entrypoint.sh
COPY ./reth-entrypoint.sh .
RUN chmod +x reth-entrypoint.sh
COPY ./genesis.json .
COPY ./rollup.json .
COPY --from=op-node /app/op-node/bin/op-node /usr/local/bin
COPY --from=reth-builder /app/reth/target/maxperf/op-reth /usr/local/bin