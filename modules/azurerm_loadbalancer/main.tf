data "azurerm_public_ip" "ip" {
  name                = var.public_ip_name
  resource_group_name = var.resource_group_name
}

variable "public_ip_name" {
  description = "The name of the Public IP"
  type        = string
}
variable "resource_group_name" {
  description = "The name of the Resource Group in which the Public IP is created"
  type        = string
}



resource "azurerm_lb" "lb" {
  name                = "raman-lb"
  location            = "centralindia"
  resource_group_name = var.resource_group_name

  frontend_ip_configuration {
    name                 = "NetflixPublicIPAddress"
    public_ip_address_id = data.azurerm_public_ip.ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "pool1" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "lb-BackEndAddressPool1"
}

resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "netflix-probe"
  port            = 80
}

# IP and Port based Routing
resource "azurerm_lb_rule" "lb_rule" {
  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "NetflixRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "NetflixPublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool1.id]
  probe_id                       = azurerm_lb_probe.probe.id
}


