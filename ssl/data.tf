data "aws_s3_bucket" "existing_bucket" {
  bucket = var.bucket_name
}