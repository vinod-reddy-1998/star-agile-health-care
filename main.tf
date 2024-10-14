provider "aws" {
  region = "us-east-1"
}

resource "aws_eks_cluster" "test_cluster" {
  name     = "test-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet.*.id
  }
}

resource "aws_iam_role" "eks_role" {
  name = "eks-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_subnet" "eks_subnet" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.${count.index}.0/24"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
