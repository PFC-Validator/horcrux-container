# Build horcrux from the Gno team's production-hardened fork
# (gnolang/horcrux, v3.3.2-gno lineage), consumed directly at their release
# tags -- no intermediate PFC source fork. Their line carries the dependency
# sweep, the grpc NewClient migration, and the ECIES fixed-width key encoding
# fix (+tests). PFC-developer/horcrux is retired to a dormant pointer.
# Our layer remains: CGO build, launch scripts, alpine runtime.
# CGO is REQUIRED: horcrux's raft cosigners encrypt peer traffic with ECIES
# (go-ethereum secp256k1), which panics without cgo -- a CGO_ENABLED=0 build
# crashloops the 3-member signer clusters on every sign attempt while
# single-signer instances appear fine.
FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS build
RUN apk add --no-cache git build-base
ARG TARGETARCH
# Native build only -- the CI workflow targets linux/amd64 (the fleet) and a
# naive cross fallback cannot work for cgo (a native musl gcc rejects the
# other arch's flags); do not reintroduce one without a real cross toolchain.
RUN git clone --depth 1 -b v3.3.2-gno.6 https://github.com/gnolang/horcrux.git /src/horcrux && \
    cd /src/horcrux && \
    apk add --no-cache gcc musl-dev && \
    GOWORK=off CGO_ENABLED=1 go build -o /bin/horcrux ./cmd/horcrux

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
