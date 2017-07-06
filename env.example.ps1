<#
    Common variables used acrros the deployment scripts
#>
# Azure subscription Id and Azure account tenant Id can both be found by
# running `Get-AzureRmSubscription`
$subId=""
$aadTenantId=""
# Globally unique name for the cluster dns and a subscription-wide unique resource group name
$clusterName=""
$clusterRgName=""
# Location of cluster deployment
$clusterRgLoc=""
# Subscription-wide unique resource group name and location for extra resource group
$extRgName=""
$extRgLoc=""
# API Management instance name, organisation and admin email
$apimName=""
$apimOrg=""
$apimAdminEmail=""
# Azure Key Vault name, certificate name and password
$kvName=""
$certName=""
$certPassword=""

<#
    Common functions used across the deployment scripts
#>
Function ResourceGroupCreateIfNotExist([string]$ResourceGroupName,
                                       [string]$ResourceGroupLocation) {
    $resourceGroup=(Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Stop)
    if (-Not($resourceGroup))
    {
        Write-Host "Resource group '$ResourceGroupName' does not exist, creating it now"
        Try {
            $resourceGroup=(New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation)
        } Catch {
            Write-Error $_.Exception|format-list -force
            exit
        }
    } else {
        $status=$resourceGroup.ProvisioningState
        if ($status -ne "Succeeded") {
            Write-Error "Cannot deploy to resource group '$ResourceGroupName' whilst it is in state '$status'"
            exit
        }
        if ($resourceGroup.Location -ne $ResourceGroupLocation) {
            Write-Error "Resource group '$ResourceGroupName' is in the wrong location"
            exit
        }
        Write-Host "Using existing resource group"
    }
}

Function ResourceGroupFailIfNotExist([string]$ResourceGroupName,
                                     [string]$ResourceGroupLocation) {
     $resourceGroup=(Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction Stop)
    if (-Not($resourceGroup))
    {
        throw [System.IO.IOException] "Resource group '$ResourceGroupName' does not exist"
    }
}

Function PromptAzureLoginIfNeeded() {
    Try
    {  
        Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId -ErrorAction Stop
        Write-Host "Already logged in, setting context to: $AzureSubscription"
    }
    Catch {
        Write-Host "Not logged in, please authenticate using the pop up dialog"
        Login-AzureRmAccount
        Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId
        Write-Host "Logged in, setting context to: $AzureSubscription"
    }
}