provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "eks-vpc"
  }
}

resource "aws_subnet" "eks_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "eks-subnet-${count.index}"
  }
}

data "aws_ami" "eks" {
  most_recent = true

  owners = ["602401143452"] # Amazon EKS optimized AMI owner ID

  filters = [{
    name   = "name"
    values = ["amazon-eks-node-*"]
  }]
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Effect = "Allow"
      Sid    = ""
    }]
  })
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_eks_cluster" "my_cluster" {
  name     = "my-test-cluster"
  role_arn = aws_iam_role.eks_node_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }

  depends_on = [aws_iam_role_policy_attachment.worker_node_policy]
}

resource "aws_eks_node_group" "my_test_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "my-test-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  subnet_ids = aws_subnet.eks_subnet[*].id

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.registry_policy
  ]
}

output "cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}

output "kubeconfig" {
  value = aws_eks_cluster.my_cluster.kubeconfig
}
