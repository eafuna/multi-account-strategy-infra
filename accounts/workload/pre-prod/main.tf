provider "aws" {
  region = local.region
}

data "aws_availability_zones" "available" {}

locals {

  resource_name = "${var.account_name}-${var.environment}"
  region        = var.region

  workload_cidr = [
    "10.50.98.0/23",
    "10.50.100.0/22",
    "10.50.104.0/21",
    "10.50.112.0/21",
    "10.50.120.0/22",
  "10.50.124.0/23"]

  workload_public_subnets = {}
  workload_private_subnets = {
    "subnets" = ["10.50.98.0/23"]
    // ,"10.50.118.0/21"
  }
  database_subnets = {
  "main" = ["10.50.100.0/22"] }

  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  account_tags = var.account_tags

}

################################################################################
# WORKLOAD PROD VPC
################################################################################
module "workload_vpc" {
  source = "../../../modules/aws_vpc/"

  name                  = "${local.resource_name}-vpc"
  cidr                  = local.workload_cidr[0]
  secondary_cidr_blocks = slice(local.workload_cidr, 1, length(local.workload_cidr))

  azs = local.azs

  public_subnets      = [for k, v in local.workload_public_subnets : "${join(",", v)}"]
  private_subnets     = [for k, v in local.workload_private_subnets : "${join(",", v)}"]
  database_subnets    = [for k, v in local.database_subnets : "${join(",", v)}"]
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
