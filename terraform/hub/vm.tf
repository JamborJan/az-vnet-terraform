resource "azurerm_linux_virtual_machine" "hub-vm" {
  name                  = "hub-vm"
  location              = azurerm_resource_group.hub_rg.location
  resource_group_name   = azurerm_resource_group.hub_rg.name
  network_interface_ids = [azurerm_network_interface.hub-nic.id]
  size                  = "Standard_B1ls" # smallest you can get, linux only: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-b-series-burstable

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "hub-vm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.vm_user_ssh
  }

  tags = {
    Environment     = terraform.workspace
    Owner           = var.tag_owner
    ApplicationName = var.tag_application_name
    CostCenter      = var.tag_costcenter
    DR              = var.tag_dr
  }

}

