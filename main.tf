terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Adjust as needed
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

# Data source for the default VPC
data "aws_vpc" "default" {
  default = true
}

# Get all public subnets associated with the default VPC
data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# New data source for availability zones
data "aws_availability_zones" "available" {}

# Filter for supported availability zones for EKS
locals {
  supported_azs = [
    "us-east-1a",
    "us-east-1b",
    "us-east-1c",
    "us-east-1d",
    "us-east-1f"
  ]
  filtered_azs = [for az in data.aws_availability_zones.available.names : az if az in local.supported_azs]
}

# Retrieve CIDR blocks for public subnets
data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public_subnets.ids)
  id       = each.key
}

locals {
  name = "my-eks-cluster"  # Specify your EKS cluster name
  tags = {
    Environment = "test"
    Project     = "eks-demo"
  }
  public_subnet_cidrs = [for subnet in data.aws_subnet.public : subnet.cidr_block]
}

# VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name              = "default-vpc"  # Give a name for identification
  cidr              = data.aws_vpc.default.cidr_block

  azs              = local.filtered_azs  # Use filtered availability zones
  private_subnets  = []  # No private subnets defined
  public_subnets   = local.public_subnet_cidrs  # Use CIDR blocks of public subnets
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

# EKS module
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
  subnet_ids               = module.vpc.public_subnets  # Use public subnet CIDR blocks from the VPC module
  control_plane_subnet_ids = module.vpc.public_subnets  # Control plane in public subnets

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
