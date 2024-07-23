#/bin/bash

# Do not continue if any errors occur in these scripts.
set -e


## removed from run phase 



docker build -f Dockerfile-local . -t terraform-shell
docker run -it --rm \
  --volume "$PWD":/terraform \
  --volume "/Users/jingle/.aws":/root/.aws \
  --workdir /terraform \
terraform-shell 
