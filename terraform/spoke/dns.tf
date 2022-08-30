resource "azurerm_private_dns_zone_virtual_network_link" "spoke-vnet-dns" {
  count                 = var.spoke_count
  name                  = join("-", ["spoke-vnet-dns", var.spoke_index])
  resource_group_name   = var.hub_rg_name
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = azurerm_virtual_network.spoke_vnet.id
}

resource "azurerm_private_dns_a_record" "spoke-vms-dns" {
  count               = var.spoke_count
  name                = join("-", ["spoke", var.spoke_index, "vm"])
  zone_name           = var.dns_zone_name
  resource_group_name = var.hub_rg_name
  ttl                 = 300
  records             = [azurerm_linux_virtual_machine.spoke-vms[count.index].private_ip_address]
}


