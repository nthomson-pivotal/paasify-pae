resource "aws_s3_bucket" "ops_manager_bucket" {
  bucket        = format("%s-ops-manager-bucket-%s", var.env_name, var.bucket_suffix)
  force_destroy = true

  tags = merge(var.tags, map("Name", "${var.env_name}-control-plane-ops-manager"))
}
