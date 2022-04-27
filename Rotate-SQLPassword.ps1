### In order to use your application service with the KeyVault, a few things need to happen first. 
### Run the Setup-AppServiceForKeyVault.ps1 script to automate the steps. 
### Running this script will break your App Service if it's not configured correctly

$resourceGroupName = "woac-demo"
$keyVaultName = "dsfgkldsfiugwer"
$keyVaultSecretName = "MyConnectionString"
$sqlServerName = "asdfcvbwert"
$webAppName = "woacdemo2"
function Get-RandomCharacter () {
    $validCharacters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#%^&*()"
    return $validCharacters[(Get-Random -Minimum 0 -Maximum $validCharacters.Length)]
    
}
function Generate-RandomPassword($length) {
    $randomPassword = ""
    for ($i = 0; $i -lt $length; $i++)
    { 
        $randomPassword += Get-RandomCharacter
    }
    return ($randomPassword | ConvertTo-SecureString -AsPlainText -Force)
}

Write-Host "Getting the key vault" -ForegroundColor Green
$keyVault = Get-AzKeyVault -Name $keyVaultName -ResourceGroupName $resourceGroupName
#$secret = $keyVault | Get-AzKeyVaultSecret -SecretName SQLServerPassword

Write-Host "Generating a new password" -ForegroundColor Green
$newPassword = Generate-RandomPassword -length 15

Write-Host "Adding the password to the key vault for future reference" -ForegroundColor Green
Set-AzKeyVaultSecret -VaultName $keyVault.VaultName -SecretName SQLServerPassword -SecretValue $newPassword | Out-Null

Write-Host "Replacing the admin password on the SQL Server" -ForegroundColor Green
Set-AzSqlServer -ServerName $sqlServerName -ResourceGroupName $resourceGroupName -SqlAdministratorPassword $newPassword | Out-Null

Write-Host "Getting the existing connection string from the Azure Key Vault" -ForegroundColor Green
$connectionString = $keyVault | Get-AzKeyVaultSecret -SecretName $keyVaultSecretName
$connectionStringPlainText = $connectionString.SecretValue | ConvertFrom-SecureString -AsPlainText
$connectionStringRaw = $connectionStringPlainText.Split(";")
$connectionStringRaw[4] = ("Password={0}" -f ($newPassword | ConvertFrom-SecureString -AsPlainText))
$newConnectionString = $connectionStringRaw -join ";" | ConvertTo-SecureString -AsPlainText -Force

Set-AzKeyVaultSecret -VaultName $keyVault.VaultName -SecretName $keyVaultSecretName -SecretValue $newConnectionString | Out-Null

#restart the app service
Restart-AzWebApp -ResourceGroupName $resourceGroupName -Name $webAppName | Out-Null