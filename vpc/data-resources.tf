resource "random_id" "random_id_prefix" {
  byte_length = 2
}

locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
}

# data "aws_vpc" "existing_vpc" {
#   cidr_block = var.vpc_cidr
# }

# data "aws_subnet" "public_subnet" {
#   vpc_id    = data.aws_vpc.existing_vpc.id
#   cidr_block = tolist(var.public_subnets_cidr)
# }

# data "aws_subnet" "private_subnet" {
#   vpc_id    = data.aws_vpc.existing_vpc.id
#   cidr_block = tolist(var.private_subnets_cidr)
# }

# locals {
#   existing_public_subnet_cidrs  = [for subnet in data.aws_subnet.public_subnet : subnet.cidr_block]
#   existing_private_subnet_cidrs = [for subnet in data.aws_subnet.private_subnet : subnet.cidr_block]

#   public_subnet_cidr_valid  = length(var.public_subnets_cidr) == length(local.existing_public_subnet_cidrs) ? true : false
#   private_subnet_cidr_valid = length(var.private_subnets_cidr) == length(local.existing_private_subnet_cidrs) ? true : false
# }

# # Print error if CIDR blocks don't match
# data "null_data_source" "validation_error" {
#   count = local.public_subnet_cidr_valid && local.private_subnet_cidr_valid ? 0 : 1
# }

# # If validation fails, print an error and halt the execution
# resource "null_resource" "validation_error" {
#   count = local.public_subnet_cidr_valid && local.private_subnet_cidr_valid ? 0 : 1

#   triggers = {
#     validation_error_message = data.null_data_source.validation_error.*.triggers.error_message
#   }

#   provisioner "local-exec" {
#     command = "echo ${data.null_data_source.validation_error.*.triggers.error_message}"
#   }
# }
