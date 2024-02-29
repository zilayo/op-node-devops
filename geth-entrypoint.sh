#!/bin/sh
set -eu

VERBOSITY=3
GETH_DATA_DIR=/blast/data
GETH_CHAINDATA_DIR="${GETH_DATA_DIR}/geth/chaindata"
GENESIS_FILE_PATH="${GENESIS_FILE_PATH:-/genesis.json}"
ADDITIONAL_ARGS=""
CHAIN_ID=81457

mkdir -p $GETH_DATA_DIR

sh -c "[ ! -f /blast/jwt.txt ] && openssl rand -hex 32 | tr -d '\n' > /blast/jwt.txt"

if [ "${OP_GETH_ETH_STATS+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --ethstats=$OP_GETH_ETH_STATS"
fi

if [ "${OP_GETH_BOOTNODES+x}" = x ]; then
    ADDITIONAL_ARGS="$ADDITIONAL_ARGS --bootnodes=$OP_GETH_BOOTNODES"
fi

if [ ! -d "$GETH_CHAINDATA_DIR" ]; then
	echo "$GETH_CHAINDATA_DIR missing, running init"
	echo "Initializing genesis."
	geth --verbosity="$VERBOSITY" init \
		--datadir="$GETH_DATA_DIR" \
    --state.scheme=path \
		"$GENESIS_FILE_PATH"
else
	echo "$GETH_CHAINDATA_DIR exists."
fi

exec geth \
    --datadir="$GETH_DATA_DIR" \
    --networkid=$CHAIN_ID \
    --verbosity="$VERBOSITY" \
    --http \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.addr=0.0.0.0 \
    --http.port="8545" \
    --http.api=web3,debug,eth,net,engine \
    --authrpc.addr=0.0.0.0 \
    --authrpc.port="8551" \
    --authrpc.vhosts="*" \
    --authrpc.jwtsecret="/blast/jwt.txt" \
    --ws \
    --ws.addr=0.0.0.0 \
    --ws.port="8546" \
    --ws.origins="*" \
    --ws.api=debug,eth,net,engine \
    --metrics \
    --metrics.addr=0.0.0.0 \
    --metrics.port="6060" \
    --syncmode="snap" \
    --state.scheme="path" \
    --maxpeers=100 \
    --rollup.disabletxpoolgossip=true \
    --rollup.sequencerhttp="https://sequencer.blast.io" \
    --port="30303" \
    --log.file="/geth-logs/gethlog.log" \
    --log.rotate="true" \
    $ADDITIONAL_ARGS
