# Node devops for op-node chains

1) Add `genesis.json` and `rollup.json` for the desired chain to workspace root directory.
2) Set the chain name in `.env`. This is used to namespace the docker compose project.
3) Run `make start`

Expects that an Eth Mainnet node is running on the same host machine, with L1 execution RPC served on port 8545, and L1 consensus RPC served on port 5052.

## Required Ports

30305 TCP/UDP - Op-Reth P2P
9005 TCP/UDP - Op-Node P2P
