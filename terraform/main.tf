#############################################################################
# RESOURCES Hub Zone
#############################################################################

resource "azurerm_resource_group" "hub-rg" {
  name     = join("-", [local.full_rg_name, "hub"])
  location = var.location

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_public_ip" "hub-pip" {
  name                = "hub-pip"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  allocation_method = "Dynamic"

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_network_security_group" "hub-nsg" {
  name                = "hub-nsg"
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ip_address
    destination_address_prefix = "*"
  }

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_private_dns_zone" "dns-zone" {
  name                = "vnetdemo.loc"
  resource_group_name = azurerm_resource_group.hub-rg.name

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

## Please be aware that provisioning a Virtual Network Gateway takes a long time (between 30 minutes and 1 hour)
#
#resource "azurerm_virtual_network_gateway" "hub-vnet-gateway" {
#  name                = "hub-vpn-gateway1"
#  location            = azurerm_resource_group.hub-rg.location
#  resource_group_name = azurerm_resource_group.hub-rg.name
#
#  type     = "Vpn"
#  vpn_type = "RouteBased"
#
#  active_active = false
#  enable_bgp    = false
#  sku           = "VpnGw1"
#
#  ip_configuration {
#    name                          = "vnetGatewayConfig"
#    public_ip_address_id          = azurerm_public_ip.hub-pip.id
#    private_ip_address_allocation = "Dynamic"
#    subnet_id                     = azurerm_subnet.hub-vnet-subnet.id
#  }
#  depends_on = [azurerm_public_ip.hub-pip]
#}
#
#resource "azurerm_virtual_network_gateway_connection" "hub-onprem-conn" {
#  name                = "hub-onprem-conn"
#  location            = azurerm_resource_group.hub-rg.location
#  resource_group_name = azurerm_resource_group.hub-rg.name
#
#  type           = "Vnet2Vnet"
#  routing_weight = 1
#
#  virtual_network_gateway_id      = azurerm_virtual_network_gateway.hub-vnet-gateway.id
#  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.onprem-vpn-gateway.id
#
#  shared_key = local.shared-key
#}
#
#resource "azurerm_virtual_network_gateway_connection" "onprem-hub-conn" {
#  name                = "onprem-hub-conn"
#  location            = azurerm_resource_group.onprem-vnet-rg.location
#  resource_group_name = azurerm_resource_group.onprem-vnet-rg.name
#  type                            = "Vnet2Vnet"
#  routing_weight = 1
#  virtual_network_gateway_id      = azurerm_virtual_network_gateway.onprem-vpn-gateway.id
#  peer_virtual_network_gateway_id = azurerm_virtual_network_gateway.hub-vnet-gateway.id
#
#  shared_key = local.shared-key
#}

resource "azurerm_virtual_network" "hub-vnet" {
  name                = join("-", [local.full_rg_name, "hub"])
  location            = azurerm_resource_group.hub-rg.location
  resource_group_name = azurerm_resource_group.hub-rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub-vnet-dns" {
  name                  = "hub-vnet-dns"
  resource_group_name   = azurerm_resource_group.hub-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.hub-vnet.id
}

resource "azurerm_subnet" "hub-vnet-subnet" {
  name                 = join("-", [local.full_rg_name, "hub", "subnet"])
  resource_group_name  = azurerm_resource_group.hub-rg.name
  virtual_network_name = azurerm_virtual_network.hub-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "subnet1internal" {
  subnet_id                 = azurerm_subnet.hub-vnet-subnet.id
  network_security_group_id = azurerm_network_security_group.hub-nsg.id
  depends_on                = [azurerm_subnet.hub-vnet-subnet, azurerm_network_security_group.hub-nsg]
}

resource "azurerm_network_interface" "hub-nic" {
  name                 = join("-", [local.full_rg_name, "hub", "nic"])
  location             = azurerm_resource_group.hub-rg.location
  resource_group_name  = azurerm_resource_group.hub-rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "hub-ip"
    subnet_id                     = azurerm_subnet.hub-vnet-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hub-pip.id
  }

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_linux_virtual_machine" "hub-vm" {
  name                  = "hub-vm"
  location              = azurerm_resource_group.hub-rg.location
  resource_group_name   = azurerm_resource_group.hub-rg.name
  network_interface_ids = [azurerm_network_interface.hub-nic.id]
  size                  = "Standard_B1ls" # smallest you can get, linux only: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable

  os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = "hub-vm"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username       = "azureuser"
    public_key     = var.vm_user_ssh
  }

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
  
}

resource "azurerm_private_dns_a_record" "hub-vm-dns" {
  name                = "hub-vm"
  zone_name           = azurerm_private_dns_zone.dns-zone.name
  resource_group_name = azurerm_resource_group.hub-rg.name
  ttl                 = 300
  records             = [azurerm_linux_virtual_machine.hub-vm.private_ip_address]
}

#############################################################################
# RESOURCES Spoke Zones
#############################################################################

