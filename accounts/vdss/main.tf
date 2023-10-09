provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {

  resource_name = "${var.account_name}-${var.environment}"
  region        = var.region

  # ====================================
  # VPC vdss-egress-vpc
  # ====================================
  egress_cidr = [
    "10.50.0.0/22"
  ]

  egress_private_subnets = {}
  egress_public_subnets = {
    "subnets" = [
      "10.50.0.0/23",
      # "10.50.2.0/23"
    ]
  }

  # ====================================
  # VPC vdss-oobmgmt-vpc
  # ====================================
  oobmgmt_cidr = [
    "10.50.8.0/22"
  ]
  oobmgmt_private_subnets = {
    "subnets" = [
      "10.50.8.0/23",
      "10.50.10.0/23"
    ]
  }


  # ====================================
  # VPC vdss-insp-vpc
  # ====================================
  inspection_cidr = ["10.50.4.0/22"]
  inspection_public_subnets = {
    "inspection_fw" = ["10.50.4.0/23"]
  }
  inspection_private_subnets = {
    "inspection_fw" = ["10.50.6.0/23"]
  }


  # ====================================
  # VPC reserved
  # ====================================
  reserved_cidr = ["10.50.12.0/22", "10.50.16.0/22"]

  # ====================================
  # General
  # ====================================  
  azs          = slice(data.aws_availability_zones.available.names, 0, 3)
  account_tags = var.account_tags

}

################################################################################
# INSPECTION VPC
################################################################################
module "reserved_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-reserved-vpc"
  cidr                  = local.reserved_cidr[0]
  secondary_cidr_blocks = slice(local.reserved_cidr, 1, length(local.reserved_cidr))

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  azs                 = local.azs
  public_subnets      = []
  private_subnets     = []
  database_subnets    = []
  elasticache_subnets = []
  redshift_subnets    = []
  intra_subnets       = []
  outpost_subnets     = []

  enable_nat_gateway = false

  tags = local.account_tags


}

################################################################################
# INSPECTION VPC
################################################################################
module "inspection_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-inspection-vpc"
  cidr                  = local.inspection_cidr[0]
  secondary_cidr_blocks = slice(local.inspection_cidr, 1, length(local.inspection_cidr))

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  azs             = local.azs
  public_subnets  = [for k, v in local.inspection_public_subnets : "${join(",", v)}"]
  private_subnets = [for k, v in local.inspection_private_subnets : "${join(",", v)}"]
  # private_subnets_names = [for k, v in local.egress_subnets : k ]
  database_subnets    = []
  elasticache_subnets = []
  redshift_subnets    = []
  intra_subnets       = []
  outpost_subnets     = []

  enable_nat_gateway = false

  tags = local.account_tags


}

################################################################################
# EGRESS VPC
################################################################################
module "egress_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-egress-vpc"
  cidr                  = local.egress_cidr[0]
  secondary_cidr_blocks = slice(local.egress_cidr, 1, length(local.egress_cidr))

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  azs             = local.azs
  public_subnets  = [for k, v in local.egress_public_subnets : "${join(",", v)}"]
  private_subnets = [for k, v in local.egress_private_subnets : "${join(",", v)}"]
  # private_subnets_names = [for k, v in local.egress_subnets : k ]
  database_subnets    = []
  elasticache_subnets = []
  redshift_subnets    = []
  intra_subnets       = []
  outpost_subnets     = []

  enable_nat_gateway = false

  tags = local.account_tags


}

################################################################################
# OOB-MGMT VPC
################################################################################
module "oobmgmt_vpc" {
  source = "../../modules/aws_vpc/"

  name                  = "${local.resource_name}-oobmgmt-vpc"
  cidr                  = local.oobmgmt_cidr[0]
  secondary_cidr_blocks = slice(local.oobmgmt_cidr, 1, length(local.oobmgmt_cidr))

  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false

  public_subnets      = []
  private_subnets     = []
  database_subnets    = []
  elasticache_subnets = []
  redshift_subnets    = []
  intra_subnets       = []
  outpost_subnets     = []

  enable_nat_gateway = false

  tags = local.account_tags

}
