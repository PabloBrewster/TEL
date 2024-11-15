#########################################################################
# Resource Group
resource "azurerm_resource_group" "pb-rg-dev01" {
  name     = var.resourceGroupName
  location = var.location
}

#########################################################################
# Data Factory
resource "azurerm_data_factory" "pb-df" {
  name                = var.dataFactoryName
  location            = azurerm_resource_group.pb-rg-dev01.location
  resource_group_name = azurerm_resource_group.pb-rg-dev01.name
    identity {
    type = "SystemAssigned"
  }
  managed_virtual_network_enabled = true
}

#########################################################################
# SQL Server & Database
resource "azurerm_mssql_server" "pb-sql" {
  name                         = var.SQLServerName
  resource_group_name          = azurerm_resource_group.pb-rg-dev01.name
  location                     = azurerm_resource_group.pb-rg-dev01.location
  version                      = "12.0"
  administrator_login          = var.SQLAdminLogin
  administrator_login_password = var.SQLAdminPassword
  minimum_tls_version          = "1.2"  
   azuread_administrator {
    login_username = var.AADAdmin_name
    object_id      = var.AADAdmin_id
  } 
  public_network_access_enabled = true
}

resource "azurerm_mssql_database" "pb-sqldb" {
  name           = var.SQLDatabaseName
  server_id      = azurerm_mssql_server.pb-sql.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 1
  read_scale     = false
  sku_name       = "Basic"
  zone_redundant = false
}

#########################################################################
# Cosmos DB 
resource "azurerm_cosmosdb_account" "pb-cdba" {
  name                = var.cosmosAccountName
  location            = azurerm_resource_group.pb-rg-dev01.location
  resource_group_name = azurerm_resource_group.pb-rg-dev01.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.pb-rg-dev01.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "pb-cdb" {
  name                = var.cosmosDBName 
  resource_group_name = azurerm_resource_group.pb-rg-dev01.name
  account_name        = azurerm_cosmosdb_account.pb-cdba.name
}

resource "azurerm_cosmosdb_sql_container" "pb-sqlc" {
  name                = var.cosmosDBContainer
  resource_group_name = azurerm_resource_group.pb-rg-dev01.name
  account_name        = azurerm_cosmosdb_account.pb-cdba.name
  database_name       = azurerm_cosmosdb_sql_database.pb-cdb.name
  partition_key_path  = "/partitionKey"
}
