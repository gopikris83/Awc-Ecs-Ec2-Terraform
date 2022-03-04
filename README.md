# AWS ECS EC2 Provisioning with ALB - Terraform

Simple AWS ECS Cluster provisioning with ALB using Terraform. 

There is also Cloudwatch logs enabled along with Cloudwatch alarms to monitor the ECS Cluster deployments.

For more details on Terraform : https://www.terraform.io/



## What is deployed ?

Things that are deployed as part of [Terraform] :

Application container deployed to print User-Agent Info

* VPC - With private and public subnet
* EC2 Launch Configuration
* VPC Security Group
* ELB - Application Load Balancer with Security Group configured
* S3 Bucket
* S3 Bucket Policy
* IAM roles for executing ECS Tasks
* EC2 Auto Scaling Group to run desired number of EC2 instances
* ECR for storing docker images

### Install dependencies

* [`Python`](https://www.python.org/downloads/) Refer the link
* [`Docker`](https://docs.docker.com/engine/install/) Refer the link
* [`Make`](https://www.gnu.org/software/make/) Refer the link. Make for running container build and test on local machine
* [`terraform`](https://learn.hashicorp.com/tutorials/terraform/install-cli) required for `terraform deploy`.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.1.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~>4.0.0 |

## Usage

Backend is created using S3 Bucket to store the terraform state file.

Assuming ECR is created and images are pushed to ECR repo through CI/CD or Cli. 
Terraform configuration for ECR is excluded. 

Makefile is available for building the app images and running the containers on local machine.

```
export AWS_ACCESS_KEY_ID = AKIA******
export AWS_SECRET_ACCESS_KEY = **********

```

Use the load balancer dns host to access the docker container app.

In order to do any changes to the infrastructure you must:

* Init/Plan/Apply

### Init, Plan and Apply changes
```
# Run terraform to initialize, plan (preview the infrastructure) and apply for provisioning.

terraform init

terraform plan

terraform apply

# Finally, destroy all infrastructure using terraform destroy

terraform destroy
```