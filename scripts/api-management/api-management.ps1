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

# Login to Azure PowerShell CLI and set context
Try
{  
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId -ErrorAction Stop
}
Catch {
    Login-AzureRmAccount
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId
}

echo "Getting existing Virtual Network"
$vnet=(Get-AzureRmVirtualNetwork -ResourceName VNet -ResourceGroupName $VNetResourceGroupName)

echo "Getting existing API Management subnet"
$apimSubnet=(Get-AzureRmVirtualNetworkSubnetConfig -Name APIM -VirtualNetwork $vnet -ErrorAction SilentlyContinue)
if ( -Not($apimSubnet)) {
    echo "API Management subnet does not exists, I'll create it now"
    Add-AzureRmVirtualNetworkSubnetConfig -Name APIM -VirtualNetwork $vnet -AddressPrefix 192.168.4.0/24
    $vnet=(Set-AzureRmVirtualNetwork -VirtualNetwork $vnet)
    $apimSubnet=(Get-AzureRmVirtualNetworkSubnetConfig -Name APIM -VirtualNetwork $vnet)
}
$apimVnet=(New-AzureRmApiManagementVirtualNetwork -Location $DeployToResourceGroupName -SubnetResourceId $apimSubnet.Id)

echo "Deploying new API Management instance"
New-AzureRmApiManagement -ResourceGroupName $DeployToResourceGroupName `
                                        -Location $DeployToResourceGroupLocation `
                                        -Name $ApimName `
                                        -Organization $Organization `
                                        -AdminEmail $AdminEmail `
                                        -VirtualNetwork $apimVnet `
                                        -VpnType $VpnType `
                                        -Sku $Sku 2>&1 | Out-File apim.txt -Append