resource "azurerm_resource_group" "spoke-rgs" {
  count    = var.spoke_count
  name     = join("-", [local.full_rg_name, "spoke", count.index+1])
  location = var.location

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_virtual_network" "spoke-vnets" {
  count               = var.spoke_count
  name                = join("-", [local.full_rg_name, "spoke", count.index+1])
  location            = azurerm_resource_group.spoke-rgs[count.index].location
  resource_group_name = azurerm_resource_group.spoke-rgs[count.index].name
  address_space       = ["10.${count.index+1}.0.0/16"]

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "spoke-vnet-dns" {
  count                 = var.spoke_count
  name                  = join("-", ["spoke-vnet-dns", count.index+1])
  resource_group_name   = azurerm_resource_group.hub-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name
  virtual_network_id    = azurerm_virtual_network.spoke-vnets[count.index].id
}

resource "azurerm_subnet" "spoke-vnets-subnet" {
  count                = var.spoke_count
  name                 = join("-", [local.full_rg_name, "spoke", count.index+1,"subnet"])
  resource_group_name  = azurerm_resource_group.spoke-rgs[count.index].name
  virtual_network_name = azurerm_virtual_network.spoke-vnets[count.index].name
  address_prefixes     = ["10.${count.index+1}.1.0/24"]
}

resource "azurerm_network_interface" "spoke-nics" {
  count                = var.spoke_count
  name                 = join("-", [local.full_rg_name, "spoke", count.index+1, "nic"])
  location             = azurerm_resource_group.spoke-rgs[count.index].location
  resource_group_name  = azurerm_resource_group.spoke-rgs[count.index].name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = join("-", ["spoke", count.index+1, "ip"])
    subnet_id                     = azurerm_subnet.spoke-vnets-subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }
}

resource "azurerm_linux_virtual_machine" "spoke-vms" {
  count                 = var.spoke_count
  name                  = join("-", [local.full_rg_name, "spoke", count.index+1, "vm"])
  location              = azurerm_resource_group.spoke-rgs[count.index].location
  resource_group_name   = azurerm_resource_group.spoke-rgs[count.index].name
  network_interface_ids = [azurerm_network_interface.spoke-nics[count.index].id]
  size                  = "Standard_B1ls" # smallest you can get, linux only: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable

  os_disk {
    name              = "myOsDisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name  = join("-", ["spoke-vm", count.index+1])
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username       = "azureuser"
    public_key     = var.vm_user_ssh
  }

  tags = {
    Environment = terraform.workspace
    Owner = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter = var.tag_costcenter
    DR = var.tag_dr
  }

}

resource "azurerm_private_dns_a_record" "spoke-vms-dns" {
  count               = var.spoke_count
  name                = join("-", ["spoke", count.index+1, "vm"])
  zone_name           = azurerm_private_dns_zone.dns-zone.name
  resource_group_name = azurerm_resource_group.hub-rg.name
  ttl                 = 300
  records             = [azurerm_linux_virtual_machine.spoke-vms[count.index].private_ip_address]
}

#############################################################################
# Peerings (always hub to spoke, never spoke to spoke in this example)
# If one spoke needs to communicate to another one, it must go through hub
#############################################################################

resource "azurerm_virtual_network_peering" "hub-spoke-peers" {
  count                     = var.spoke_count
  name                      = join("-", [local.full_rg_name, "hub", "spoke-peer", count.index+1])
  resource_group_name       = azurerm_resource_group.hub-rg.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-vnets[count.index].id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  #allow_gateway_transit   = false
  #use_remote_gateways     = true
  # removed the gateway for demo
  #depends_on = [azurerm_virtual_network.spoke-vnets[count.index+1], azurerm_virtual_network.hub-vnet , azurerm_virtual_network_gateway.hub-vnet-gateway]
  depends_on = [azurerm_virtual_network.hub-vnet] # we cannot depend on the spoke vnets here as we don't know how many are created and calculations / expressions like "azurerm_virtual_network.spoke-vnets[count.index+1]" are not allowed 
}

resource "azurerm_virtual_network_peering" "spoke-hub-peers" {
  count                     = var.spoke_count
  name                      = join("-", [local.full_rg_name, "spoke", count.index+1,"hub-peer"])
  resource_group_name       = azurerm_resource_group.spoke-rgs[count.index].name
  virtual_network_name      = azurerm_virtual_network.spoke-vnets[count.index].name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet.id
  
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  #allow_gateway_transit   = false
  #use_remote_gateways     = true
  # removed the gateway for demo
  #depends_on = [azurerm_virtual_network.spoke-vnets[count.index+1], azurerm_virtual_network.hub-vnet , azurerm_virtual_network_gateway.hub-vnet-gateway]
  depends_on = [azurerm_virtual_network.hub-vnet] # we cannot depend on the spoke vnets here as we don't know how many are created and calculations / expressions like "azurerm_virtual_network.spoke-vnets[count.index+1]" are not allowed 
}
