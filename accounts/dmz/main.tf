provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {

  resource_name = "${var.account_name}-${var.environment}"
  region        = var.region

  dmz_cidr = ["10.50.48.0/21", "10.50.56.0/22"]

  dmz_public_subnets = {
    "subnets" = ["10.50.48.0/22"]
  }
  dmz_private_subnets = {
    "subnets" = ["10.50.56.0/22"]
    //"10.50.52.0/22",
  }

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  account_tags = var.account_tags

}

################################################################################
# DMZ VPC
################################################################################
module "dmz_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-dmz-vpc"
  cidr                  = local.dmz_cidr[0]
  secondary_cidr_blocks = slice(local.dmz_cidr, 1, length(local.dmz_cidr))

  azs = local.azs

  public_subnets      = [for k, v in local.dmz_public_subnets : "${join(",", v)}"]
  private_subnets     = [for k, v in local.dmz_private_subnets : "${join(",", v)}"]
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
