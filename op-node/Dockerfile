FROM blastio/blast-optimism:mainnet as op-node

RUN apk add --no-cache bash curl

COPY ./op-node-entrypoint.sh .
RUN chmod +x op-node-entrypoint.sh
COPY ./rollup.json .

ENTRYPOINT ["./op-node-entrypoint.sh"]