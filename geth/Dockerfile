FROM blastio/blast-geth:mainnet as geth

RUN apt-get update && apt-get install -y openssl bash

COPY ./geth-entrypoint.sh .
RUN chmod +x geth-entrypoint.sh
COPY ./genesis.json .

ENTRYPOINT ["./geth-entrypoint.sh"]