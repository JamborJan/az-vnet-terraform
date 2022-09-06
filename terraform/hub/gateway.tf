## Please be aware that provisioning a Virtual Network Gateway takes a long time (between 30 minutes and 1 hour)
#
#resource "azurerm_virtual_network_gateway" "hub-vnet-gateway" {
#  name                = "hub-vpn-gateway1"
#  location            = azurerm_resource_group.hub_rg.location
#  resource_group_name = azurerm_resource_group.hub_rg.name
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
#    public_ip_address_id          = azurerm_public_ip.hub_pip.id
#    private_ip_address_allocation = "Dynamic"
#    subnet_id                     = azurerm_subnet.hub-vnet-subnet.id
#  }
#  depends_on = [azurerm_public_ip.hub_pip]
#}
#
#resource "azurerm_virtual_network_gateway_connection" "hub-onprem-conn" {
#  name                = "hub-onprem-conn"
#  location            = azurerm_resource_group.hub_rg.location
#  resource_group_name = azurerm_resource_group.hub_rg.name
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


