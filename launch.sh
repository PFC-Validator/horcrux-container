#!/bin/bash
CHAIN_ID=$1
POD_NAME=$(hostname)
ORDINAL_INDEX=${POD_NAME##*-}
CHAIN=${POD_NAME%%-*}
echo "Chain $CHAIN Ordinal Index: $ORDINAL_INDEX"

mkdir ${HOME}/.horcrux
horcrux config init --node "tcp://${CHAIN}-${ORDINAL_INDEX}.${CHAIN}:1234"  \
       	--cosigner "tcp://${CHAIN}-horcrux-0.${CHAIN}-horcrux:2222" \
       	--cosigner "tcp://${CHAIN}-horcrux-1.${CHAIN}-horcrux:2222" \
       	--cosigner "tcp://${CHAIN}-horcrux-2.${CHAIN}-horcrux:2222" \
	--debug-addr 0.0.0.0:6001 \
	--home ${HOME}/.horcrux --threshold 2 --grpc-timeout 1000ms --raft-timeout 1000ms


cp /run/sign/ecies_keys.json ${HOME}/.horcrux/ecies_keys.json
cp /run/sign/shard.json ${HOME}/.horcrux/${CHAIN_ID}_shard.json

ls ${HOME}/.horcrux
cat ${HOME}/.horcrux/config.yaml
/bin/horcrux start --home=${HOME}/.horcrux


