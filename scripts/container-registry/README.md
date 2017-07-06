# Azure Container Registry
Deploy an Azure Container Registry instance to store private container images.

Modify the values in the template parameters file `templates\container-registry\azuredeploy.parameters.json` before running the below command.

```
./container-registry.ps1 -AzureSubscriptionId '<your-subscriptionId>' -AzureResourceGroupName '<resourcegroupname>'
```

