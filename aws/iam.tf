resource "aws_iam_access_key" "key" {
  user = "${aws_iam_user.user.name}"

  provisioner "local-exec" {
    command = "sleep 20"
  }

  depends_on = [ "aws_iam_user_policy.policy" ]
}

resource "aws_iam_user" "user" {
  name = "paasify-pae-${var.env_name}-admin"
  path = "/"
}

resource "aws_iam_user_policy" "policy" {
  name = "paasify-pae-${var.env_name}-admin"
  user = "${aws_iam_user.user.name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}