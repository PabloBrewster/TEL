# Transform - Extract - Load
Deploys and executes a pipeline solution in Azure using Terraform and PowerShell that reads synthetic data from a newly built SQL Azure DB source and synchronizes changes to a CosmosDB NoSQL sink using Data Factory. 


Requirements
1. Source Database: Deploys a new Azure SQL DB instance and a synthetic OLTP workload database application https://github.com/PabloBrewster/CellularAutomation.
2. Sink Database: Deploys a new CosmosDB NoSQL account
3. Pipeline Components: Deploys a Data Factory resource to synchronize source upserts to target sink.


Repository Description
Solution.ps1: Is the driver script for the deployment of Azure resourses
 - Sets variables used by Terraform and PowerShell 
 - Deploys Azure resources using Terraform
 - Powershell Creates a SQL user for the Data Factory Managed Identity, assigns minimum privileges
 - PowerShell Grants Data Factory Managed Identity permissions to target CosmosDB
 - PowerShell Deploys Data Factory Components
 - Simulates a synthetic OLTP workload in the SQL DB
 - Triggers Data Factory pipeline to synchronize upserts to the NoSQL sink.


