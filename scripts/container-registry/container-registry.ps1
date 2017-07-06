Param(
  [Parameter(Mandatory=$True)]
  [string]
  $AzureSubscriptionId,
  [Parameter(Mandatory=$True)]
  [string]
  $AzureResourceGroupName,
  [string]
  $TemplateFile="../../templates/container-registry/azuredeploy.json",
  [string]
  $TemplateParametersFile="../../templates/container-registry/azuredeploy.parameters.json"
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

echo "Starting Azure Container Registry Deployment"
New-AzureRmResourceGroupDeployment -Name "acrdeploy" `
                                   -ResourceGroupName $AzureResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -TemplateParameterFile $TemplateParametersFile  2>&1 | Out-File C:\container-registry.txt -Append