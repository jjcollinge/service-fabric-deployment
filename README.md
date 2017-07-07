# Service Fabric with Supporting Services Deployment
This repo contains templates and scripts meant for deploying a Service Fabric cluster along with supporting services.
The templates and scripts will need modifying for your own specific scenario but should give you a good starting point to build on.

## Azure Services

### Azure Service Fabric Cluster
The Service Fabric cluster template has the following properties:
* 3 distinct node types with dedicated
    * Azure Load Balancers
    * Virtual Network Subnets
    * Network Security Groups
    * Placement Properties for targetted app deployments (PCIDSS and non PCIDSS)
* Internal DNS Service
* Windows Container support
* Reverse Proxy
* Managed Disks

### Azure Key Vault
Azure Key Vault is used to store your cluster's security certificate. This currently stores a single self signed certificate. You can extend the template to deploy additional application or reverse proxy certificates.

### Azure Active Directory
By default the Service Fabric management endpoints will be protected by Azure Active Directory authentication.

### Azure API Management
API Management can be used to front your web services hosted on the cluster. You can add throttling, API secrets, header transformations, etc. The API Management instance will be connected to your cluster's virtual network so you can route traffic internally if desired.

### Azure Container Registry
Private docker container images can be stored in the Azure Container Registry. These images can then easily be deployed to the Service Fabric cluster by referencing the image URLs in a `ApplicationManifest.xml`.

### Operational Management Suite
Your cluster will use Windows Azure Diagnostics agents to report ETW events to an Operational Management Suite Workspace. The Azure Service Fabric and Security solutions will be preloaded.

### Application Insights
The Windows Azure Diagnostics agents are also configured to report ETW events to an Application Insights instance. You can use the same Application Insights instance to report your application telemetry to via the SDK or EventFlow.

## Azure Resource Groups
The supporting services are deployed into a different Azure Resource Group as their life cycle may not align with that of the cluster.

**Cluster Resource Group**
* Azure Service Fabric Cluster
* Operational Management Suite Workspace
* Application Insights

**Supporting Service Resource Group**
* Azure Key Vault
* API Management
* Azure Continer Service

Azure Active Directory operates as a Software as a Service model and therefore is not provisioned, however, an Application Registration will be required.

<img src="images/service-fabric.png" />

## Instructions
To deploy these components, you must follow these **instructions, in order**.

1. Copy the example environment file to you local environment file.
    
        cp env.example.ps1 env.ps1

2. Edit the `env.ps1` file and provide a value for each variable
3. Source the environment variable file

        . env.ps1

4. Deploy an Azure Key Vault with self-signed certificate

        .\scripts\key-vault\key-vault.ps1 `
        -AzureSubscriptionId $subId `
        -AzureResourceGroupName $extRgName `
        -AzureResourceGroupLocation $extRgLoc `
        -KeyVaultName $kvName `
        -CertDnsName $clusterName `
        -CertName $certName `
        -Password $certPassword

5. Create an Application Registration in your Azure Active Directory tenant.

        .\scripts\active-directory\SetupApplications.ps1 `
        -TenantId $aadTenantId `
        -ClusterName "$clusterName.$clusterRgLoc.cloudapp.azure.com" `
        -WebApplicationReplyUrl "https://$clusterName.$clusterRgLoc.cloudapp.azure.com:19080/Explorer/index.html"

    Record the output values for the following properties in a file:

        tenantId
        clusterApplication
        clientApplication

6. Visit the [Azure Portal](https://portal.azure.com), go to Azure Active Directory, App Registrations, search using your cluster application and select the Web App. Click on permissions and grant the application access to `Sign-in and read user profiles`.

7. Edit the parameters file: `templates\service-fabric\azuredeploy.parameters.json`. Modify the parameters to match your desired cluster configuration. Azure Key Vault details can be found in the text file `key-vault.txt` and Active Directory details were output in step 5.

8. Deploy the Azure Service Fabric cluster.

        .\scripts\service-fabric\service-fabric.ps1 `
        -AzureSubscriptionId $subId `
        -AzureResourceGroupName $clusterRgName `
        -AzureResourceGroupLocation $clusterRgLoc

    Beware, this may take a little while.

9. Deploy an API Management instance to facade your cluster's APIs

        .\scripts\api-management\api-management.ps1 `
        -AzureSubscriptionId $subId `
        -DeployToResourceGroupName $extRgName `
        -DeployToResourceGroupLocation $extRgLoc `
        -ApimName $apimName `
        -VNetResourceGroupName $clusterRgName `
        -VNetResourceGroupLocation $clusterRgLoc `
        -Organization $apimOrg `
        -AdminEmail $apimAdminEmail

10. If you plan to deploy Windows Containers to your Service Fabric cluster, you'll probably want a private Azure Container Registry. Edit the template parameters file: `templates\continer-registry\azuredeploy.parameters.json`.

11. Deploy the Azure Container Registry.

        .\scripts\container-registry\container-registry.ps1 `
        -AzureSubscriptionId $subId `
        -AzureResourceGroupName $extRgName

12. Once all the deployments have completed **successfully**, you can grab your Service Fabric endpoint from the portal or the `service-fabric.txt` file and visit the Service Fabric Explorer. Your OMS Workspace and Application Insights will be accessible via the Azure Portal.