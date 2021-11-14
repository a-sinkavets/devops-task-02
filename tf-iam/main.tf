data "aws_caller_identity" "current" {}

resource "aws_iam_role" "my_role" {
  name = "${var.env_prefix}_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = ""
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Principal = {
          AWS = "${data.aws_caller_identity.current.account_id}"
        }
      },
    ]
  })
}

resource "aws_iam_group_policy" "my_group_policy" {
  name  = "${var.env_prefix}_group_policy"
  group = aws_iam_group.my_group.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = aws_iam_role.my_role.arn
      },
    ]
  })
}

resource "aws_iam_group" "my_group" {
  name = "${var.env_prefix}_group"
}

resource "aws_iam_user" "my_user" {
  name = "${var.env_prefix}_user"
}

resource "aws_iam_user_group_membership" "my_user_membership" {
  user = aws_iam_user.my_user.name
  groups = [ aws_iam_group.my_group.name ]
}
