resource "azurerm_resource_group" "spoke_rg" {
  name     = join("-", [local.full_rg_name, "spoke", var.spoke_index])
  location = var.location

  tags = {
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }
}

