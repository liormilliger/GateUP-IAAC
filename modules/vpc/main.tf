module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs            = var.availability_zones
  public_subnets = var.public_subnets_cidr

  # By not defining private_subnets and setting enable_nat_gateway to false,
  # we create a simpler, more cost-effective network.
  enable_nat_gateway = false
  enable_vpn_gateway = false

  # Tags are crucial for identifying and managing resources.
  tags = var.tags

  # This tag is often required by Kubernetes for service discovery on public subnets.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}
