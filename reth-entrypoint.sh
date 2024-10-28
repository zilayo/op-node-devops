#!/bin/sh
set -eu
RETH_DATA_DIR=/chain_data/data
CONFIG_PATH="./reth.toml"
GENESIS_PATH="./genesis.json"

export RUST_LOG="${RETH_LOG_LEVEL}"
export RUST_LOG_TARGET=1

mkdir -p $RETH_DATA_DIR

echo "Checking if /chain_data/jwt.txt exists..."
if [ ! -f /chain_data/jwt.txt ]; then
  echo "File /chain_data/jwt.txt does not exist, generating random jwt.txt"
  openssl rand -hex 32 | tr -d '\n' >/chain_data/jwt.txt # op node has access to the same file
else
  echo "File /chain_data/jwt.txt already exists"
fi

exec op-reth node \
  --engine.experimental \
  --config="$CONFIG_PATH" \
  --chain="$GENESIS_PATH" \
  --rollup.sequencer-http "$SEQUENCER_URL" \
  --rollup.disable-tx-pool-gossip \
  --datadir="$RETH_DATA_DIR" \
  --http \
  --http.corsdomain="*" \
  --http.addr="0.0.0.0" \
  --http.port="9545" \
  --http.api="web3,debug,eth,net,trace" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port="8551" \
  --authrpc.jwtsecret="/chain_data/jwt.txt" \
  --ws \
  --ws.addr="0.0.0.0" \
  --ws.port="9546" \
  --ws.origins="*" \
  --ws.api="debug,eth,net,trace" \
  --metrics="0.0.0.0:5060" \
  --port="30305" \
  --discovery.port="30305" \
  --log.file.directory="/chain_data/reth-logs/" \
  --log.file.filter="debug" \
  --log.file.format="json" \
  --log.file.max-files="10" \
  --nat="extip:0.0.0.0" \
  --rpc-max-response-size="300" \
  --bootnodes="$EXECUTION_BOOTNODES"
