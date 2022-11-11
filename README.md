# terraform
crate aws-ec2 and deploy nginx using terraform and ansible
Table of Contents
About The Project
Built With
Getting Started
Prerequisites
Installation
Usage
About The Project
This project is built to host a nginx application in AWS EC2 instance.

Built With
The project is built using,

AWS resources
Terraform
Ansible
Getting Started
Prerequisites
Create a free tier AWS account.
Create an IAM user with programmable access and make a note of the access and secret keys.
Installation
Install Terraform on local laptop
Install Ansible on ec2

Standing up the Infrastructure
The infrastructure is setup in AWS using Terraform.

cd into the infrastructure folder in the cloned repository.
Run the following commands in order
terraform init
terraform plan
terraform apply
This will provision the required infrastructure and provides the EC2 instance public IP as the output.

Installing the nginx
The next step is to install the required softwares in the EC2 instance and deploy the nginx application. This is done using ansible and check the output.
