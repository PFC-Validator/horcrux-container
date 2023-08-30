
FROM ghcr.io/strangelove-ventures/horcrux:v3.1.0 AS horcrux
FROM busybox:1.28

#RUN apk add --update --no-cache libc-dev bash 

COPY --from=horcrux /bin/horcrux /bin
ADD ./launch.sh /bin 
ADD ./launch-single.sh /bin 

WORKDIR /root 
ENTRYPOINT [ "/bin/bash" ] 
CMD ["chain-id"]
