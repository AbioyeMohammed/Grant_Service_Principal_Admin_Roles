function grant_service_principal_admin_roles
{
    $cloudcred = Get-Credential

    Connect-AzureAD -Credential $cloudcred
    
    Connect-AzAccount -credential $credential

    $AzADAppDisplayName = Read-Host "Enter a name for your Azure AD Application" 

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
