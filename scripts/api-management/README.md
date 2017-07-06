# Azure API Management
Deploy an API Management instance to facade your cluster's APIs.

```
$vnet=(Get-AzureRmVirtualNetwork -ResourceName VNet -ResourceGroupName '<resourcegroupname>')
Add-AzureRmVirtualNetworkSubnetConfig -Name APIM -VirtualNetwork $vnet -AddressPrefix 192.168.4.0/24
Set-AzureRmVirtualNetwork -VirtualNetwork $vnet
$apimSubnet=$vnet.Subnets[3].Id
$apimVnet=(New-AzureRmApiManagementVirtualNetwork -Location "West US" -SubnetResourceId $apimSubnet)
./api-management.ps1 -AzureSubscriptionId '<your-subscriptionId>' -AzureResourceGroupName '<resourcegroupname>' -AzureResourceGroupLocation '<resourcegrouplocation>' -ApimName '<apim-name>' -Organization '<organization-name>' -VirtualNetwork $apimVnet -AdminEmail '<admin-email>'
```

