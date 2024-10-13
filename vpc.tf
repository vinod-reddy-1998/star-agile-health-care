provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "default_subnets" {
  count = length(data.aws_subnet_ids.default.ids)
  id    = data.aws_subnet_ids.default.ids[count.index]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name              = "default-vpc"  # Give a name for identification
  cidr              = data.aws_vpc.default.cidr_block

  azs              = data.aws_vpc.default.azs  # Use availability zones from the default VPC
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
