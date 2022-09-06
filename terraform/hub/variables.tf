#############################################################################
# GENERAL VARIABLES
#############################################################################

variable "location" {
  type    = string
  default = "West Europe"
}

variable "resource_group_name" {
  type    = string
  default = "rg-vnetdemo-kstjj-001"
}
locals {
  full_rg_name = join("-", [terraform.workspace, var.resource_group_name])
}

#############################################################################
# SPECIFIC VARIABLES
#############################################################################

variable "spoke_count" {
  default = 2
}

variable "dns_zone_name" {}

variable "vm_user_ssh" {}

variable "allowed_ip_address" {}

#############################################################################
# TAGS
#
# tag_environment = terraform.workspace
#
#############################################################################

variable "tag_owner" {
  default = "jan.jambor@xwr.ch"
}

variable "tag_application_name" {
  default = "vnetdemo"
}

variable "tag_costcenter" {
  default = "jj"
}
variable "tag_dr" {
  default = "essential"
}


