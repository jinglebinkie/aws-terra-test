# These are providers required by all Terraform projects in this repository,
# so that they can be baked into the Docker image once, rather than being
# downloaded multiple times, as some of them are quite large.

# To update a provider, change the version number here, commit the change,
# and re-run `./terraform-shell.sh` which will automatically rebuild the
# Docker image. Similarly when adding a new provider.

# In each project, you still need to run `terraform init` to generate the
# .terraform.lock.hcl (which must be committed), but it will not need to
# download the provider again, it will create a symlink to the cached version
# inside the Docker image.

#terraform {
#  required_providers {
#    mycloud = {
#      source  = "google"
#      version = "~> 4.62.1"
#    }
#  }
#}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"

        }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
  }
}
