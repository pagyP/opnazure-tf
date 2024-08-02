resource "azurerm_resource_group" "opnsense-rg" {
  name     = "opnsense-rg"
  location = "france central"
}

module "opnsense-vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.4.0"
  # insert the 3 required variables here
  location            = azurerm_resource_group.opnsense-rg.location
  resource_group_name = azurerm_resource_group.opnsense-rg.name
  name                = "opnsense-vnet"
  address_space       = ["172.16.50.0/24"]

  subnets = {
    subnet0 = {
      name                            = "untrust-subnet"
      default_outbound_access_enabled = false
      #sharing_scope                   = "Tenant"  #NOTE: This preview feature requires approval, leaving off in example: Microsoft.Network/EnableSharedVNet
      address_prefixes = ["172.16.50.0/27"]
    }
    subnet1 = {
      name                            = "trust-subnet"
      address_prefixes                = ["172.16.50.32/27"]
      default_outbound_access_enabled = false
    }
  }
}




module "primary-fw" {
  source              = "./modules/VM"
  resource_group_name = azurerm_resource_group.opnsense-rg.name
  location            = azurerm_resource_group.opnsense-rg.location
  tags = {
    environment = "dev"
  }
  vm_name           = "opnsense-pri"
  admin_password    = "Qwertyuiop1234567890"
  admin_username    = "opnsense"
  image_publisher   = "thefreebsdfoundation"
  image_offer       = "freebsd-13_1"
  image_sku         = "freebsd-13_1"
  image_version     = "latest"
  vm_size           = "Standard_B2s"
  os_disk_caching   = "ReadWrite"
  data_disk_caching = "None"
  untrust_subnet_id = module.opnsense-vnet.subnets.subnet0.resource_id
  trust_subnet_id   = module.opnsense-vnet.subnets.subnet1.resource_id
}