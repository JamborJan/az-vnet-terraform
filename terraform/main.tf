#############################################################################
# RESOURCES Global Zone
#############################################################################

resource "azurerm_private_dns_zone" "dns_zone" {
  name                = "vnetdemo.loc"
  resource_group_name = module.hub.rg_name

  tags = {
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }
}

#############################################################################
# RESOURCES Hub Zone
#############################################################################

module "hub" {
  source = "./hub"

  location            = var.location
  resource_group_name = var.resource_group_name
  vm_user_ssh         = var.vm_user_ssh
  allowed_ip_address  = var.allowed_ip_address

  dns_zone_name = azurerm_private_dns_zone.dns_zone.name

  tag_owner            = var.tag_owner
  tag_application_name = var.tag_application_name
  tag_costcenter       = var.tag_costcenter
  tag_dr               = var.tag_dr
}

#############################################################################
# RESOURCES Spoke Zones
#############################################################################

module "spoke" {
  source = "./spoke"
  count  = var.spoke_count

  location            = var.location
  resource_group_name = var.resource_group_name
  vm_user_ssh         = var.vm_user_ssh
  allowed_ip_address  = var.allowed_ip_address

  spoke_index   = count.index + 1
  hub_rg_name   = module.hub.rg_name
  hub_vnet_id   = module.hub.vnet_id
  hub_vnet_name = module.hub.vnet_name
  dns_zone_name = azurerm_private_dns_zone.dns_zone.name

  tag_owner            = var.tag_owner
  tag_application_name = var.tag_application_name
  tag_costcenter       = var.tag_costcenter
  tag_dr               = var.tag_dr
}

