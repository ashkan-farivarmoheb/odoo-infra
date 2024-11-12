# Local value to set the bucket name
locals {
  bucket_name = var.bucket_name
}

# Create the S3 bucket if it doesn't exist already
resource "aws_s3_bucket" "my_bucket" {
  bucket = local.bucket_name
  acl    = "private"

  count  = var.create_bucket ? 1 : 0
}

resource "null_resource" "run_shell_script" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      cd scripts
      chmod +x ./ssl.sh
      ./ssl.sh ${var.domain_name} ${var.fqdn_list}
      ls -l # List files to confirm they were created
    EOT
  }
  depends_on = [aws_s3_bucket.my_bucket]
}

resource "aws_s3_object" "upload_files" {
  for_each = fileset("scripts", "*")
  bucket = local.bucket_name

  key    = "${var.ssl_name}/${each.value}"
  source = "scripts/${each.value}"
  acl    = "private"

  depends_on = [null_resource.run_shell_script, aws_s3_bucket.my_bucket]
}