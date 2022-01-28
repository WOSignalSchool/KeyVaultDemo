$resourceGroup = Read-Host -Prompt "Enter the name of your resource group"
$keyVaultName = Read-Host -Prompt "Enter the name of your Azure KeyVault"

$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroup

if ($null -eq $keyVault) {
    Write-Host "Unable to find the Key Vault. Please enter a valid ResourceGroup and KeyVault Name"
}

$deploymentName = ("deployment-{0}.json" -f (Get-Random))
$parameterFile = Get-Content .\template.parameters.json | ConvertFrom-Json -AsHashtable

$parameterFile.parameters.adminPassword.reference.keyVault.id = $keyVault.ResourceId
$parameterFile.parameters.adminUsername.reference.keyVault.id = $keyVault.ResourceId

ConvertTo-Json $parameterFile -Depth 10 | Out-File $deploymentName

New-AzResourceGroupDeployment -TemplateFile template.json -TemplateParameterFile $deploymentName -ResourceGroupName $resourceGroup
Write-Host "Press [ENTER] to continue ..."
Read-Host