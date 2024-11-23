# Data Factory: Transform - Extract - Load
This was a self learning exercise in basic Azure DevOps and Data Engineering, to deploy, execute then destroy a data pipeline in Azure using Terraform and PowerShell. It generates then reads and transforms generic geometric data in a SQL Azure DB source and synchronizes the changes to a Cosmos DB NoSQL sink using Data Factory: For novelty, a data type transform is performed in a source view hence the click bait TED title joke. Incremental inserts and updates in the source data are synchronized using timestamps but delete's are not. If synchronizing source deletes were important then Change Data Capture would have been an a better but more expensive choice. 

Objectives

Source Database: Deploy a new Azure SQL DB instance with test data
Sink Database: Deploys a new Cosmos DB NoSQL account
Pipeline: Deploys a Data Factory resource to synchronize source insert/update deltas to the target sink.

Technical Summary 

The Solution.ps1 script Is the driver script for the deployment, execution then destruction of new Azure resources performing the following actions:

Sets variables used by Terraform and PowerShell
Deploys Azure resources using Terraform
Grants Data Factory Managed Identity permissions for source SQL
Grants Data Factory Managed Identity permissions to target Cosmos DB
Deploys Data Factory Components
Installs a stub 'Cellular Automation' test data application 
Installs 'Timestamp ETL' SQL components for delta synchronization of stub test data 
Simulates a synthetic OLTP workload in the source SQL DB
Triggers a Data Factory pipeline to synchronize to the NoSQL sink.
Simulates a second synthetic OLTP workload in the source SQL DB
Triggers a second Data Factory pipeline to synchronize the delta inserts/updates to the NoSQL sink.
Terraform Destroys all the Azure resources created by the solution.

Conclusion

This was an interesting project in my own time using my personal Azure subscription, PowerShell and Terraform commands from Google, Co-pilot and stub Cellular Automation test data generated using an application I developed in my own time many years ago. All the techniques, scripts, variables used were made up on the fly and run in my personal Azure subscription for a total cost of about £12. 
