#/bin/bash

# Do not continue if any errors occur in these scripts.
set -e

# Reads secrets from the Vault that are used by Terraform.
#source vault.sh

docker build . -t terraform-shell
docker run -it --rm \
  --volume "$PWD":/terraform \
  --volume "/Users/jingle/.aws":/root/.aws \
  --workdir /terraform \
terraform-shell /bin/terraform init; /bin/terraform plan
