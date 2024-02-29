FROM blastio/blast-geth:mainnet as geth

COPY ./geth-entrypoint.sh .
RUN chmod +x geth-entrypoint.sh
COPY ./genesis.json .

ENTRYPOINT ["./geth-entrypoint.sh"]