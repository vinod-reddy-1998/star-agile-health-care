provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "public_subnets" {
  count = length(data.aws_subnet_ids.default.ids)
  id    = data.aws_subnet_ids.default.ids[count.index]
}

locals {
  name = "my-eks-cluster"  # Specify your EKS cluster name
  tags = {
    Environment = "test"
    Project     = "eks-demo"
  }
}

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
  subnet_ids               = data.aws_subnet_ids.default.ids  # Use default subnet IDs
  control_plane_subnet_ids = data.aws_subnet_ids.default.ids  # Control plane in public subnets

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
