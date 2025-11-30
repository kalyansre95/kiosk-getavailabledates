resource "azurerm_mssql_server" "sql_server" {
  name                         = "sql-${var.project_name}-${var.environment}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password

  public_network_access_enabled = false
}

resource "azurerm_mssql_database" "sql_db" {
  name      = "db-${var.project_name}"
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "Basic"
}

# Private Endpoint for SQL
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "pe-sql-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "sql-connection"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

# Private DNS Zone for SQL
resource "azurerm_private_dns_zone" "sql_dns" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

# Link SQL Private DNS Zone with VNET
resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "dnslink-sql"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.kiosk_vnet.id
}

# SQL DNS A-record
resource "azurerm_private_dns_a_record" "sql_record" {
  name                = azurerm_mssql_server.sql_server.name
  zone_name           = azurerm_private_dns_zone.sql_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  records = [
    azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address
  ]
}