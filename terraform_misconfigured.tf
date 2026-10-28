provider "aws" {
  region = "us-east-1"
  access_key = "AKIAIOSFODNN7EXAMPLE"
  secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
}

resource "aws_security_group" "sample_sg" {
  name        = "insecure_sg"
  description = "Insecure security group open to the world"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sample_server" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.sample_sg.name]

  root_block_device {
    encrypted = false
  }
}

resource "aws_iam_policy" "sample_policy" {
  name        = "admin_policy"
  description = "Grants full administrative access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["*"]
        Effect   = "Allow"
        Resource = ["*"] # Flagged: Wildcard permissions across all AWS services
      }
    ]
  })
}