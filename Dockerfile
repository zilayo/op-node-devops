# Build the op-geth layer
FROM golang:1.21 as geth

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/op-geth.git
ENV VERSION=v1.101308.2
ENV COMMIT=0402d543c3d0cff3a3d344c0f4f83809edb44f10

RUN git clone $REPO --branch $VERSION --single-branch . && \
  git switch -c branch-$VERSION && \
  bash -c '[ "$(git rev-parse HEAD)" = "$COMMIT" ]'

RUN go run build/ci.go install -static ./cmd/geth

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
FROM golang:1.21

RUN apt-get update && \
  apt-get install -y jq curl openssl bash && \
  rm -rf /var/lib/apt/lists

COPY ./op-node-entrypoint.sh .
RUN chmod +x op-node-entrypoint.sh
COPY ./geth-entrypoint.sh .
RUN chmod +x geth-entrypoint.sh
COPY ./genesis.json .
COPY ./rollup.json .
COPY --from=op-node /app/op-node/bin/op-node ./
COPY --from=geth /app/build/bin/geth ./