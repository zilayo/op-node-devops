#!/bin/sh
set -eu
VERBOSITY=3
GETH_DATA_DIR=/base/data
GETH_CHAINDATA_DIR="${GETH_DATA_DIR}/geth/chaindata"
GENESIS_FILE_PATH="${GENESIS_FILE_PATH:-/genesis.json}"

mkdir -p $GETH_DATA_DIR

echo "Checking if /base/jwt.txt exists..."
if [ ! -f /base/jwt.txt ]; then
    echo "File /base/jwt.txt does not exist, generating random jwt.txt"
    openssl rand -hex 32 | tr -d '\n' > /base/jwt.txt # op node has access to the same file
else
    echo "File /base/jwt.txt already exists"
fi

if [ ! -d "$GETH_CHAINDATA_DIR" ]; then
	echo "$GETH_CHAINDATA_DIR missing, running geth init"
	echo "Initializing genesis."
	geth --verbosity="$VERBOSITY" init \
		--datadir="$GETH_DATA_DIR" \
    --state.scheme=path \
		"$GENESIS_FILE_PATH"
else
	echo "$GETH_CHAINDATA_DIR exists."
fi

exec ./geth \
    --datadir="$GETH_DATA_DIR" \
    --network="base-mainnet" \
    --verbosity="$VERBOSITY" \
    --http \
    --http.corsdomain="*" \
    --http.vhosts="*" \
    --http.addr="0.0.0.0" \
    --http.port="9545" \
    --http.api="web3,debug,eth,net,engine" \
    --authrpc.addr="0.0.0.0" \
    --authrpc.port="8551" \
    --authrpc.vhosts="*" \
    --authrpc.jwtsecret="/base/jwt.txt" \
    --ws \
    --ws.addr="0.0.0.0" \
    --ws.port="9546" \
    --ws.origins="*" \
    --ws.api="debug,eth,net,engine" \
    --metrics \
    --metrics.addr="0.0.0.0" \
    --metrics.port="5060" \
    --syncmode="snap" \
    --gcmode="archive" \
    --state.scheme="path" \
    --maxpeers="200" \
    --rollup.disabletxpoolgossip=true \
    --rollup.sequencerhttp="https://mainnet-sequencer.base.org" \
    --rollup.halt="major" \
    --port="30305" \
    --discovery.port="30305" \
    --log.file="/base/geth-logs/gethlog.log" \
    --log.rotate="true" \
    --bootnodes="enode://87a32fd13bd596b2ffca97020e31aef4ddcc1bbd4b95bb633d16c1329f654f34049ed240a36b449fda5e5225d70fe40bc667f53c304b71f8e68fc9d448690b51@3.231.138.188:30301,enode://ca21ea8f176adb2e229ce2d700830c844af0ea941a1d8152a9513b966fe525e809c3a6c73a2c18a12b74ed6ec4380edf91662778fe0b79f6a591236e49e176f9@184.72.129.189:30301,enode://acf4507a211ba7c1e52cdf4eef62cdc3c32e7c9c47998954f7ba024026f9a6b2150cd3f0b734d9c78e507ab70d59ba61dfe5c45e1078c7ad0775fb251d7735a2@3.220.145.177:30301,enode://8a5a5006159bf079d06a04e5eceab2a1ce6e0f721875b2a9c96905336219dbe14203d38f70f3754686a6324f786c2f9852d8c0dd3adac2d080f4db35efc678c5@3.231.11.52:30301,enode://cdadbe835308ad3557f9a1de8db411da1a260a98f8421d62da90e71da66e55e98aaa8e90aa7ce01b408a54e4bd2253d701218081ded3dbe5efbbc7b41d7cef79@54.198.153.150:30301"