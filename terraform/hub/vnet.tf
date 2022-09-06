resource "azurerm_public_ip" "hub_pip" {
  name                = "hub-pip"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  allocation_method   = "Dynamic"

  tags = {
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }
}


resource "azurerm_network_security_group" "hub_nsg" {
  name                = "hub-nsg"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name

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
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }
}


resource "azurerm_virtual_network" "hub_vnet" {
  name                = join("-", [local.full_rg_name, "hub"])
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }
}


resource "azurerm_subnet" "hub_vnet_subnet" {
  name                 = join("-", [local.full_rg_name, "hub", "subnet"])
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "subnet1internal" {
  subnet_id                 = azurerm_subnet.hub_vnet_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_nsg.id
  depends_on                = [azurerm_subnet.hub_vnet_subnet, azurerm_network_security_group.hub_nsg]
}

resource "azurerm_network_interface" "hub-nic" {
  name                 = join("-", [local.full_rg_name, "hub", "nic"])
  location             = azurerm_resource_group.hub_rg.location
  resource_group_name  = azurerm_resource_group.hub_rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "hub-ip"
    subnet_id                     = azurerm_subnet.hub_vnet_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hub_pip.id
  }

  tags = {
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }
}


