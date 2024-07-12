FROM hashicorp/terraform:latest

# Bake required providers into the image.
ADD required-providers.tf /root/required-providers.tf
# RUN mkdir -p /root/.terraform/
RUN cd /root && terraform init -upgrade

# Set required environment variables.
#ADD .bashrc /root/.bashrc

# Replace default shell with Bash.
RUN apk add bash curl aws-cli

ENTRYPOINT [ "" ]
CMD /bin/bash
