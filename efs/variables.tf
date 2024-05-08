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