# EC2 Instance with dependencies


### Requirements
#### - AWS cli with credentials 
#### - Terraform


### Create S3 State Bucket

```shell
aws s3api create-bucket --bucket "BUCKET_NAME"  --region us-east-1
```


### input your bucket name into the backend.tf file from backend.tf.example
```terraform
    bucket         = "BUCKET_NAME"
    key            = "terraform.tfstate"
    region         = "us-east-1"
```

### Initialize remote state
```shell
terraform init 
```

### input your aws credentials and choose instance name into terraform.tfvars from terraform.tfvars.example
```terraform
access_key = "AWS_KEY"
secret_key = "SECRET_KEY"
instance_name = "INSTANCE_NAME"
```
### Execute plan and verify everything looks good
```shell
terraform plan  
```

### Deploy cloud resources
```shell
terraform apply  
```

### Grab instance name and private key from the output
```shell
Outputs:

instance_dns_name = "ec2-XX-XX-XX-XX.compute-1.amazonaws.com"

```

A private key with the instance name will be generated. Save this in a secure location

### You may ssh into the instance 
```shell
  ssh -i "INSTANCE_NAME.pem" ubuntu@ec2-XX-XX-XX-XX.compute-1.amazonaws.com

```