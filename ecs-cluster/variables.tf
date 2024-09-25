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

variable "min_size_asg" {
  description = "ASG min size"
  type        = number
}

variable "max_size_asg" {
  description = "ASG min size"
  type        = number
}

variable "desired_size_asg" {
  description = "ASG min size"
  type        = number
}

variable "imageId" {
  description = "Image ID"
  type = string
}

variable "instance_type" {
  description = "Instance type"
  type = string
}

variable "ec2_key_name" {
  description = "Ec2 Key Name"
  type        = string
}