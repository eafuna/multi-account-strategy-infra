provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {

  resource_name = "${var.account_name}-${var.environment}"
  region        = var.region
  azs           = slice(data.aws_availability_zones.available.names, 0, 3)
  account_tags  = var.account_tags

  # ====================================
  # VPC vdms
  # ====================================  
  vdms_cidr           = ["10.50.28.0/22"]
  vdms_public_subnets = {}
  vdms_private_subnets = {
    "mgmt_subnet"     = ["10.50.28.0/23"]
    "reserved_subnet" = ["10.50.30.0/23"]
  }

  # ====================================
  # VPC reserved
  # ====================================  
  reserved_cidr            = ["10.50.32.0/22"]
  reserved_public_subnets  = {}
  reserved_private_subnets = {}

}


################################################################################
# RESERVED VPC
################################################################################
module "reserved_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-reserved-vpc"
  cidr                  = local.reserved_cidr[0]
  secondary_cidr_blocks = slice(local.reserved_cidr, 1, length(local.reserved_cidr))

  azs = local.azs

  public_subnets      = [for k, v in local.reserved_public_subnets : "${join(",", v)}"]
  private_subnets     = [for k, v in local.reserved_private_subnets : "${join(",", v)}"]
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
