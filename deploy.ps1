$repoRegToken = "AAAGRAY44YNVRZBLH7HJLMTEUDSFU"
$repoOwner = "gt-omscs-se-2023summer"
$repoName = "6300Summer23Team127"
$rgName = "CS6300-GRP" # Resource Group Name for the current subscription
$saName = "cs6300grpstorageaccount" # Storage account name must be lowercase, and in the current subscription


#<ONLY EDIT BELOW IF YOU ARE COMFORTABLE WITH AZURE>#
$location = "eastus"
$uid = $(New-Guid).ToString().Substring(0,8)
$deployFilename = $("./azure-deploy-{0}.yaml" -f $uid)
$runnerName = "runner-" + $uid
$volumeName = "runner-" + $uid + "-data"
$saKey = az storage account keys list --resource-group $rgName --account-name $saName --query "[0].value" --output tsv
Write-Host "Found Key: $saKey" -foregroundcolor green

$yaml = Get-Content ./template-azure-deploy.yaml
$yaml = $yaml -replace "<<sakey>>", $saKey
$yaml = $yaml -replace "<<saname>>", $saName
$yaml = $yaml -replace "<<runnername>>", $runnerName
$yaml = $yaml -replace "<<reporegtoken>>", $repoRegToken
$yaml = $yaml -replace "<<repoowner>>", $repoOwner
$yaml = $yaml -replace "<<reponame>>", $repoName
$yaml = $yaml -replace "<<volumename>>", $volumeName
$yaml = $yaml -replace "<<location>>", $location
$yaml | Out-File $deployFilename

# Create the Azure file share
# az storage share delete --name $volumeName --account-name $saName --account-key $saKey
az storage share create --name $volumeName --account-name $saName --account-key $saKey

# Create the Azure Container Instance
az container create --resource-group CS6300-GRP --file $deployFilename

# https://learn.microsoft.com/en-us/azure/container-instances/container-instances-volume-azure-files

# az container create `
#     --resource-group $rgName `
#     --name $runnerName `
#     --image armyguy255a/github-runner-gatech:latest `
#     --dns-name-label $runnerName `
#     --ports 80 `
#     --environment-variables REG_TOKEN=$repoRegToken GH_OWNER=$repoOwner GH_REPOSITORY=$repoName `
#     --azure-file-volume-account-name $saName `
#     --azure-file-volume-account-key $saKey `
#     --azure-file-volume-share-name $volumeName `
#     --azure-file-volume-mount-path "/mnt"


az container logs --resource-group $rgName --name $runnerName


return 
#Delete resources
az container delete --resource-group $rgName --name $runnerName --yes
az storage share delete --name $volumeName --account-name $saName --account-key $saKey

#Backup the registration configuration
#Login to the container remotely
az container exec --resource-group CS6300-GRP --name $runnerName --exec "/bin/bash"
az login
az account set --subscription "Visual Studio Enterprise Subscription"
tar -czvf actions-runner-backup.tar.gz /home/docker/actions-runner
STORAGE_KEY=$(az storage account keys list --resource-group CS6300-GRP --account-name cs6300grpstorageaccount --query "[0].value" --output tsv)
echo $STORAGE_KEY
az storage blob upload --account-name cs6300grpstorageaccount --account-key $STORAGE_KEY --container-name runner-backups --name actions-runner-backup.tar.gz --type block --file ./actions-runner-backup.tar.gz --output none