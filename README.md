# aws-terra-test

./terraform-shell.sh 
This will start the build of a docker image with needed terraform software and assisting tools like aws cli and then start the fresh built image and mount local credentials file into container through volume
Cannot seem to get cloudbuild to pass creds as variables into docker running container after ubild through buildspec.yml

When starting locally: run terraform init to setup fresh providers

Terraform will use S3 bucket as backend storage 

I was able to post and get with following commands

curl -X POST https://fnkzmqc5e5.execute-api.eu-central-1.amazonaws.com/newsitem  --header 'Content-Type: application/json' -d '{"news-item-id":"8", "date-news-item":"20021979", "desc-news-item":"nieuwer-nieuwsbericht-metnieuwnieuws"}'

curl -X GET https://fnkzmqc5e5.execute-api.eu-central-1.amazonaws.com/news
