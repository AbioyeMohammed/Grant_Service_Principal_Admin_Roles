function grant_service_principal_admin_roles
{
    $cloudcred = Get-Credential

    Connect-AzureAD -Credential $cloudcred

     $AzADAppDisplayName = "ReproduceOneDriveApp" 

    <#add your application to Company Administrator and user account roles in the Office 365 administrative roles to prevent - “code”: “Authorization_RequestDenied”, . 
    can take up to 30mins
    https://docs.microsoft.com/en-us/troubleshoot/azure/active-directory/authorization-request-denied-graph-api
    #>

    $AzureADApplicationDetails = Get-AzureADApplication -Filter "DisplayName eq '$($AzADAppDisplayName)'"
    
    $ServicePrincipal = new-AzADServicePrincipal -ApplicationId $AzureADApplicationDetails.AppId
    
    $tenantAzADroles = Get-AzureADDirectoryRole
    foreach ($AzADrole in $tenantAzADroles.ObjectId)
    {
        <#  -ObjectId : Specifies the ID of a directory role in Azure Active Directory.
            -RefObjectId:Specifies the ID of the Azure Active Directory object to assign as owner/manager/member.#>
        Add-AzureADDirectoryRoleMember -ObjectId $AzADrole -RefObjectId $ServicePrincipal.Id 
    }

     get-AzureADDirectoryRoleMember -ObjectId $AzADrole | Select-Object ObjectId,DisplayName  

}


    Connect-MsolService -Credential $cloudcred

    
    #Gets service principals from Azure Active Directory.
    $objectId = (Get-MsolServicePrincipal | where{$_.DisplayName -match $appdisplayName}).ObjectId
    $objectId
    
    $roleName = "User Account Administrator" 
    Add-MsolRoleMember -RoleName $roleName -RoleMemberType ServicePrincipal -RoleMemberObjectId $objectId
    
    $roleName = "Company Administrator" 
    Add-MsolRoleMember -RoleName $roleName -RoleMemberType ServicePrincipal -RoleMemberObjectId $objectId

    Connect-PnPOnline -ClientId $servicePrincipalConnection.ApplicationId -ClientSecret  $Clientsecret -Url "https://m365x685435-admin.sharepoint.com"

#Get all office 365 users Onedrive sites
$OneDriveSites = Get-PnPTenantSite -IncludeOneDriveSites -Filter "Url -like '-my.sharepoint.com/personal/'"
