# resource "azurerm_marketplace_agreement" "freebsd" {
#   publisher = "thefreebsdfoundation"
#   offer     = "freebsd-13_1"
#   plan      = "13_1-release"
# }

resource "azurerm_resource_group" "example" {
  name     = "example-resources1"
  location = "sweden central"
}

resource "azurerm_virtual_network" "example" {
  name                = "opnsense-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "trust" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "untrust" {
  name                 = "external"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_network_interface" "primary-trust" {
  name                = "pri-trust-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.trust.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "primary-untrust" {
  name                = "pri-untrust-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.untrust.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_network_interface" "secondary-trust" {
  name                = "sec-trust-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.trust.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "secondary-untrust" {
  name                = "sec-untrust-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "external"
    subnet_id                     = azurerm_subnet.untrust.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "primaryfw" {

  name                            = "opnsense-pri"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  admin_password                  = "Qwertyuiop123456789"
  disable_password_authentication = false
  boot_diagnostics {
    storage_account_uri = ""
  }
  network_interface_ids = [
    azurerm_network_interface.primary-trust.id,
    azurerm_network_interface.primary-untrust.id
  ]

  #   admin_ssh_key {
  #     username   = "adminuser"
  #     public_key = file("~/.ssh/id_rsa.pub")
  #   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "pri-fw-os-disk"
  }
  # plan {
  #   name      = "13_1-release"
  #   publisher = "thefreebsdfoundation"
  #   product   = "freebsd-13_1"
  # }
  plan {
    name      = "14_0-release-amd64-gen2-zfs"
    publisher = "thefreebsdfoundation"
    product   = "freebsd-14_0"
  }

  # source_image_reference {
  #   publisher = "thefreebsdfoundation"
  #   offer     = "freebsd-13_1"
  #   sku       = "13_1-release"
  #   version   = "latest"

  # }
  source_image_reference {
    publisher = "thefreebsdfoundation"
    offer     = "freebsd-14_0"
    sku       = "14_0-release-amd64-gen2-zfs"
    version   = "latest"

  }
  # depends_on = [ azurerm_marketplace_agreement.freebsd ]
  # depends_on = [ azurerm_lb.example,
  # azurerm_lb_backend_address_pool.example,
  # azurerm_lb_backend_address_pool_address.primaryfw,
  # azurerm_lb_backend_address_pool_address.secondaryfw,
  # azurerm_lb_nat_rule.nat1,
  # azurerm_lb_nat_rule.nat2,
  # azurerm_lb_outbound_rule.this ]
}

# resource "time_sleep" "wait" {
#   depends_on = [azurerm_linux_virtual_machine.primaryfw]
#   create_duration = "120s"
# }
resource "azurerm_linux_virtual_machine" "secondaryfw" {
  name                            = "opnsense-sec"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  admin_password                  = "Qwertyuiop123456789"
  disable_password_authentication = false
  boot_diagnostics {
    storage_account_uri = ""
  }
  network_interface_ids = [
    azurerm_network_interface.secondary-trust.id,
    azurerm_network_interface.secondary-trust.id
  ]

  #   admin_ssh_key {
  #     username   = "adminuser"
  #     public_key = file("~/.ssh/id_rsa.pub")
  #   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "sec-fw-os-disk"
  }
  # plan {
  #   name      = "13_1-release"
  #   publisher = "thefreebsdfoundation"
  #   product   = "freebsd-13_1"
  # }
  plan {
    name      = "14_0-release-amd64-gen2-zfs"
    publisher = "thefreebsdfoundation"
    product   = "freebsd-14_0"
  }

  # source_image_reference {
  #   publisher = "thefreebsdfoundation"
  #   offer     = "freebsd-13_1"
  #   sku       = "13_1-release"
  #   version   = "latest"

  # }
  source_image_reference {
    publisher = "thefreebsdfoundation"
    offer     = "freebsd-14_0"
    sku       = "14_0-release-amd64-gen2-zfs"
    version   = "latest"

  }
  # depends_on = [ azurerm_linux_virtual_machine.primaryfw,
  # time_sleep.wait]
  # depends_on = [ azurerm_marketplace_agreement.freebsd ]
  # depends_on = [ azurerm_lb.example,
  # azurerm_lb_backend_address_pool.example,
  # azurerm_lb_backend_address_pool_address.primaryfw,
  # azurerm_lb_backend_address_pool_address.secondaryfw,
  # azurerm_lb_nat_rule.nat1,
  # azurerm_lb_nat_rule.nat2,
  # azurerm_lb_outbound_rule.this,
  # azurerm_linux_virtual_machine.primaryfw ]
}
