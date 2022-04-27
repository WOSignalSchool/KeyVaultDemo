$resourceGroupName = "woac-demo"
$keyVaultName = "dsfgkldsfiugwer"
$keyVaultSecretName = "MyConnectionString"
$webAppName = "woacdemo2"

#Create an app connection string configuration that will be added to the web app (https://docs.microsoft.com/en-us/azure/app-service/app-service-key-vault-references)
$connectionString = @{
  "MyDbConnection" = @{
    value="@Microsoft.KeyVault(VaultName=$keyVaultName;SecretName=$keyVaultSecretName)";
    type="2"
  }               
}

#Create a managed identity for the web app
Write-Host "Creating a managed identity for the web app" -ForegroundColor Green
Set-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName -AssignIdentity $true | Out-Null

#Get the web app configuration
$webApp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName

#Add the web app to the KeyVault Access Policy
Write-Host "Adding the web app to the KeyVault Access Policy" -ForegroundColor Green
Set-AzKeyVaultAccessPolicy -ObjectId $webApp.Identity.PrincipalId -VaultName $keyVaultName -PermissionsToSecrets get | Out-Null

#Add the configuration setting
Write-Host "Adding the Azure Key Vault configuration settings to the web app" -ForegroundColor Green
Set-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName -ConnectionStrings $connectionString

#Restart the Web Application
Write-Host "Restarting the web app" -ForegroundColor Green
Restart-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName | Out-Null