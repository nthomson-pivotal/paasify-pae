output "bucket" {
  value = aws_s3_bucket.ops_manager_bucket.bucket
}

output "ssh_private_key" {
  value = element(concat(tls_private_key.ops_manager.*.private_key_pem, list("")), 0)
}

output "ssh_public_key_name" {
  value = element(concat(aws_key_pair.ops_manager.*.key_name, list("")), 0)
}

output "ssh_public_key" {
  value = element(concat(aws_key_pair.ops_manager.*.public_key, list("")), 0)
}

output "ops_manager_iam_instance_profile_name" {
  value = aws_iam_instance_profile.ops_manager.name
}

output "ops_manager_iam_user_name" {
  value = aws_iam_user.ops_manager.name
}

output "ops_manager_iam_user_access_key" {
  value = aws_iam_access_key.ops_manager.id
}

output "ops_manager_iam_user_secret_key" {
  value     = aws_iam_access_key.ops_manager.secret
  sensitive = true
}

output "ops_manager_iam_role_name" {
  value = aws_iam_role.ops_manager.name
}
