# Build the op-reth layers
FROM debian:bullseye-slim as base
RUN apt-get update && apt-get install -y libudev-dev build-essential ca-certificates clang curl git libpq-dev libssl-dev pkg-config lsof lld gcc
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

FROM base as reth-builder
WORKDIR /app
ENV REPO=https://github.com/paradigmxyz/reth.git
ENV VERSION=v1.0.0
ENV COMMIT=83d412da70af678a46f368533b6df45a287a1ce6
RUN git clone $REPO --branch $VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
ENV RUSTFLAGS="-C target-cpu=native"
RUN cargo build --profile maxperf --bin op-reth --features "optimism,jemalloc"

# Build the op-node layer
FROM golang:1.21 as op-node
WORKDIR /app
ENV REPO=https://github.com/ethereum-optimism/optimism.git
ENV VERSION=v1.7.7
ENV COMMIT=f8143c8cbc4cc0c83922c53f17a1e47280673485
RUN git clone $REPO --branch op-node/$VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'
RUN cd op-node && \
  make VERSION=$VERSION op-node

# Build the final layer & copy node binaries
FROM golang:1.21
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