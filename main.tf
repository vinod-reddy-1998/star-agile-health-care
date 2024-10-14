provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks_cluster_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# IAM Policy for EKS
resource "aws_iam_policy" "eks_policy" {
  name        = "eks_policy"
  description = "EKS Cluster policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "ec2:DescribeInstances",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs",
          "eks:DescribeCluster",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "eks_role_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = aws_iam_policy.eks_policy.arn
}

# Create the EKS Cluster
resource "aws_eks_cluster" "my_eks_cluster" {
  name     = "my-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.my_subnet.id]
  }
}

# Create a subnet for the EKS cluster (you can customize this)
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# EKS Cluster Authentication
resource "aws_eks_cluster_auth" "my_eks_cluster_auth" {
  cluster_name = aws_eks_cluster.my_eks_cluster.name
}

# Output kubeconfig
output "kubeconfig" {
  value = aws_eks_cluster_auth.my_eks_cluster_auth.kubeconfig
}

# Optional: Create an EKS node group (you can customize this)
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_eks_cluster.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_cluster_role.arn

  subnet_ids = [aws_subnet.my_subnet.id]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}
