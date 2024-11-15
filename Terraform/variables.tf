#https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables

variable "resourceGroupName" {
    description = "Resource Group Name"
    type = string
    sensitive = false
}

variable "dataFactoryName" {
    description = "Data Factory Name"
    type = string
    sensitive = false
}

variable "SQLServerName" {
    description = "SQL Server Name"
    type = string
    sensitive = false
}

variable "SQLDatabaseName" {
    description = "SQL Database Name"
    type = string
    sensitive = false
}

variable "cosmosAccountName" {
    description = "CosmosDB Account Name"
    type = string
    sensitive = false
}

variable "cosmosDBName" {
    description = "CosmosDB Database Name"
    type = string
    sensitive = false
}

variable "cosmosDBContainer" {
    description = "CosmosDB Container Name"
    type = string
    sensitive = false
}

variable "location" {
    description = "Local"
    type = string
    sensitive = false
}

variable "AADAdmin_name" {
    description = "Entra Admin Name"
    type = string
    sensitive = true
}

variable "AADAdmin_id" {
    description = "Entra Admin ID"
    type = string
    sensitive = true
}

variable "SQLAdminLogin" {
    description = "SQL Admin Name"
    type = string
    sensitive = true
}

variable "SQLAdminPassword" {
    description = "SQL Admin Password"
    type = string
    sensitive = true
}

