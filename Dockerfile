# Build the op-reth layers
FROM ghcr.io/paradigmxyz/op-reth:v1.1.1 AS reth

# Build the op-node layer
FROM us-docker.pkg.dev/oplabs-tools-artifacts/images/op-node:v1.9.5 AS op-node

# Build the final layer & copy node binaries
FROM ubuntu:22.04
RUN apt-get update && \
  apt-get install -y jq curl openssl bash ca-certificates lsof && \
  rm -rf /var/lib/apt/lists
COPY ./op-node-entrypoint.sh .
COPY ./reth-entrypoint.sh .
RUN chmod +x reth-entrypoint.sh && chmod +x op-node-entrypoint.sh
COPY ./genesis.json .
COPY ./rollup.json .
COPY ./reth.toml .
COPY --from=op-node /usr/local/bin/op-node /usr/local/bin/op-node
COPY --from=reth /usr/local/bin/op-reth /usr/local/bin/op-reth