# resource "azurerm_marketplace_agreement" "freebsd" {
#   publisher = "thefreebsdfoundation"
#   offer     = "freebsd-13_1"
#   plan      = "13_1-release"
# }

resource "azurerm_resource_group" "example" {
  name     = "example-resources1"
  location = "france central"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                            = "example-machine"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Qwertyuiop123456789"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.example.id,
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
  # depends_on = [ azurerm_marketplace_agreement.freebsd ]
}