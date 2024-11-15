# DataFactory-ChangeDataCapture
Deploys an Azure solution using Terraform that utilizes the Preview Change Data Capture feature in Data Factory. 

Requirements
1. Source Database: Deploy Azure SQL DB with the Change Data Capture feature Enabled
2. Target Database: CosmosDB NoSQL
3. Pipeline Components: Extraction using Data Factory and Change Data Capture.

Repository Description
Solution.ps1: Is the driver script for the deployment of Azure resourses
 - Sets environmental variables that assume an Azure target with Terraform and Azure Client ID preconfigured
 - Deploys Azure resources using Terraform
 - Powershell Creates a SQL user for the Data Factory Managed Identity, assigns minimum privileges
 - PowerShell Creates SQL DB Table, enables Change Data Capture  
 - PowerShell Grants Data Factory Managed Identity permissions to target CosmosDB
 - PowerShell Deploys Data Factory Components

Objective
Once deployed, the Data Factory solution detects DML data changes in the source database table then extracts, transforms and loads it to the target database. 

