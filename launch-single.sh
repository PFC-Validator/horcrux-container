#!/bin/bash
# Single node. intended for testnets
CHAIN_ID=$1
POD_NAME=$(hostname)
CHAIN=${POD_NAME%%-*}
echo "Chain $CHAIN Single Node"

mkdir ${HOME}/.horcrux
horcrux config init --node "tcp://${CHAIN}-0.${CHAIN}:1234"  \
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
