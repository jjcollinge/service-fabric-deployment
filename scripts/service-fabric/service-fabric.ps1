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

PromptAzureLoginIfNeeded

ResourceGroupCreateIfNotExist -ResourceGroupName $AzureResourceGroupName -ResourceGroupLocation $AzureResourceGroupLocation

echo "Starting Azure Service Fabric cluster deployment, hang tight this may take a while"
Try {
    $rand=(Get-Random -Maximum 999 -Minimum 0)
    New-AzureRmResourceGroupDeployment -Name "asfdeploy$rand" `
                                    -ResourceGroupName $AzureResourceGroupName `
                                    -TemplateFile $TemplateFile `
                                    -TemplateParameterFile $TemplateParametersFile  2>&1 | Out-File servie-fabric.txt
} Catch {
    Write-Error $_.Exception | format-list -force
    exit
}
Write-Host "Successfully completed script"