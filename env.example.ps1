# API Management Config
$azureSubscriptionId=""
$azureResourceGroupName=""
$azureResourceGroupLocation=""
$apimName=""
$organization=""
$adminEmail=""
$sku="Standard"
$vpnType="External"
$virtualNetwork=""

# Key Vault Config
$azureSubscriptionId=""
$azureResourceGroupName=""
$azureResourceGroupLocation="westeurope"
$keyVaultName=""
$certName=""
$certDnsName=""
$password=""
$outputPath="$pwd/certs"

# Active Directory Config
$tenantId=""
$clusterName='<your-cluster-name>.<region>.cloudapp.azure.com'
$webApplicationReplyUrl='https://<your-cluster-name>.<region>.cloudapp.azure.com:19080/Explorer/index.html'

# Service Fabric Config
$azureSubscriptionId=""
$azureResourceGroupName=""
$azureResourceGroupLocation="westeurope"
$templateFile="../../templates/service-fabric/azuredeploy.json"
$templateParametersFile="../../templates/service-fabric/azuredeploy.parameters.json"