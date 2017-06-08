param (
    [string]
    $certStoreLocation = "cert:\currentuser\my",
    [Parameter(Mandatory=$true)]
    [string]$dnsname,
    [Parameter(Mandatory=$true)]
    [string]$password,
    [Parameter(Mandatory=$true)]
    [string]$pfxOutputFolder
 )

$thumbprint = (New-SelfSignedCertificate -certstorelocation cert:\currentuser\my -dnsname ccmsfthackldn) | Out-String
$pwd = ConvertTo-SecureString -String $password -Force -AsPlainText
Export-PfxCertificate -cert ($certStoreLocation + "\" + $thumbprint) -FilePath $pfxOutputFolder -Password $pwd

Write-Host ("Certificate location: " + $certStoreLocation)
Write-Host ("Certificate thumbprint " + $thumbprint)
Write-Host ("Pfx output: " + $pfxOutputFolder)