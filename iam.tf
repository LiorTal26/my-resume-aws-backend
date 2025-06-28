resource "aws_iam_policy" "tf_state_access" {
  name        = "tf-state-access"
  description = "Allow GitHub Actions role to read/write Terraform state"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::my-resume-tf-state-ilcentral1",
          "arn:aws:s3:::my-resume-tf-state-ilcentral1/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem", "dynamodb:UpdateItem"]
        Resource = "arn:aws:dynamodb:il-central-1:108782097005:table/terraform-locks"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gh_actions_tf_state" {
  role       = "gh-actions-deploy"
  policy_arn = aws_iam_policy.tf_state_access.arn
}
