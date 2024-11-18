resource "null_resource" "run_shell_script" {
  provisioner "local-exec" {
    command = <<EOT
      #!/bin/bash
      cd scripts
      chmod +x ./ssl.sh
      ./ssl.sh "${var.domain_name}" "${var.fqdn_list}" || { echo "SSL script failed"; exit 1; }
      echo "SSL files created:"
      ls -l # List files to confirm they were created
    EOT
  }

  # Using `triggers` to force execution whenever domain or FQDN list changes
  triggers = {
    domain_name = var.domain_name
    fqdn_list   = var.fqdn_list
    ssl_name    = var.ssl_name
  }

  depends_on = [data.aws_s3_bucket.existing_bucket]
}

resource "aws_s3_object" "upload_files" {
  for_each = fileset("scripts", "*") # Ensure scripts/* files are detected
  bucket   = data.aws_s3_bucket.existing_bucket.bucket

  key      = "${var.ssl_name}/${each.value}" # Unique folder for each run
  source   = "scripts/${each.value}"
  acl      = "private"

  depends_on = [null_resource.run_shell_script]
}