aws_region = "ap-southeast-2"
aws_account_id = "838811465072"
environment = "develop"
project = "odoo"

/* module networking */
vpc_cidr             = "10.1.0.0/16"
public_subnets_cidr  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"] //List of Public subnet cidr range
private_subnets_cidr = ["10.1.10.0/24", "10.1.11.0/24", "10.1.12.0/24"] //List of private subnet cidr range