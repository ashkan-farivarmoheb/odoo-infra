# Output the bucket name
output "bucket_name" {
  value = local.bucket_name
}

output "folder_name" {
  value = "${var.ssl_name}"
}

output "upload_files" {
  value = [for obj in aws_s3_object.upload_files : obj.key]
}