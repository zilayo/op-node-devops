#!/bin/sh
set -eu

L1_RPC_URL="http://host.docker.internal:8545"
L2_ENGINE_URL="http://blast-geth:8551"
CHAIN_ID=81457

until [ "$(curl -s -w '%{http_code}' -o /dev/null ${L2_ENGINE_URL})" -eq 401 ]; do
  echo "waiting for geth to be ready"
  sleep 5
done

PUBLIC_IP=$(curl -s v4.ident.me)

exec op-node \
  --l2.jwt-secret="/blast/jwt.txt" \
  --l1="${L1_RPC_URL}" \
  --l1.trustrpc=true \
  --l2="${L2_ENGINE_URL}" \
  --metrics.enabled=true \
  --metrics.addr="0.0.0.0" \
  --metrics.port=7300 \
  --p2p.advertise.ip=${PUBLIC_IP} \
  --p2p.listen.ip="0.0.0.0" \
  --p2p.listen.tcp="9222" \
  --p2p.listen.udp="9222" \
  --snapshotlog.file="/tmp/op-node-snapshot-log" \
  --rollup.config="/rollup.json" \
  --p2p.bootnodes="enr:-J64QGwHl9uYLfC_cnmxSA6wQH811nkOWJDWjzxqkEUlJoZHWvI66u-BXgVcPCeMUmg0dBpFQAPotFchG67FHJMZ9OSGAY3d6wevgmlkgnY0gmlwhANizeSHb3BzdGFja4Sx_AQAiXNlY3AyNTZrMaECg4pk0cskPAyJ7pOmo9E6RqGBwV-Lex4VS9a3MQvu7PWDdGNwgnZhg3VkcIJ2YQ,enr:-J64QDge2jYBQtcNEpRqmKfci5E5BHAhNBjgv4WSdwH1_wPqbueq2bDj38-TSW8asjy5lJj1Xftui6Or8lnaYFCqCI-GAY3d6wf3gmlkgnY0gmlwhCO2D9yHb3BzdGFja4Sx_AQAiXNlY3AyNTZrMaEDo4aCTq7pCEN8om9U5n_VyWdambGnQhwHNwKc8o-OicaDdGNwgnZhg3VkcIJ2YQ"