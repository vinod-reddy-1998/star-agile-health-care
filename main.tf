provider "aws" {
  region = "us-east-1"
}

# Create VPC
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-vpc"
  }
}

# Create Subnets
resource "aws_subnet" "eks_subnet_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "eks-subnet-a"
  }
}

resource "aws_subnet" "eks_subnet_b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "eks-subnet-b"
  }
}

# Create IAM role for EKS
resource "aws_iam_role" "eks_role" {
  name = "my-eks-role"

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

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# Create EKS Cluster
resource "aws_eks_cluster" "my_test_cluster" {
  name     = "my-test-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.eks_subnet_a.id,
      aws_subnet.eks_subnet_b.id,
    ]
  }
}

# Create IAM role for node group
resource "aws_iam_role" "eks_node_role" {
  name = "my-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

# Create Node Group
resource "aws_eks_node_group" "my_test_node_group" {
  cluster_name    = aws_eks_cluster.my_test_cluster.name
  node_group_name = "my-test-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [
    aws_subnet.eks_subnet_a.id,
    aws_subnet.eks_subnet_b.id,
  ]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]  # Change here
}
