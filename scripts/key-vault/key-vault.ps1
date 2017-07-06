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
  $KeyVaultName,
  [Parameter(Mandatory=$True)]
  [string]
  $CertName,
  [Parameter(Mandatory=$True)]
  [string]
  $CertDnsName,
  [Parameter(Mandatory=$True)]
  [string]
  $Password
)

$OutputPath="$pwd/certs"

# Login to Azure PowerShell CLI and set context
Try
{  
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId -ErrorAction Stop
}
Catch {
    Login-AzureRmAccount
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId
}

# Create resource group if it doesn't already exist
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

# Create Azure Key Vault
echo "Creating Azure Key Vault"
Try
{
    New-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $AzureResourceGroupName -Location $AzureResourceGroupLocation -EnabledForDeployment -EnabledForTemplateDeployment -Tag @{ Set="cc123"; Environment="Dev" } -ErrorAction Stop
}
Catch {
    echo $_.Exception|format-list -force
    exit
}

# Download PowerShell helper modules
if ( -Not (Test-Path Service-Fabric )) {
    echo "Installing Helper Module"
    git clone https://github.com/ChackDan/Service-Fabric.git
    Unblock-File -Path .\Service-Fabric\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1
    Import-Module .\Service-Fabric\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1
}

if ( -Not ( Test-Path $OutputPath )) {
    mkdir $OutputPath
}

echo "Creating certificate and uploading it to Key Vault"
Try
{
    # Create self signed certificate, upload to key vault and store in output folder
    # Write output to file so not to lose key vault information
    Invoke-AddCertToKeyVault -SubscriptionId $AzureSubscriptionId `
                            -ResourceGroupName $AzureResourceGroupName `
                            -Location $AzureResourceGroupLocation `
                            -VaultName $KeyVaultName `
                            -CertificateName $CertName `
                            -Password $Password `
                            -CreateSelfSignedCertificate `
                            -DnsName $CertDnsName `
                            -OutputPath $OutputPath 2>&1 | Out-File key-vault.txt -Append
}
Catch {
    echo $_.Exception|format-list -force
    exit
}

echo "Successfully completed script"

