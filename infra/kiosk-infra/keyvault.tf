resource "azurerm_key_vault" "kiosk_kv" {
  name                = "kv-${var.project_name}-${var.environment}"
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  resource_group_name = azurerm_resource_group.rg.name

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}
data "azurerm_client_config" "current" {}

# Now give Access for app service managed identiy for above Key vault

resource "azurerm_key_vault_access_policy" "app_access" {
  key_vault_id = azurerm_key_vault.kiosk_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_windows_web_app.app.identity[0].principal_id

  secret_permissions = ["Get", "List"]

  depends_on = [
    azurerm_windows_web_app.app
  ]
}

# Give Terraform user access to the Key Vault

resource "azurerm_key_vault_access_policy" "terraform_user" {
  key_vault_id = azurerm_key_vault.kiosk_kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set"]
}

#Create Private Endpoint for Key vault

resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-kv-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "kv-connection"
    private_connection_resource_id = azurerm_key_vault.kiosk_kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false

  }
}

#Create Private DNS for Key vault

resource "azurerm_private_dns_zone" "kv_dns" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg.name
}

#Link Private DNS of Keyvault to the VNET created earlier

resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_link" {
  name                  = "dnslink-kv"
  resource_group_name   = azurerm_resource_group.rg.name
  virtual_network_id    = azurerm_virtual_network.kiosk_vnet.id
  private_dns_zone_name = azurerm_private_dns_zone.kv_dns.name
}


#Add DNS record to Key vault.. Usually Azure will create it but I am adding explicit

resource "azurerm_private_dns_a_record" "kv_record" {
  name                = azurerm_key_vault.kiosk_kv.name
  zone_name           = azurerm_private_dns_zone.kv_dns.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.kv_pe.private_service_connection[0].private_ip_address]
}

resource "azurerm_key_vault_secret" "sql_conn" {
  name         = "sql-connection-string"
  key_vault_id = azurerm_key_vault.kiosk_kv.id
  #value        = "dummy-placeholder" #Because SQL Server hasn't been created yet, so Terraform cannot form a real connection string yet.
  value = "Server=tcp:${azurerm_mssql_server.sql_server.fully_qualified_domain_name},1433;Database=${azurerm_mssql_database.sql_db.name};User ID=${var.sql_admin_user};Password=${var.sql_admin_password};Encrypt=true;Connection Timeout=30;"

  depends_on = [
    azurerm_mssql_server.sql_server,
    azurerm_mssql_database.sql_db,
    azurerm_private_endpoint.sql_pe,
    azurerm_private_endpoint.sql_pe,
    azurerm_key_vault_access_policy.terraform_user
  ]
}