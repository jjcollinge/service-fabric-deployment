# Azure Key Vault
Create a new Azure Key Vault and upload a self signed certificate to it
```
./key-vault.ps1 -AzureSubscriptionId '<your-subscriptionId>' -AzureResourceGroupName '<resourcegroupname>' -AzureResourceGroupLocation '<resourcegrouplocation>' -KeyVaultName '<keyvaultname>' -CertDnsName '<certdnsname>' -Password '<certpassword>'
```

Once the script has completed, you need to grab the output values from the `key-vault.txt` file:

`sourceVaultvalue` \
`certificateThumbprint` \
`certificateUrlvalue`

##### Credit
https://github.com/ChackDan/Service-Fabric