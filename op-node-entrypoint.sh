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
  --p2p.bootnodes=enr:"-J-4QM3GLUFfKMSJQuP1UvuKQe8DyovE7Eaiit0l6By4zjTodkR4V8NWXJxNmlg8t8rP-Q-wp3jVmeAOml8cjMj__ROGAYznzb_HgmlkgnY0gmlwhA-cZ_eHb3BzdGFja4X947FQAIlzZWNwMjU2azGhAiuDqvB-AsVSRmnnWr6OHfjgY8YfNclFy9p02flKzXnOg3RjcIJ2YYN1ZHCCdmE,enr:-J-4QDCVpByqQ8nFqCS9aHicqwUfXgzFDslvpEyYz19lvkHLIdtcIGp2d4q5dxHdjRNTO6HXCsnIKxUeuZSPcEbyVQCGAYznzz0RgmlkgnY0gmlwhANiQfuHb3BzdGFja4X947FQAIlzZWNwMjU2azGhAy3AtF2Jh_aPdOohg506Hjmtx-fQ1AKmu71C7PfkWAw9g3RjcIJ2YYN1ZHCCdmE"

