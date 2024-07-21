# aws-terra-test

./terraform-shell.sh 
This will start the build of a docker image with needed terraform software and assisting tools like aws cli and then start the fresh built image and mount local credentials file into container through volume, from there terraform init/plan/apply is possible keeping a remote state in S3

AWS Note: 
Cannot seem to get codebuild to pass creds as variables (from manually inserted secrets in Secret manager) into docker running container after build through buildspec.yml. Therfor a terraform init is not working as the remoe state bucket is not reachable. Using the buildspec I can query the Secretmanager for the creds and echo them ( it will show **), but it retrieves something at least 
Codeuild is picking up github pushes not , and creds might work now .. 

When starting locally: run terraform init to setup fresh providers

Terraform will use S3 bucket as backend storage 
Bucket was manually created and not publicly accessible

after running terraform apply for following was created:
- Dynamodb table with ID/Description/Date of news item
- REST ApiGW with read and post methods
- Lambda function for the get and post of articles

Created sever IAM policies  : 
- bucket-stuff
- cloudwatch policies
- codebuild policies
- get-secrets

I was able to post and get with following commands

curl -X POST https://x6s8aoqca0.execute-api.eu-central-1.amazonaws.com/bananas/newsitem -H "Content-Type: application/json" -d '{"news-item-id":"8", "date-news-item":"20021979", "desc-news-item":"nieuwer-nieuwsbericht-metnieuwnieuws"}'


curl -X GET https://x6s8aoqca0.execute-api.eu-central-1.amazonaws.com/bananas/news



Not fixed ( but is it needed without frontend ?) = CORS 
Proper assumeroles for least privileged access 
Metering/monitoring with dashboard 





