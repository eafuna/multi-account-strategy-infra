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
  # VPC log-vpc
  # ====================================  
  logging_cidr           = ["10.50.20.0/22"]
  logging_public_subnets = {}
  logging_private_subnets = {
    "logging"  = ["10.50.20.0/23"],
    "reserved" = ["10.50.22.0/23"]
  }

  # ====================================
  # VPC Reserved
  # ====================================  
  reserved_cidr            = ["10.50.24.0/22"]
  reserved_public_subnets  = {}
  reserved_private_subnets = {}

}

################################################################################
# VPC RESERVED
################################################################################
module "reserved_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-logging-vpc"
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
# VPC LOG
################################################################################
module "logging_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-logging-vpc"
  cidr                  = local.logging_cidr[0]
  secondary_cidr_blocks = slice(local.logging_cidr, 1, length(local.logging_cidr))

  azs = local.azs

  public_subnets      = [for k, v in local.logging_public_subnets : "${join(",", v)}"]
  private_subnets     = [for k, v in local.logging_private_subnets : "${join(",", v)}"]
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
