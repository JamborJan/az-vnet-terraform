resource "azurerm_virtual_network" "spoke_vnet" {
  name                = join("-", [local.full_rg_name, "spoke", var.spoke_index])
  location            = azurerm_resource_group.spoke_rg.location
  resource_group_name = azurerm_resource_group.spoke_rg.name
  address_space       = ["10.${var.spoke_index}.0.0/16"]

  tags = {
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }
}


resource "azurerm_subnet" "spoke_vnet_subnet" {
  name                 = join("-", [local.full_rg_name, "spoke", var.spoke_index, "subnet"])
  resource_group_name  = azurerm_resource_group.spoke_rg.name
  virtual_network_name = azurerm_virtual_network.spoke_vnet.name
  address_prefixes     = ["10.${var.spoke_index}.1.0/24"]
}

resource "azurerm_network_interface" "spoke_nic" {
  name                 = join("-", [local.full_rg_name, "spoke", var.spoke_index, "nic"])
  location             = azurerm_resource_group.spoke_rg.location
  resource_group_name  = azurerm_resource_group.spoke_rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = join("-", ["spoke", var.spoke_index, "ip"])
    subnet_id                     = azurerm_subnet.spoke_vnet_subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }
}


