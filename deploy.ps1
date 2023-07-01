$location = "eastus"
$uid = $(New-Guid).ToString().Substring(0,8)
$deployFilename = $("./azure-deploy{0}.yaml" -f $uid)
$runnerName = "group-runner" + $uid
$rgName = "CS6300-GRP"
$saName = "cs6300grpstorageaccount"
$repoRegToken = "AAAPN2QGLON5I75G2T3G7F3ET6EU4"
$repoOwner = "pdieppa3"
$repoName = "gatech-android-app-sample"
$volumeName = "runner-data" + $uid
$saKey = az storage account keys list --resource-group CS6300-GRP --account-name $saName --query "[0].value" --output tsv
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
az storage share create --name $volumeName --account-name $saName --account-key $saKey

az container create --resource-group CS6300-GRP --file $deployFilename
