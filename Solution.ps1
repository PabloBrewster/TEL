Set-Location C:\Users\pablo\source\repos\TEL

# Initialize PowerShell variables
$AADAdmin_id = "####-####-####-####-####"
$AADAdmin_name = "####@####.com"
$SQLAdminLogin = "####"
$SQLAdminPassword = "####"
$resourceGroupName  = "rgpbdev01"
$location = "uksouth"
$dataFactoryName = "dfpbdev01"
$SQLServerName = "sqlpbdev01"
$SQLDatabaseName = "SQL_data"
$cosmosAccountName = "cdbapbdev01"
$cosmosDBName = "cdbsqldb-pbdev01"
$cosmosDBContainer = "NoSQL_data"

# Deploy Azure resources using Terraform
# Assumes terraform is installed locally and initialized
# Terraform variables are initialized from environment variables
$Env:TF_VAR_AADAdmin_id = $AADAdmin_id;
$Env:TF_VAR_AADAdmin_name = $AADAdmin_name;
$Env:TF_VAR_SQLAdminLogin = $SQLAdminLogin;
$Env:TF_VAR_SQLAdminPassword = $SQLAdminPassword;
$Env:TF_VAR_resourceGroupName  = $resourceGroupName;
$Env:TF_VAR_location = $location;
$Env:TF_VAR_dataFactoryName = $dataFactoryName;
$Env:TF_VAR_SQLServerName = $SQLServerName;
$Env:TF_VAR_SQLDatabaseName = $SQLDatabaseName;
$Env:TF_VAR_cosmosAccountName = $cosmosAccountName;
$Env:TF_VAR_cosmosDBName = $cosmosDBName;
$Env:TF_VAR_cosmosDBContainer = $cosmosDBContainer;

Set-location ./terraform
terraform validate
terraform plan
terraform apply
Set-Location ../

