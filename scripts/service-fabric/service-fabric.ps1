Param(
  [Parameter(Mandatory=$True)]
  [string]
  $AzureSubscriptionId,
  [Parameter(Mandatory=$True)]
  [string]
  $AzureResourceGroupName,
  [Parameter(Mandatory=$True)]
  [string]
  $AzureResourceGroupLocation,
  [string]
  $TemplateFile="templates/service-fabric/azuredeploy.json",
  [string]
  $TemplateParametersFile="templates/service-fabric/azuredeploy.parameters.json"
)

# Login to Azure PowerShell CLI and set context
Try
{  
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId -ErrorAction Stop
}
Catch {
    Login-AzureRmAccount
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId
}

# NOTE: Make sure resource group is in same location as cluster
$resourceGroup=(Get-AzureRmResourceGroup -Name $AzureResourceGroupName -ev notPresent -ea 0)
if ($notPresent)
{
    echo "Creating new resource group"
    $resourceGroup=(New-AzureRmResourceGroup -Name $AzureResourceGroupName -Location $AzureResourceGroupLocation)
} else {
    echo "Using existing resource group"
}
if ($resourceGroup.ProvisioningState -eq "Deleting") {
    echo "Error: Resource group is currently being deleted"
    exit
}
if ($resourceGroup.Location -ne $AzureResourceGroupLocation) {
    echo "Error: Resource group is not in the correct location"
    exit
}

echo "Starting Azure Service Fabric cluster deployment, hang tight this may take a while"
$rand=(Get-Random -Maximum 999 -Minimum 0)
New-AzureRmResourceGroupDeployment -Name "asfdeploy$rand" `
                                   -ResourceGroupName $AzureResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -TemplateParameterFile $TemplateParametersFile  2>&1 | Out-File servie-fabric.txt -Append