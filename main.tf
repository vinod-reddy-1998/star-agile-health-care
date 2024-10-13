provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  vpc_id = data.aws_vpc.default.id
}

locals {
  name = "my-eks-cluster"  # Specify your EKS cluster name
  tags = {
    Environment = "test"
    Project     = "eks-demo"
  }
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = "10.0.0.0/16"  # Use your default or desired CIDR range

  azs             = ["us-east-1a", "us-east-1b"]  # Adjust as needed
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]  # Example public subnets
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]  # Example private subnets

  enable_nat_gateway = true
  map_public_ip_on_launch = true

  tags = local.tags
}

# EKS Module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  vpc_id                   = data.aws_vpc.default.id
  subnet_ids               = data.aws_subnets.default.ids  # Updated to use aws_subnets
  control_plane_subnet_ids = data.aws_subnets.default.ids  # Updated to use aws_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    amc-cluster-wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 2

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "helloworld"
      }
    }
  }

  tags = local.tags
}
