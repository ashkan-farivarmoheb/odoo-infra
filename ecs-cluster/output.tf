output "efs_file_system_id" {
  value = aws_efs_file_system.efs.id
}

output "efs_access_point_ids" {
  value = aws_efs_access_point.odoo_access.id
}
