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
  [string]
  $Password
)

Function Reset() {
    # Undo any actions taking during the script
    echo "Resetting"
    Remove-Item -Recurse -Force Service-Fabric
    Remove-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $AzureResourceGroupName -Location $AzureResourceGroupLocation -Force
    $certificateObject = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $certificateObject.Import("$outputPath\$certPath", $Password, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::DefaultKeySet)
    $thumbprint=$certificateObject.Thumbprint
    Get-ChildItem "Cert:\CurrentUser\My\$thumbprint" | Remove-Item
    Remove-Item "$outputPath/$CertName.pfx"
    # Do not delete resource group or cert folder as they may have existed prior to running this script
}

Function CleanUp() {
    # Remove temporary files which are not needed after a successful run
    echo "Cleaning up"
    Remove-Item -Recurse -Force Service-Fabric
}


# Login to Azure PowerShell CLI and set context
Try
{  
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId -ErrorAction Stop
}
Catch {
    Login-AzureRmAccount
    Select-AzureRmSubscription -SubscriptionId $AzureSubscriptionId
}

# # Create resource group if it doesn't already exist
# Get-AzureRmResourceGroup -Name $AzureResourceGroupName -ev notPresent -ea 0
# if ($notPresent)
# {
#     # Create Persistent Resource Group
#     New-AzureRmResourceGroup -Name $AzureResourceGroupName -Location AzureResourceGroupLocation
# }

# Create Azure Key Vault
echo "Creating Azure Key Vault"
Try
{
    New-AzureRmKeyVault -VaultName $KeyVaultName -ResourceGroupName $AzureResourceGroupName -Location $AzureResourceGroupLocation -EnabledForDeployment -EnabledForTemplateDeployment -Tag @{ Set="cc123"; Environment="Dev" } -ErrorAction Stop
}
Catch {
    Write-Error "Error: $_.Exception.Message"
    exit
}

# Download PowerShell helper modules
if (Test-Path Service-Fabric) {
    Remove-Item -Recurse -Force Service-Fabric
}
echo "Installing helper modules"
git clone https://github.com/ChackDan/Service-Fabric.git
Unblock-File -Path .\Service-Fabric\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1
Import-Module .\Service-Fabric\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1

if ( -Not (Test-Path $outputPath )) {
    mkdir $outputPath
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
                            -OutputPath $outputPath 2>&1 | Out-File C:\keyvault.txt -Append
}
Catch {
    echo $_.Exception|format-list -force
    Reset
    exit
}

CleanUp
echo "Successfully completed script"

