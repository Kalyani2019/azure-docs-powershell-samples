# Reference: Az.CosmosDB | https://docs.microsoft.com/powershell/module/az.cosmosdb
# --------------------------------------------------
# Purpose
# Create Cosmos Gremlin API account, database, and graph
# with dedicated throughput and conflict resolution policy
# with last writer wins and custom resolver path
# --------------------------------------------------
Function New-RandomString{Param ([Int]$Length = 10) return $(-join ((97..122) + (48..57) | Get-Random -Count $Length | ForEach-Object {[char]$_}))}
# --------------------------------------------------
$uniqueId = New-RandomString -Length 7 # Random alphanumeric string for unique resource names
$apiKind = "Gremlin"
# --------------------------------------------------
# Variables - ***** SUBSTITUTE YOUR VALUES *****
$locations = @("East US", "West US") # Regions ordered by failover priority
$resourceGroupName = "myResourceGroup" # Resource Group must already exist
$accountName = "cosmos-$uniqueId" # Must be all lower case
$consistencyLevel = "Session"
$tags = @{Tag1 = "MyTag1"; Tag2 = "MyTag2"; Tag3 = "MyTag3"}
$databaseName = "myDatabase"
$graphName = "myGraph"
$graphRUs = 400
$partitionKeys = @("/myPartitionKey")
# --------------------------------------------------
$conflictResolutionPath = "/_ts"
# --------------------------------------------------
Write-Host "Creating account $accountName"
$account = New-AzCosmosDBAccount -ResourceGroupName $resourceGroupName `
    -Location $locations -Name $accountName -ApiKind $apiKind -Tag $tags `
    -DefaultConsistencyLevel $consistencyLevel `
    -EnableAutomaticFailover:$true

Write-Host "Creating database $databaseName"
$database = Set-AzCosmosDBGremlinDatabase -InputObject $account `
    -Name $databaseName

# Prepare conflict resolution policy object for graph
$conflictResolutionPolicy = New-AzCosmosDBGremlinConflictResolutionPolicy `
    -Type LastWriterWins -Path $conflictResolutionPath

Write-Host "Creating graph $graphName"
$graph = Set-AzCosmosDBGremlinGraph -InputObject $database `
    -Name $graphName -Throughput $graphRUs `
    -PartitionKeyKind Hash -PartitionKeyPath $partitionKeys `
    -ConflictResolutionPolicy $conflictResolutionPolicy
