# DataFactory-ChangeDataCapture
Deploys and executes a pipeline an Azure using Terraform and PowerShell. 
Reads synthetic data from a newly commissioned SQL Azure DB source and synchronizes changes to a CosmosDB NoSQL sink using Data Factory. 

Requirements
1. Source Database: Deploy Azure SQL DB with the Change Data Capture feature Enabled
2. Target Database: CosmosDB NoSQL
3. Pipeline Components: Data Factory synchronizing inserts and updates.

Repository Description
Solution.ps1: Is the driver script for the deployment of Azure resourses
 - Sets variables used by Terraform and PowerShell 
 - Deploys Azure resources using Terraform
 - Powershell Creates a SQL user for the Data Factory Managed Identity, assigns minimum privileges
 - PowerShell Grants Data Factory Managed Identity permissions to target CosmosDB
 - PowerShell Deploys Data Factory Components
 - Simulates a synthetic OLTP workload in the SQL DB
 - Triggers Data Factory pipeline to synchronize upserts to the NoSQL sink.


