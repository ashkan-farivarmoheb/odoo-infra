resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  acl    = "private"
  count  = data.aws_s3_bucket.existing_bucket.id == "" ? 1 : 0
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
  bucket = data.aws_s3_bucket.existing_bucket.id != "" ? data.aws_s3_bucket.existing_bucket.bucket : aws_s3_bucket.my_bucket[0].bucket

  key    = "${var.ssl_name}/${each.value}"
  source = "scripts/${each.value}"
  acl    = "private"

  depends_on = [null_resource.run_shell_script]
}