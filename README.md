# terraform-IaC
#  AWS Terraform Infrastructure: EC2 + S3 Static Website

This Terraform project automates the creation of:

- An **EC2 instance** with SSH and HTTP access.
- An **S3 bucket** configured for **static website hosting**.
- Parameterized configuration for instance type, key pair, and bucket name.
## 🧰 Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured (`aws configure`)
- A public SSH key (`~/.ssh/id_rsa.pub`)
  
3. Initialize Terraform
terraform init
4. Plan the Deployment
terraform plan
5. Apply the Configuration
terraform apply
