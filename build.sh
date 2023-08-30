tag=$1
docker build . -t ghcr.io/pfc-developer/horcrux-container:$tag
docker push  ghcr.io/pfc-developer/horcrux-container:$tag
