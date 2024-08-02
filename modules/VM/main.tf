
locals {
  nic_names    = "${var.vm_name}-nic"
  os_disk_name = "${var.vm_name}-osdisk"
}
resource "azurerm_network_interface" "trust" {
  name                           = "${local.nic_names}-trust-nic"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  accelerated_networking_enabled = false
  ip_forwarding_enabled          = true

  ip_configuration {
    name                          = "${local.nic_names}-trust-ipconfig"
    subnet_id                     = var.trust_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}

resource "azurerm_network_interface" "untrust" {
  name                           = "${local.nic_names}-untrust-nic"
  location                       = var.location
  resource_group_name            = var.resource_group_name
  accelerated_networking_enabled = false
  ip_forwarding_enabled          = true

  ip_configuration {
    name                          = "${local.nic_names}-untrust-ipconfig"
    subnet_id                     = var.untrust_subnet_id
    private_ip_address_allocation = "Dynamic"
  }

}


resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.vm_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
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
    name                 = local.os_disk_name
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