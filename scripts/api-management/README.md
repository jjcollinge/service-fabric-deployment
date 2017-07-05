# Azure API Management
Deploy an API Management instance to facade your cluster's APIs.

```
$virtualNetwork=(Get-AzureRmVirtualNetwork -ResourceName VNet -ResourceGroupName '<resourcegroupname>')
./api-management.ps1 -AzureSubscriptionId '<your-subscriptionId>' -AzureResourceGroupName '<resourcegroupname>' -AzureResourceGroupLocation '<resourcegrouplocation>' -ApimName '<apim-name>' -Organization '<organization-name>' -AdminEmail '<admin-email>'
```

