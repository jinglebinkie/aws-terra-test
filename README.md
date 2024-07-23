# aws-terra-test

./terraform-shell-local.sh 
This will start the build of a docker image with needed terraform software and assisting tools like aws cli and then start the fresh built image and mount local credentials file into container through volume, from there terraform init/plan/apply is possible keeping a remote state in S3
When starting locally: run terraform init to setup fresh providers

AWS Notes: 
AWS creds are placed in Secrets Manager in my own AWS account, in the buildspec they are now passed to the container  as env vars, and the entrypoint.sh determines what to execute regarding Terraform
AWS codebuild can access repo aws-terra-test throug a fine-grained peronal access token (without user permissions , only  Read access to code, commit statuses, and metadata and  Read and Write access to repository hooks
Separated APIGW/Lambda resources from the DynamoDB in 2 seperate modules 


Terraform will use S3 bucket as backend storage 
Bucket was manually created and not publicly accessible

after running terraform apply the following resources are created:
- Dynamodb table with ID/Description/Date of news item
- REST ApiGW with read and post methods
- Lambda function for the get and post of articles

Created sever IAM policies  : 
- bucket-stuff
- cloudwatch policies
- codebuild policies
- get-secrets

I was able to post and get with following commands (replace apigateway url after redeploy)

curl -X POST https://k87432wz04.execute-api.eu-central-1.amazonaws.com/bananas/newsitem -H "Content-Type: application/json" -d '{"news-item-id":"8", "date-news-item":"20021979", "desc-news-item":"nieuwer-nieuwsbericht-metnieuwnieuws"}'


curl -X GET https://k87432wz04.execute-api.eu-central-1.amazonaws.com/bananas/news



Not fixed yet = CORS 
Proper assumeroles for least privileged access 
Metering/monitoring with dashboard 







