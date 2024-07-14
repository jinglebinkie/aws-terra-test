#/bin/bash

# Do not continue if any errors occur in these scripts.
set -e

# Reads secrets from the Vault that are used by Terraform.
#source vault.sh

## removed from run phase 
##  --volume "$PWD":/terraform \
##  --volume "/Users/jingle/.aws":/root/.aws \

docker build . -t terraform-shell
docker run -it --rm \
  --workdir /terraform \
terraform-shell
