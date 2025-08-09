resource "aws_iam_role" "prod-webserver-role" {   // IAM role for webserver instances
  name = "prod-webserver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "prod-webserver-role"
  }
}

resource "aws_iam_role_policy_attachment" "prod-webserver-policy-attachment" {   // Attaching policy to the role
  role       = aws_iam_role.prod-webserver-role.name  //expects a name not an id
  depends_on = [aws_iam_role.prod-webserver-role]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  
}
resource "aws_iam_instance_profile" "prod-webserver-profile" { // Instance profile for webserver instances
  depends_on = [aws_iam_role_policy_attachment.prod-webserver-policy-attachment]  
  name = "prod-webserver-profile"
  role = aws_iam_role.prod-webserver-role.name
}