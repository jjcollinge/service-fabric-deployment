Param(
  [Parameter(Mandatory=$True)]
  [string]
  $AzureSubscriptionId,
  [Parameter(Mandatory=$True)]
  [string]
  $AzureResourceGroupName,
  [string]
  $TemplateFile="templates/container-registry/azuredeploy.json",
  [string]
  $TemplateParametersFile="templates/container-registry/azuredeploy.parameters.json"
)

PromptAzureLoginIfNeeded

echo "Starting Azure Container Registry Deployment"
Try {
    New-AzureRmResourceGroupDeployment -Name "acrdeploy" `
                                   -ResourceGroupName $AzureResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -TemplateParameterFile $TemplateParametersFile 2>&1 | Out-File container-registry.txt
} Catch {
    Write-Error $_.Exception | format-list -force
    exit
}
Write-Host "Successfully completed script"
