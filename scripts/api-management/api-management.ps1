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
  $Sku="Standard",
  [string]
  $VpnType="External",
  [string]
  $VirtualNetwork=""
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

$apimService = New-AzureRmApiManagement -ResourceGroupName $AzureResourceGroupName `
                                        -Location $AzureResourceGroupLocation `
                                        -Name $ApimName `
                                        -Organization $Organization `
                                        -AdminEmail $AdminEmail `
                                        -VirtualNetwork $apimVirtualNetwork `
                                        -VpnType $VpnType `
                                        -Sku $Sku 2>&1 | Out-File C:\apim.txt -Append