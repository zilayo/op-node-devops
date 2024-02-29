FROM blastio/blast-optimism:mainnet as op-node

RUN apt-get update && apt-get install -y openssl bash

COPY ./op-node-entrypoint.sh .
RUN chmod +x op-node-entrypoint.sh
COPY ./rollup.json .

ENTRYPOINT ["./op-node-entrypoint.sh"]