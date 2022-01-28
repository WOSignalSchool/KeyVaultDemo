$resourceGroup = Read-Host -Prompt "Enter the name of your resource group"
New-AzResourceGroupDeployment -TemplateFile template.json  -templateParameterFile .template.parameters.json  -ResourceGroupName $resourceGrouop
Write-Host "Press [ENTER] to continue ..."