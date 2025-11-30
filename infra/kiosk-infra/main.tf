locals {
  rg_name   = "rg-${var.project_name}-${var.environment}"
  plan_name = "asp-${var.project_name}-${var.environment}"
  app_name  = "app-${var.project_name}-getavailabledates-${var.environment}"
}

#1) Resource Group

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

#2 App service plan creation

resource "azurerm_service_plan" "plan" {
  name     = local.plan_name
  location = var.location
  #location       = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type  = "Windows"
  sku_name = "B1" # change to F1 if you want Free Tier

}

#3 App Service Creation

resource "azurerm_windows_web_app" "app" {
  name                = local.app_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id

  https_only = true

  site_config {
    application_stack {
      dotnet_version = "v8.0"
    }
  }

  app_settings = {
    "ENVIRONMENT"                      = upper(var.environment)
    "WEBSITE_RUN_FROM_PACKAGE"         = "0"
    "SQL_CONNECTION_STRING_SECRET_URI" = "https://${azurerm_key_vault.kiosk_kv.name}.vault.azure.net/secrets/sql-connection-string"
  }
  identity {
    type = "SystemAssigned"
  }
}
