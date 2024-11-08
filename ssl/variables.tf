variable "aws_region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "ap-southeast-2"
}

variable "aws_account_id" {
  description = "aws account id"
  type = string
}

variable "bucket_name" {
    description = "ssl bucket name"
    type = string
}

variable "domain_name" {
  description = "domain name to create a ssl"
  type = string
}

variable "ssl_name" {
  description = "folder name to place ssl files"
  type = string
}

variable "fqdn_list" {
  type    = string
  default = "example.com,sub.example.com,another.example.com"
}