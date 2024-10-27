#!/bin/sh
set -eu

L1_RPC_URL="http://host.docker.internal:8545"
L1_BEACON_URL="http://host.docker.internal:5052"
L2_ENGINE_URL="ws://op-reth:8551"

PUBLIC_IP=$(curl -s v4.ident.me)
# TODO check the --network flag
exec op-node \
  --log.level="info" \
  --l2.jwt-secret="/chain_data/jwt.txt" \
  --l1="${L1_RPC_URL}" \
  --l1.trustrpc=true \
  --l1.beacon="${L1_BEACON_URL}" \
  --l2="${L2_ENGINE_URL}" \
  --metrics.enabled=true \
  --metrics.addr="0.0.0.0" \
  --metrics.port="5065" \
  --rpc.addr="0.0.0.0" \
  --rpc.port="9550" \
  --p2p.advertise.ip="${PUBLIC_IP}" \
  --p2p.listen.ip="0.0.0.0" \
  --p2p.listen.tcp="9005" \
  --p2p.listen.udp="9005" \
  --rollup.config="./rollup.json" \
  --verifier.l1-confs=4 \
  --rollup.load-protocol-versions=true \
  --syncmode "execution-layer" \
  --p2p.bootnodes="$CONSENSUS_BOOTNODES" \
  --l2.enginekind="reth" \
  --p2p.discovery.path="/chain_data/op_node_discovery" \
  --p2p.peerstore.path="/chain_data/op_node_peerstore" \
  --p2p.priv.path="/chain_data/p2p_priv.txt"
