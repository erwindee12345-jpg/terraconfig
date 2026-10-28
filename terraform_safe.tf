provider "aws" {
  region = "us-east-1"
}

resource "aws_security_group" "sample_sg" {
  name        = "secure_sg"
  description = "Secure security group with restricted SSH and HTTPS egress access"

  ingress {
    description = "Allow inbound SSH from trusted corporate CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.0.2.50/32"]
  }

  egress {
    description = "Allow outbound HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["192.0.3.40/32"]
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2_secure_runtime_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_instance_profile" "sample_profile" {
  name = "sample_instance_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.sample_policy.arn
}

resource "aws_instance" "sample_server" {
  ami                  = "ami-0c55b159cbfafe1f0"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.sample_sg.name]
  iam_instance_profile = aws_iam_instance_profile.sample_profile.name

  monitoring           = true
  ebs_optimized        = true 

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" 
  }

  root_block_device {
    encrypted = true
  }
}

resource "aws_iam_policy" "sample_policy" {
  name        = "least_privilege_policy"
  description = "Grants scoped access to CloudWatch logs only"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = ["arn:aws:logs:us-east-1:123456789012:log-group:/aws/sample-app:*"]
      }
    ]
  })
}