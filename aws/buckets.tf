resource "random_string" "control_plane_bucket_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_s3_bucket" "control_plane_artifacts" {
  bucket = "paasify-${var.env_name}-pae-artifacts-${random_string.control_plane_bucket_suffix.result}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket" "control_plane_exports" {
  bucket = "paasify-${var.env_name}-pae-exports-${random_string.control_plane_bucket_suffix.result}"
  acl    = "private"
}

resource "aws_iam_user" "control_plane_bucket" {
  name = "paasify-${var.env_name}-pae-s3"
}

resource "aws_iam_access_key" "control_plane_bucket" {
  user = "${aws_iam_user.control_plane_bucket.name}"
}

resource "aws_iam_user_policy" "control_plane_bucket" {
  name = "paasify-${var.env_name}-pae-s3"
  user = "${aws_iam_user.control_plane_bucket.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListObjectsInBucket",
            "Effect": "Allow",
            "Action": ["s3:ListBucket","s3:ListBucketVersions","s3:GetBucketVersioning"],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.control_plane_artifacts.bucket}",
                "arn:aws:s3:::${aws_s3_bucket.control_plane_exports.bucket}"
            ]
        },
        {
            "Sid": "AllObjectActions",
            "Effect": "Allow",
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.control_plane_artifacts.bucket}/*",
                "arn:aws:s3:::${aws_s3_bucket.control_plane_exports.bucket}/*"
            ]
        }
    ]
}
EOF
}