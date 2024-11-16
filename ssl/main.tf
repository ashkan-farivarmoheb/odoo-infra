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

  depends_on = [data.aws_s3_bucket.existing_bucket]
}

resource "aws_s3_object" "upload_files" {
  for_each = fileset("scripts", "*")
  bucket = data.aws_s3_bucket.existing_bucket

  key    = "${var.ssl_name}/${each.value}"
  source = "scripts/${each.value}"
  acl    = "private"

  depends_on = [null_resource.run_shell_script, data.aws_s3_bucket.existing_bucket]
}