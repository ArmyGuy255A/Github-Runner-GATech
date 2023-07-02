$repoRegToken = "AAAPN2VCRPOLVB7I6BBCQPDEUDLIW"
$repoOwner = "pdieppa3"
$repoName = "gatech-android-app-sample"
$rgName = "CS6300-GRP" # Resource Group Name for the current subscription
$saName = "cs6300grpstorageaccount" # Storage account name must be lowercase, and in the current subscription


#<ONLY EDIT BELOW IF YOU ARE COMFORTABLE WITH AZURE>#
$location = "eastus"
$uid = $(New-Guid).ToString().Substring(0,8)
$deployFilename = $("./azure-deploy{0}.yaml" -f $uid)
$runnerName = "runner-" + $uid
$volumeName = "runner-" + $uid + "-data"
$saKey = az storage account keys list --resource-group CS6300-GRP --account-name $saName --query "[0].value" --output tsv
Write-Host "Found Key: $saKey" -foregroundcolor green

# $yaml = Get-Content ./template-azure-deploy.yaml
# $yaml = $yaml -replace "<<sakey>>", $saKey
# $yaml = $yaml -replace "<<saname>>", $saName
# $yaml = $yaml -replace "<<runnername>>", $runnerName
# $yaml = $yaml -replace "<<reporegtoken>>", $repoRegToken
# $yaml = $yaml -replace "<<repoowner>>", $repoOwner
# $yaml = $yaml -replace "<<reponame>>", $repoName
# $yaml = $yaml -replace "<<volumename>>", $volumeName
# $yaml = $yaml -replace "<<location>>", $location
# $yaml | Out-File $deployFilename

# Create the Azure file share
az storage share delete --name $volumeName --account-name $saName --account-key $saKey
az storage share create --name $volumeName --account-name $saName --account-key $saKey

# Create the Azure Container Instance
# az container create --resource-group CS6300-GRP --file $deployFilename

az container create `
    --resource-group $rgName `
    --name $runnerName `
    --image armyguy255a/github-runner-gatech:latest `
    --dns-name-label $runnerName `
    --ports 80 `
    --environment-variables REG_TOKEN=$repoRegToken GH_OWNER=$repoOwner GH_REPOSITORY=$repoName `
    --azure-file-volume-account-name $saName `
    --azure-file-volume-account-key $saKey `
    --azure-file-volume-share-name $volumeName `
    --azure-file-volume-mount-path /home/docker/actions-runner
