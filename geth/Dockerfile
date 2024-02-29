FROM blastio/blast-geth:mainnet as geth

RUN apk add --no-cache openssl bash curl

COPY ./geth-entrypoint.sh .
RUN chmod +x geth-entrypoint.sh
COPY ./genesis.json .

ENTRYPOINT ["./geth-entrypoint.sh"]