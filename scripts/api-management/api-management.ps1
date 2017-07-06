Param(
  [Parameter(Mandatory=$True)]
  [string]
  $AzureSubscriptionId,
  [Parameter(Mandatory=$True)]
  [string]
  $DeployToResourceGroupName,
  [Parameter(Mandatory=$True)]
  [string]
  $DeployToResourceGroupLocation,
  [Parameter(Mandatory=$True)]
  [string]
  $VNetResourceGroupName,
  [Parameter(Mandatory=$True)]
  [string]
  $VNetResourceGroupLocation,
  [Parameter(Mandatory=$True)]
  [string]
  $ApimName,
  [Parameter(Mandatory=$True)]
  [string]
  $Organization,
  [Parameter(Mandatory=$True)]
  [string]
  $AdminEmail,
  [string]
  $Sku="Premium",
  [string]
  $VpnType="External"
)

PromptAzureLoginIfNeeded

ResourceGroupCreateIfNotExist -ResourceGroupName $AzureResourceGroupName -ResourceGroupLocation $AzureResourceGroupLocation
Try {
    ResourceGroupFailIfNotExist -ResourceGroupName $VNetResourceGroupName -ResourceGroupLocation $VNetResourceGroupLocation
} Catch {
    Write-Error $_.Exception | format-list -force
    exit
}

Write-Host "Getting existing virtual network"
$vnet=(Get-AzureRmVirtualNetwork -ResourceName VNet -ResourceGroupName $VNetResourceGroupName -ErrorAction SilentlyContinue)
if (-Not($vnet)) {
    Write-Error "Could not get existing virtual network"
    exit
}

Write-Host "Getting existing API Management subnet"
$apimSubnet=(Get-AzureRmVirtualNetworkSubnetConfig -Name APIM -VirtualNetwork $vnet -ErrorAction SilentlyContinue)
if (-Not($apimSubnet )) {
    Write-Host "API Management subnet does not already exists, creating it now"
    Add-AzureRmVirtualNetworkSubnetConfig -Name APIM -VirtualNetwork $vnet -AddressPrefix 192.168.4.0/24
    Try {
        $vnet=(Set-AzureRmVirtualNetwork -VirtualNetwork $vnet)
        $apimSubnet=(Get-AzureRmVirtualNetworkSubnetConfig -Name APIM -VirtualNetwork $vnet)
    } Catch {
        Write-Error $_.Exception | format-list -force
        exit
    }
}

Write-Host "Using API Management Subnet: $apimSubnet.Id"
$apimVnet=(New-AzureRmApiManagementVirtualNetwork -Location $DeployToResourceGroupName -SubnetResourceId $apimSubnet.Id)

Write-Host "Deploying new API Management instance"
Try {
    New-AzureRmApiManagement -ResourceGroupName $DeployToResourceGroupName `
                        -Location $DeployToResourceGroupLocation `
                        -Name $ApimName `
                        -Organization $Organization `
                        -AdminEmail $AdminEmail `
                        -VirtualNetwork $apimVnet `
                        -VpnType $VpnType `
                        -Sku $Sku 2>&1 | Out-File apim.txt -ErrorAction Stop
}
Catch {
    Write-Error $_.Exception | format-list -force
    exit
}
Write-Host "Successfully completed script"