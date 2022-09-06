#############################################################################
# Peerings (always hub to spoke, never spoke to spoke in this example)
# If one spoke needs to communicate to another one, it must go through hub
#############################################################################

resource "azurerm_virtual_network_peering" "hub-spoke-peers" {
  name                      = join("-", [local.full_rg_name, "hub", "spoke-peer", var.spoke_index])
  resource_group_name       = var.hub_rg_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke_vnet.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  #allow_gateway_transit   = false
  #use_remote_gateways     = true
  # removed the gateway for demo
  #depends_on = [azurerm_virtual_network.spoke_vnet, azurerm_virtual_network.hub-vnet , azurerm_virtual_network_gateway.hub-vnet-gateway]
  #depends_on = [azurerm_virtual_network.hub-vnet] # we cannot depend on the spoke vnets here as we don't know how many are created and calculations / expressions like "azurerm_virtual_network.spoke-vnets[count.index+1]" are not allowed 
}

resource "azurerm_virtual_network_peering" "spoke-hub-peers" {
  count                     = var.spoke_count
  name                      = join("-", [local.full_rg_name, "spoke", var.spoke_index, "hub-peer"])
  resource_group_name       = azurerm_resource_group.spoke_rg.name
  virtual_network_name      = azurerm_virtual_network.spoke_vnet.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  #allow_gateway_transit   = false
  #use_remote_gateways     = true
  # removed the gateway for demo
  #depends_on = [azurerm_virtual_network.spoke-vnets[count.index+1], azurerm_virtual_network.hub-vnet , azurerm_virtual_network_gateway.hub-vnet-gateway]
  #depends_on = [azurerm_virtual_network.hub-vnet] # we cannot depend on the spoke vnets here as we don't know how many are created and calculations / expressions like "azurerm_virtual_network.spoke-vnets[count.index+1]" are not allowed 
}