# Grant Data Factory Managed Identity permissions for SQL DB
# Create Data Factory Managed Identity DB User for SQL DB 
# Assumes the SqlServer PowerShell module is installed
# Assumes SQL Server Firewall rule exceptions to allow this IP & 'Azure Resources' 
Connect-AzAccount
$access_token = (Get-AzAccessToken -ResourceUrl https://database.windows.net).Token
Invoke-Sqlcmd -ServerInstance $SQLServerName".database.windows.net" -Database $SQLDatabaseName -AccessToken $access_token -Query "CREATE USER [$dataFactoryName] FROM EXTERNAL PROVIDER;"
Invoke-Sqlcmd -ServerInstance $SQLServerName".database.windows.net" -Database $SQLDatabaseName -AccessToken $access_token -Query "ALTER ROLE [db_datareader] ADD MEMBER [$dataFactoryName];"
Invoke-Sqlcmd -ServerInstance $SQLServerName".database.windows.net" -Database $SQLDatabaseName -AccessToken $access_token -Query "ALTER ROLE [db_datawriter] ADD MEMBER [$dataFactoryName];"

# Add Cheap ETL solution
Invoke-Sqlcmd -ServerInstance $SQLServerName".database.windows.net" -Database $SQLDatabaseName `
-AccessToken $access_token -InputFile '.\SQL\CheapETLForCA.sql'

# Grant Data Factory Managed Identity permissions for Cosmos DB
# Assumes the Azure AZ PowerShell module is installed
$principalId = Get-AzADServicePrincipal -DisplayName $dataFactoryName
$roleDefinitionId = "00000000-0000-0000-0000-000000000002" #read-write
$principalId = (get-azdatafactoryV2 -ResourceGroupName $resourceGroupName -Name $dataFactoryName).Identity.principalId
New-AzCosmosDBSqlRoleAssignment -AccountName $cosmosAccountName `
    -ResourceGroupName $resourceGroupName `
    -RoleDefinitionId $roleDefinitionId `
    -Scope "/" `
    -PrincipalId $principalId

# Create a simple source 'operational' SQL application using a scratch db template - https://paulbrewer.wordpress.com/2015/07/19/sql-server-performance-synthetic-transaction-baseline/
$url = "https://raw.githubusercontent.com/PabloBrewster/CellularAutomation/refs/heads/main/CA_SQLBenchmark.sql"
$response = Invoke-WebRequest -Uri $url
$sql = $response.Content
Invoke-Sqlcmd -ServerInstance $SQLServerName".database.windows.net" -Database $SQLDatabaseName -AccessToken $access_token `
              -Query $sql

# Deploy Data Factory Linked Services, Data Sets, Pipeline and Trigger
Set-AzDataFactoryV2LinkedService -DataFactoryName $dataFactoryName 
    -ResourceGroupName $resourceGroupName -Name "ls_cdbapbdev01" 
    -DefinitionFile .\DataFactory\LinkedServices\ls_cdbapbdev01.json

# Data Factory Linked Service not deploying correctly, created manually due to time pressure
Set-AzDataFactoryV2LinkedService -DataFactoryName $dataFactoryName `
    -ResourceGroupName $resourceGroupName -Name "ls_sqlpbdev01" `
    -DefinitionFile .\DataFactory\LinkedServices\ls_sqlpbdev01.json

Set-AzDataFactoryV2Dataset -DataFactoryName $dataFactoryName `
    -ResourceGroupName $resourceGroupName -Name "ds_cosmosdb" `
    -DefinitionFile .\DataFactory\DataSets\ds_cosmosdb.json

Set-AzDataFactoryV2Dataset -DataFactoryName $dataFactoryName `
    -ResourceGroupName $resourceGroupName -Name "ds_sqldb" `
    -DefinitionFile .\DataFactory\DataSets\ds_sqldb.json

Set-AzDataFactoryV2DataFlow -DataFactoryName $dataFactoryName `
    -ResourceGroupName $resourceGroupName -Name "df_sqldb_to_cosmosdb" `
    -DefinitionFile .\DataFactory\DataFlows\df_sqldb_to_cosmosdb.json

Set-AzDataFactoryV2Pipeline -DataFactoryName $dataFactoryName `
    -ResourceGroupName $resourceGroupName -Name "pl_etl_Merkle" `
    -DefinitionFile .\DataFactory\Pipelines\pl_etl_merkle.json

Set-AzDataFactoryV2Trigger -DataFactoryName $dataFactoryName `
    -ResourceGroupName $resourceGroupName -Name "trpbhub00" `
    -DefinitionFile .\DataFactory\Triggers\trpbhub00.json

# Simulate OLTP workload in the source SQL DB
Invoke-Sqlcmd -ServerInstance $SQLServerName".database.windows.net" -Database $SQLDatabaseName `
-AccessToken $access_token -Query "EXECUTE dbo.CA_Benchmark @IO_Benchmark = 1, @StressLevel = 2, @Batches = 1;"

# Trigger pipeline to sync changes from SQL source to NoSQL sink
Invoke-AzDataFactoryV2Pipeline -DataFactory $dataFactoryName `
    -PipelineName "pl_etl_Merkle" `
    -ResourceGroupName $resourceGroupName

# Simulate OLTP workload (inserts) in source SQL DB
Invoke-Sqlcmd -ServerInstance $SQLServerName".database.windows.net" -Database $SQLDatabaseName `
-AccessToken $access_token -Query "EXECUTE dbo.CA_Benchmark @IO_Benchmark = 1, @StressLevel = 2, @Batches = 1;"

# Trigger pipeline to sync changes from SQL source to NoSQL sink (Inserts/Updates only, using timestamp > last data factory runtime)
Invoke-AzDataFactoryV2Pipeline -DataFactory $dataFactoryName `
    -PipelineName "pl_etl_Merkle" `
    -ResourceGroupName $resourceGroupName

# Delete all Azure resources created and used in this execution, the SQL DB source, CosmosDB sink, Data Factory & Resource Group. 
Set-location ./terraform
terraform destroy
Set-Location ../
