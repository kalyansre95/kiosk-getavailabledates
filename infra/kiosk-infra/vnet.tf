resource "azurerm_virtual_network" "kiosk_vnet" {
  name                = "vnet-${var.project_name}-${var.environment}"
  address_space       = ["10.10.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

#Subnet for App Service Vnet integration

resource "azurerm_subnet" "appservice_subnet" {
  name                 = "subnet-appservice"
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.10.1.0/24"]
  virtual_network_name = azurerm_virtual_network.kiosk_vnet.name

  delegation {
    name = "delegation_app_service"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

#Subnet for Private Endpoints Vnet Integration

resource "azurerm_subnet" "pe_subnet" {
  name                                          = "subnet-private-endpoints"
  resource_group_name                           = azurerm_resource_group.rg.name
  address_prefixes                              = ["10.10.2.0/24"]
  virtual_network_name                          = azurerm_virtual_network.kiosk_vnet.name
  private_link_service_network_policies_enabled = true
}