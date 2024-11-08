output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "folder_name" {
  value = "${var.ssl_name}"
}

output "upload_files" {
  value = [for obj in aws_s3_object.upload_files : obj.key]
}