#!/bin/sh
set -eu

L1_RPC_URL="http://host.docker.internal:8545"
L1_BEACON_URL="http://host.docker.internal:5052"
L2_ENGINE_URL="http://geth:8551"

until [ "$(curl -s -w '%{http_code}' -o /dev/null ${L2_ENGINE_URL})" -eq 401 ]; do
  echo "waiting for geth to be ready"
  sleep 5
done

PUBLIC_IP=$(curl -s v4.ident.me)

exec op-node \
  --l2.jwt-secret="/base/jwt.txt" \
  --l1="${L1_RPC_URL}" \
  --l1.trustrpc=true \
  --l1.beacon="${L1_BEACON_URL}" \
  --l2="${L2_ENGINE_URL}" \
  --metrics.enabled=true \
  --metrics.addr="0.0.0.0" \
  --metrics.port="5065" \
  --rpc.addr="0.0.0.0" \
  --rpc.port="9550" \
  --p2p.advertise.ip=${PUBLIC_IP} \
  --p2p.listen.ip="0.0.0.0" \
  --p2p.listen.tcp="9005" \
  --p2p.listen.udp="9005" \
  --rollup.config="./rollup.json" \
  --verifier.l1-confs=4 \
  --rollup.load-protocol-versions=true \
  --p2p.bootnodes="enr:-J24QNz9lbrKbN4iSmmjtnr7SjUMk4zB7f1krHZcTZx-JRKZd0kA2gjufUROD6T3sOWDVDnFJRvqBBo62zuF-hYCohOGAYiOoEyEgmlkgnY0gmlwhAPniryHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQKNVFlCxh_B-716tTs-h1vMzZkSs1FTu_OYTNjgufplG4N0Y3CCJAaDdWRwgiQG,enr:-J24QH-f1wt99sfpHy4c0QJM-NfmsIfmlLAMMcgZCUEgKG_BBYFc6FwYgaMJMQN5dsRBJApIok0jFn-9CS842lGpLmqGAYiOoDRAgmlkgnY0gmlwhLhIgb2Hb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJ9FTIv8B9myn1MWaC_2lJ-sMoeCDkusCsk4BYHjjCq04N0Y3CCJAaDdWRwgiQG,enr:-J24QDXyyxvQYsd0yfsN0cRr1lZ1N11zGTplMNlW4xNEc7LkPXh0NAJ9iSOVdRO95GPYAIc6xmyoCCG6_0JxdL3a0zaGAYiOoAjFgmlkgnY0gmlwhAPckbGHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQJwoS7tzwxqXSyFL7g0JM-KWVbgvjfB8JA__T7yY_cYboN0Y3CCJAaDdWRwgiQG,enr:-J24QHmGyBwUZXIcsGYMaUqGGSl4CFdx9Tozu-vQCn5bHIQbR7On7dZbU61vYvfrJr30t0iahSqhc64J46MnUO2JvQaGAYiOoCKKgmlkgnY0gmlwhAPnCzSHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQINc4fSijfbNIiGhcgvwjsjxVFJHUstK9L1T8OTKUjgloN0Y3CCJAaDdWRwgiQG,enr:-J24QG3ypT4xSu0gjb5PABCmVxZqBjVw9ca7pvsI8jl4KATYAnxBmfkaIuEqy9sKvDHKuNCsy57WwK9wTt2aQgcaDDyGAYiOoGAXgmlkgnY0gmlwhDbGmZaHb3BzdGFja4OFQgCJc2VjcDI1NmsxoQIeAK_--tcLEiu7HvoUlbV52MspE0uCocsx1f_rYvRenIN0Y3CCJAaDdWRwgiQG"