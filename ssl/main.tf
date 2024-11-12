# Local value to set a unique bucket name each time
locals {
  bucket_name = "${var.environment}-ssl-service-${var.ssl_name}"
}

# Create the S3 bucket if it doesn't exist already
resource "aws_s3_bucket" "my_bucket" {
  bucket = local.bucket_name
  acl    = "private"

  count  = var.create_bucket ? 1 : 0

  # Always create a new bucket, without relying on the `count`
  force_destroy = true
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

  # Using `triggers` to force execution whenever domain or FQDN list changes
  triggers = {
    domain_name = var.domain_name
    fqdn_list   = var.fqdn_list
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