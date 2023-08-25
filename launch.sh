#!/bin/bash
CHAIN_ID=$1
POD_NAME=$(hostname)
ORDINAL_INDEX=${POD_NAME##*-}
CHAIN=${POD_NAME%%-*}
echo "Chain $CHAIN Ordinal Index: $ORDINAL_INDEX"

mkdir ${HOME}/.horcrux
cat > config.yaml << EOF
signMode: threshold
thresholdMode:
  threshold: 2
  cosigners:
  - shardID: 1
    p2pAddr: tcp://${CHAIN}-horcrux-0.${CHAIN}-horcrux:22222
  - shardID: 2
    p2pAddr: tcp://${CHAIN}-horcrux-1.${CHAIN}-horcrux:22222
  - shardID: 3
    p2pAddr: tcp://${CHAIN}-horcrux-2.${CHAIN}-horcrux:22222
  grpcTimeout: 1000ms
  raftTimeout: 1000ms
chainNodes:
- privValAddr: tcp://${CHAIN}-${ORDINAL_INDEX}.${CHAIN}:1234

debugAddr: debugAddr: 0.0.0.0:6001
EOF

cp /run/sign/ecies.json ${HOME}/.horcrux/ecies.json
cp /run/sign/shard.json ${HOME}/.horcrux/${CHAIN_ID}_shard.json
/bin/horcrux start --home=${HOME}