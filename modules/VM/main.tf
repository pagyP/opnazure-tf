
locals {
  nic_names = "${var.vm_name}-nic"
}
resource "azurerm_network_interface" "trust" {
  #for_each                      = toset(var.vm_names)
  #name                          = "${each.value}-nic"
  name                         = "${local.nic_names}-trust-nic"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  accelerated_networking_enabled = false
  ip_forwarding_enabled = true

  ip_configuration {
    #name                          = "${each.value}-ipconfig"
    name                         = "${local.nic_names}-trust-ipconfig"
    subnet_id                     = var.trust_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_interface" "untrust" {
  #for_each                      = toset(var.vm_names)
  #name                          = "${each.value}-nic"
  name                         = "${local.nic_names}-untrust-nic"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  accelerated_networking_enabled = false
  ip_forwarding_enabled = true

  ip_configuration {
    #name                          = "${each.value}-ipconfig"
    name                         = "${local.nic_names}-untrust-ipconfig"
    subnet_id                     = var.untrust_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}


# }

# resource "azurerm_windows_virtual_machine" "primary" {
#   #for_each              = toset(var.vm_names)
#   #name                  = each.value
#   name = "opnsense-primary"
#   location              = var.location
#   resource_group_name   = var.resource_group_name
#   #network_interface_ids = [azurerm_network_interface.main[each.key].id]
#   size                  = "Standard_B2s"
#   admin_username        = "opnsense"
#   admin_password        = "Qwertyuiop1234567890"
#   #timezone              = var.time_zone
#   network_interface_ids = [
#     azurerm_network_interface.trust-primary.id,
#     azurerm_network_interface.untrust-primary.id
#   ]


#   source_image_reference {
#     publisher = "thefreebsdfoundation"
#     offer     = "freebsd-13_1"
#     sku       = "13_1-release"
#     version   = "latest"
#   }

#   os_disk {
#     #name    = "${each.key}-osdisk"
#     name = "opnsense-osdisk"
#     caching = var.os_disk_caching
#     #create_option     = "FromImage"
#     #managed_disk_type = var.os_disk_type
#     storage_account_type = var.os_disk_type
#   }

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password = var.admin_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.trust.id,
    azurerm_network_interface.untrust.id
  ]

#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
   plan {
      name      = "13_1-release"
      publisher = "thefreebsdfoundation"
      product   = "freebsd-13_1"
    }

  source_image_reference {
    publisher = "thefreebsdfoundation"
    offer     = "freebsd-13_1"
    sku       = "13_1-release"
    version   = "latest"
   
  }





  tags = var.tags

}

# resource "azurerm_virtual_machine_data_disk_attachment" "main" {
#   for_each           = toset(var.vm_names)
#   managed_disk_id    = azurerm_managed_disk.main[each.key].id
#   virtual_machine_id = azurerm_windows_virtual_machine.main[each.key].id
#   lun                = 0
#   caching            = var.data_disk_caching

# }