# Build horcrux from the PFC fork (PFC-developer/horcrux), synced to upstream
# v3.3.2 -- the exact version the fleet already runs, so this changes only the
# container substrate, not the signer software.
# CGO is REQUIRED: horcrux's raft cosigners encrypt peer traffic with ECIES
# (go-ethereum secp256k1), which panics without cgo -- a CGO_ENABLED=0 build
# crashloops the 3-member signer clusters on every sign attempt while
# single-signer instances appear fine.
FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS build
RUN apk add --no-cache git build-base
ARG TARGETARCH
RUN git clone --depth 1 -b v3.3.2 https://github.com/PFC-developer/horcrux.git /src/horcrux && \
    cd /src/horcrux && \
    if [ "$TARGETARCH" != "$BUILDARCH" ]; then \
      apk add --no-cache gcc musl-dev && GOARCH=$TARGETARCH CC=gcc CGO_ENABLED=1 go build -o /bin/horcrux ./cmd/horcrux; \
    else \
      CGO_ENABLED=1 go build -o /bin/horcrux ./cmd/horcrux; \
    fi

FROM alpine:3.24
LABEL org.opencontainers.image.description "runs horcrux inside the PFC cluster"

RUN apk add --update --no-cache libc-dev bash
RUN mkdir -p /bin
RUN mkdir -p /root
COPY --chmod=755 --from=build /bin/horcrux /bin/horcrux
ADD --chmod=755 ./launch.sh /bin/launch.sh
ADD --chmod=755 ./launch-single.sh /bin/launch-single.sh
ADD --chmod=755 ./launch-all.sh /bin/launch-all.sh

WORKDIR /root
CMD "/bin/bash"
