FROM hashicorp/terraform:1.9.2

# Bake required providers into the image.
#ADD required-providers.tf /root/required-providers.tf

# bake .tf files to create the resources n the container  for cloudbuild , otherwise comment our and use local volume in terraform-shell script 
RUN mkdir -p /root/.terraform/
RUN mkdir /terraform/

#COPY src/ /terraform/src
#ADD main.tf /terraform/main.tf
#ADD variables.tf /terraform/variables.tf
#ADD outputs.tf /terraform/outputs.tf
#ADD entrypoint.sh /terraform/entrypoint.sh
ADD . /terraform 

# Works locally with local aws creds dile for the bucket location for tfstate, fails in cloudbuild due to inability to add aws creds
#RUN cd /root && terraform init -upgrade

# Replace default shell with Bash and add aws-cli for testing purposed when running locally 
#RUN apk add bash


WORKDIR /terraform
RUN chmod +x entrypoint.sh 
ENTRYPOINT [ "./entrypoint.sh" ]
#CMD /bin/bash
