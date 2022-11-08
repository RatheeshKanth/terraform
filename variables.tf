variable "access_key" {}
variable "secret_key" {}

variable "region" {
    type = string
    description = "aws region Sydney"
    default = "ap-southeast-2"
}

variable "key_name" { 
    description = "SSH keys to connect to ec2 instance" 
    default     =  "test-key" 
}

variable "instance_type" { 
    description = "instance type for ec2" 
    default     =  "t2.micro" 
}

variable "security_group" { 
    description = "Name of security group" 
    default     = "test-SG" 
}

variable "tag_name" { 
    description = "Tag Name of for Ec2 instance" 
    default     = "test-ec2" 
} 
variable "ami_id" { 
    description = "AMI for Ubuntu Ec2 instance" 
    default     = "ami-055166f8a8041fbf1" 
}