provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {

  resource_name = "${var.account_name}-${var.environment}"
  region        = var.region

  vdms_cidr = ["10.50.32.0/21"]

  vdms_public_subnets = {}
  vdms_private_subnets = {
    "mgmt_subnet" = [
    "10.50.32.0/22"]
    #,"10.50.36.0/22"
  }

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  account_tags = var.account_tags

}

################################################################################
# VDMS VPC
################################################################################
module "vdms_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-vdms-vpc"
  cidr                  = local.vdms_cidr[0]
  secondary_cidr_blocks = slice(local.vdms_cidr, 1, length(local.vdms_cidr))

  azs = local.azs

  public_subnets      = [for k, v in local.vdms_public_subnets : "${join(",", v)}"]
  private_subnets     = [for k, v in local.vdms_private_subnets : "${join(",", v)}"]
  database_subnets    = []
  elasticache_subnets = []
  redshift_subnets    = []
  intra_subnets       = []
  outpost_subnets     = []

  enable_nat_gateway            = false
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false


  tags = local.account_tags


}
