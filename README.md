# Transform - Extract - Load
This was a basic exercise in DevOps and Data Engineering, to deploy and execute a new application in Azure using Terraform and PowerShell. It generates, reads and transforms synthetic data from a newly built SQL Azure DB source and synchronizes the changes to a CosmosDB NoSQL sink using Data Factory

Requirements
 - Source Database: Deploys a new Azure SQL DB instance and a synthetic OLTP workload database application https://github.com/PabloBrewster/CellularAutomation.
 - Sink Database: Deploys a new CosmosDB NoSQL account
 - Pipeline Components: Deploys a Data Factory resource to synchronize source insert/update deltas to the target sink.

Repository Description 
 - Solution.ps1: Is the driver script for the deployment and execution of the new Azure recourses, it performs the following actions:
 - Sets variables used by Terraform and PowerShell
 - Deploys Azure resources using Terraform
 - PowerShell Creates a SQL user for the Data Factory Managed Identity, assigns minimum privileges
 - PowerShell Grants Data Factory Managed Identity permissions to target CosmosDB
 - PowerShell Deploys Data Factory Components
 - Simulates a synthetic OLTP workload in the SQL DB
 - Triggers Data Factory pipeline to synchronize upserts to the NoSQL sink.
