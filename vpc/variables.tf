variable "aws_region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_account_id" {
  description = "aws account id"
  type = string
}

variable "environment" {
  description = "environment"
  type = string
}

variable "project" {
  description = "Project name"
  type = string
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list
  description = "The CIDR block for the private subnet"
}