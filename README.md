## Service Fabric Deployment
This repo contains some templates and script to deploy a specific Service Fabric topology to Azure.

The cluster that will be deployed will have the following components:
* 3 distinct cluster node types with dedicated
    * Azure Load Balancers
    * Subnets
    * Network Security Groups
    * Placement properties for isolated application deployments
* Active directory authentication
* Azure Key Vault certificate(s)
* API Management front end
* DNS Service
* Reverse Proxy
* Windows Container Support
* Managed disks
* Operational Management Suite monitoring
* Appliation Insights monitoring

In order to deploy this cluster, you must visit the sub README files **in the following order**.

1. [Azure Key Vault](scripts/key-vault/README.md)
2. [Azure Active Directory](scripts/active-directory/README.md)
3. [Azure Service Fabric](scripts/service-fabric/README.md)
4. [Azure API Management](scripts/api-management/README.md)
