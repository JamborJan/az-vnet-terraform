output "rg_name" {
  value = azurerm_resource_group.hub_rg.name
  }
#  hub_vnet_id = module.hub.vnet_id

output "vnet_id" {
  value = azurerm_virtual_network.hub_vnet.id
}
output "vnet_name" {
  value = azurerm_virtual_network.hub_vnet.name
}
