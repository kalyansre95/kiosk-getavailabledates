resource "azurerm_app_service_virtual_network_swift_connection" "app_service_vnet_integartion" {
  app_service_id = azurerm_windows_web_app.app.id
  subnet_id      = azurerm_subnet.appservice_subnet.id
}