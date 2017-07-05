# Azure Active Directory
Register the cluster management endpoint as a new AAD application.

```
.\SetupApplications.ps1 -TenantId '<your-tenantID>' -ClusterName '<your-cluster-name>.<region>.cloudapp.azure.com' -WebApplicationReplyUrl 'https://<your-cluster-name>.<region>.cloudapp.azure.com:19080/Explorer/index.html'
```

Once the script has completed, you need to grab the output values for:

`tenantId` \
`clusterApplication` \
`clientApplication`

Now you need to add your users and groups to your registered application in Azure Active Directory.

##### Credit
https://blogs.msdn.microsoft.com/ncdevguy/2017/01/09/securing-an-azure-service-fabric-cluster-with-azure-active-directory-via-the-azure-portal-2/