provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get the subnet IDs from the default VPC
data "aws_subnets" "default" {
  vpc_id = data.aws_vpc.default.id
}

# Get the default subnets
data "aws_subnet" "default_subnets" {
  count = length(data.aws_subnets.default.ids)
  id    = data.aws_subnets.default.ids[count.index]
}

locals {
  name = "my-eks-cluster"  # Specify your EKS cluster name
  tags = {
    Environment = "test"
    Project     = "eks-demo"
  }
}

# EKS Module Configuration
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update  = "OVERWRITE"
    }
    kube-proxy = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update  = "OVERWRITE"
    }
    vpc-cni = {
      most_recent = true
      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update  = "OVERWRITE"
    }
  }

  vpc_id                   = data.aws_vpc.default.id  # Use default VPC ID
  subnet_ids               = data.aws_subnets.default.ids  # Use default subnet IDs
  control_plane_subnet_ids = data.aws_subnets.default.ids  # Control plane in public subnets

  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]
    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    amc_cluster_wg = {
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

# VPC Module Configuration
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name              = "default-vpc"  # Give a name for identification
  cidr              = data.aws_vpc.default.cidr_block

  azs              = data.aws_vpc.default.azs  # Use the correct attribute for AZs
  private_subnets  = [for subnet in data.aws_subnet.default_subnets : subnet.id]  # Use existing subnets
  public_subnets   = []  # You can define public subnets if needed
  intra_subnets    = []  # Define intra subnets if required

  enable_nat_gateway = false  # Typically not needed for default VPC
  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
