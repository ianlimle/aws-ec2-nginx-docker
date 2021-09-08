# Deploy EC2 instance with Nginx web server in AWS Environment
This repository contains source code to provision an EC2 instance on AWS with an Nginx docker container deployed usng Terraform. 

## Prerequisites
* AWS account
* AWS profile configured with CLI on local machine
* [Terraform](https://www.terraform.io/downloads.html)

## Project Structure
```
├── README.md
├── .gitignore
├── modules
|  └── webserver
|     └── entrypoint-script.sh
|     └── main.tf
|     └── outputs.tf
|     └── variables.tf
├── main.tf
├── outputs.tf
├── sensitive.tfvars (not committed to Git repo)
└── variables.tf
```

## Initial Configuration
Before running the provisioning command, make sure to follow these initial steps.

### Remote state backend on AWS S3 bucket
Create an S3 bucket that will be used to store the remote state backend for Terraform 
```
aws s3api create-bucket --bucket <bucket-name> --region <region> --create-bucket-configuration LocationConstraint=<region>
```
Enable bucket versioning on the s3 bucket you have just created.
```
aws s3api put-bucket-versioning --bucket <bucket-name> --versioning-configuration Status=Enabled		
```

### Create `sensitive.tfvars` file
Your root and child Terraform files are set up to read any sensitive variable values from a file called `sensitive.tfvars` at the root directory. This file is not committed to the Git repo. The contents of the file can be as follows:
```
credentials="~/.aws/credentials"  
profile="default"
public_key_location="~/.ssh/id_rsa.pub"
private_key_location="~/.ssh/id_rsa"
my_ip=<your-local-machine-ip>
```

## Provision Infrastructure
Once you've completed all the above steps in the initial configuration, redirect to the root directory and run the following commands:
```
terraform init
terraform plan --var-file=sensitive.tfvars
terraform apply --var-file=sensitive.tfvars --auto-approve
```