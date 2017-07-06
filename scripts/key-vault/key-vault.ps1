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

PromptAzureLoginIfNeeded

ResourceGroupCreateIfNotExist -ResourceGroupName $AzureResourceGroupName -ResourceGroupLocation $AzureResourceGroupLocation

# Create Azure Key Vault
echo "Creating Azure Key Vault"
Try
{
    New-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $AzureResourceGroupName -Location $AzureResourceGroupLocation -EnabledForDeployment -EnabledForTemplateDeployment -Tag @{ Set="cc123"; Environment="Dev" } -ErrorAction Stop
}
Catch {
    Write-Error $_.Exception | format-list -force
    exit
}

# Download PowerShell helper modules
if ( -Not (Test-Path Service-Fabric )) {
    Write-Host "Installing Tools"
    git clone https://github.com/ChackDan/Service-Fabric.git -ErrorAction Stop
    Unblock-File -Path .\Service-Fabric\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1 -ErrorAction Stop
    Import-Module .\Service-Fabric\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1 -ErrorAction Stop
}

if ( -Not ( Test-Path $OutputPath )) {
    Write-Host "Creating certificate output directory"
    md -Force $OutputPath
}

Write-Host "Creating certificate and uploading it to Key Vault"
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
                            -OutputPath $OutputPath 2>&1 | Out-File key-vault.txt
}
Catch {
    Write-Error $_.Exception|format-list -force
    exit
}
Write-Host "Successfully completed script"

