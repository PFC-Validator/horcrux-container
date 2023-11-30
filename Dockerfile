FROM ghcr.io/strangelove-ventures/horcrux:v3.2.1 AS horcrux
FROM alpine:3.18

RUN apk add --update --no-cache libc-dev bash 
RUN mkdir -p /bin
RUN mkdir -p /root
COPY --chmod=755 --from=horcrux /bin/horcrux /bin/horcrux
ADD --chmod=755 ./launch.sh /bin/launch.sh
ADD --chmod=755 ./launch-single.sh /bin/launch-single.sh
ADD --chmod=755 ./launch-all.sh /bin/launch-all.sh

#RUN ls -l /bin
WORKDIR /root 
CMD "/bin/bash" 
#CMD ["chain-id"]
