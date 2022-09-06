
resource "azurerm_private_dns_zone_virtual_network_link" "hub_vnet_dns" {
  name                  = "hub-vnet-dns"
  resource_group_name   = azurerm_resource_group.hub_rg.name
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_private_dns_a_record" "hub-vm-dns" {
  name                = "hub-vm"
  zone_name           = var.dns_zone_name
  resource_group_name = azurerm_resource_group.hub_rg.name
  ttl                 = 300
  records             = [azurerm_linux_virtual_machine.hub-vm.private_ip_address]
}


