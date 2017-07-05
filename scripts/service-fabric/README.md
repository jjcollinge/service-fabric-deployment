# Azure Service Fabric
Deploy an Azure Service Fabric cluster to Azure

First, populate the values in the parameters file located under `templates/service-fabric/azuredeploy.parameters.json`. You'll need the output values from both the key vault and active directory deployments.

```
./service-fabric.ps1 -AzureSubscriptionId '<your-subscriptionId>' -AzureResourceGroupName '<resourcegroupname>' -AzureResourceGroupLocation '<resourcegrouplocation>'
```