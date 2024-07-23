FROM hashicorp/terraform:1.9.2


# bake .tf files to create the resources n the container  for cloudbuild , otherwise comment our and use local volume in terraform-shell script 
RUN mkdir -p /root/.terraform/
RUN mkdir /terraform/

ADD . /terraform 

WORKDIR /terraform
RUN chmod +x entrypoint.sh 
ENTRYPOINT [ "./entrypoint.sh" ]

