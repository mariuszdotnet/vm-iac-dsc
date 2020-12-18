# Login to Azure and select context.
Connect-AzAccount
Get-AzContext
Set-AzContext -SubscriptionId "TBD"

# Build the bicep vm file
bicep build .\modules\vm.bicep

$rgName = "iac-vm-rg"
New-AzResourceGroup -Name $rgName -Location "Canada Central"

New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile