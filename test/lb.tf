resource "azurerm_lb" "example" {
  name                = "opnsense-elb"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.elbpip.id
   
}

}


resource "azurerm_public_ip" "elbpip" {
    name                = "elb-pip"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    allocation_method   = "Static"
    sku = "Standard"
  
}

resource "azurerm_lb_backend_address_pool" "example" {
    name                = "backend-pool"
    loadbalancer_id     = azurerm_lb.example.id
}

resource "azurerm_lb_backend_address_pool_address" "primaryfw" {
   backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
    name                     = "primaryfw"
    virtual_network_id = azurerm_virtual_network.example.id
    ip_address               = azurerm_network_interface.primary-untrust.private_ip_address
}

resource "azurerm_lb_backend_address_pool_address" "secondaryfw" {
    backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
    name                     = "secondaryfw"
    virtual_network_id = azurerm_virtual_network.example.id
    ip_address               = azurerm_network_interface.secondary-untrust.private_ip_address
}

resource "azurerm_lb_outbound_rule" "this" {
    loadbalancer_id     = azurerm_lb.example.id
    name                = "OutboundRule"
    backend_address_pool_id      = azurerm_lb_backend_address_pool.example.id
    protocol                      = "All"
    idle_timeout_in_minutes       = 30
  
}

resource "azurerm_lb_nat_rule" "nat1" {
    resource_group_name = azurerm_resource_group.example.name
    loadbalancer_id     = azurerm_lb.example.id
    name                = "primary-fw"
    protocol            = "Tcp"
    frontend_port       = 5443
    backend_port        = 443
    frontend_ip_configuration_name = azurerm_lb.example.frontend_ip_configuration[0].name
  
}

resource "azurerm_lb_nat_rule" "nat2" {
    resource_group_name = azurerm_resource_group.example.name
    loadbalancer_id     = azurerm_lb.example.id
    name                = "secondary-fw"
    protocol            = "Tcp"
    frontend_port       = 5444
    backend_port        = 443
    frontend_ip_configuration_name = azurerm_lb.example.frontend_ip_configuration[0].name
    
}

resource "azurerm_network_interface_nat_rule_association" "primaryfw" {
    network_interface_id = azurerm_network_interface.primary-untrust.id
    ip_configuration_name = azurerm_network_interface.primary-untrust.ip_configuration[0].name
    nat_rule_id          = azurerm_lb_nat_rule.nat1.id
    
  
}

resource "azurerm_network_interface_nat_rule_association" "secondaryyfw" {
    network_interface_id = azurerm_network_interface.secondary-untrust.id
    ip_configuration_name = azurerm_network_interface.secondary-untrust.ip_configuration[0].name
    nat_rule_id          = azurerm_lb_nat_rule.nat2.id
  
}