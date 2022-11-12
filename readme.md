# ECS-Locust
ECSでlocustを構築するソースです。

# 環境構築
```
cd terraform/envs/dev
terraform init
terraform plan
terraform apply
terraform output
```

# ImageをECRにPushする手順
```
docker build -t locust-sample-dev-ecr-repo:latest .  
```
```
aws ecr get-login-password | docker login --username AWS --password-stdin https://<aws_account_id>.dkr.ecr.<region>.amazonaws.com
```
```
docker tag locust-sample-dev-ecr-repo:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/locust-sample-dev-ecr-repo:latest
```
```
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/locust-sample-dev-ecr-repo:latest
```


# 使う
terraform outputで出てきたurlにアクセス


# terraform-ecs-sample
