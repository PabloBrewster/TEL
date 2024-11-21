# Transform - Extract - Load
This was an exercise in basic Azure DevOps and Data Engineering, to deploy and execute a new application in Azure using Terraform and PowerShell. It generates, reads and transforms synthetic geometric data in a SQL Azure DB source and synchronizes the changes to a CosmosDB NoSQL sink using Data Factory: For novelty and expediency, a data type transform is performed in a source view. Incremental inserts and updates in the source data are synchronized but delete's are not. If synchronizing source deletes were important then Change Data Capture would be an a better but more expensive choice.

Requirements
 - Source Database: Deploys a new Azure SQL DB instance and a synthetic OLTP workload database application https://github.com/PabloBrewster/CellularAutomation.
 - Sink Database: Deploys a new CosmosDB NoSQL account
 - Pipeline Components: Deploys a Data Factory resource to synchronize source insert/update deltas to the target sink.

Technical Summary 

 - Sets variables used by Terraform and PowerShell
 - Deploys Azure resources using Terraform
 - Grants Data Factory Managed Identity permissions for source SQL
 - Grants Data Factory Managed Identity permissions to target CosmosDB
 - Deploys Data Factory Components
 - Installs a stub test data generator 
 - Installs 'Cheap ETL' SQL components for delta synchronization of stub test data 
 - Simulates a synthetic OLTP workload in the source SQL DB
 - Triggers a Data Factory pipeline to synchronize the NoSQL sink.
 - Simulates a second synthetic OLTP workload in the source SQL DB
 - Triggers a second Data Factory pipeline to synchronize changes to the NoSQL sink.
 - Terraform Destroys all the Azure resources created by the solution, deletes the Azure SQL DB, Data Factory, CosmosDB NoSQL Account and Resource Group.

Conclusion

This was an interesting project in my own time using my personal Azure subscription, PowerShell and Terraform commands from Google, Co-pilot and stub Cellular Automation test data generated using an application I developed in my own time.  All the techniques, scripts, variables used were made up on the fly and run in my personal Azure subscription for a total cost of about £12. 
