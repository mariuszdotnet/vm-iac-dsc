#CONNECT ACCOUNT IF NEEDED (Manually)

# Connect-AzAccount
# Get-AzContext
# Set-AzContext -SubscriptionId "TBD"

$resourceGroup = 'storage-account-rg'
$storageAccount = 'mariuszstorageaccount'
#$vmName = 'myVM'

#Publish the configuration script to user storage
#https://docs.microsoft.com/en-us/powershell/module/az.compute/publish-azvmdscconfiguration?view=azps-5.2.0
Publish-AzVMDscConfiguration -ConfigurationPath .\dsc\iis-install.ps1 -ResourceGroupName $resourceGroup -StorageAccountName $storageAccount -force

#Set the VM to run the DSC configuration
#https://docs.microsoft.com/en-us/powershell/module/az.compute/set-azvmdscextension?view=azps-5.2.0
Set-AzVMDscExtension -Version "2.77" `
  -ArchiveResourceGroupName $resourceGroup `
  -ResourceGroupName "iac-vm-rg" `
  -VMName "vm02-vm" `
  -ArchiveStorageAccountName $storageAccount `
  -ArchiveBlobName 'iis-install.ps1.zip' `
  -AutoUpdate -ConfigurationName 'IISInstall'

  #Octopus DSC Module
  #https://octopus.com/docs/infrastructure/deployment-targets/windows-targets/azure-virtual-machines/via-an-arm-template-with-dsc

  #Good Example - https://marckean.com/2018/06/28/azure-automation-dsc-config-example/

  #Work Locally with DSC
  Get-DscResource
  Get-DscLocalConfigurationManager

  Start-DscConfiguration -Path ScriptTest -Wait -Verbose -force
  Get-DscConfiguration -CimSession localhost
  Test-DscConfiguration -CimSession localhost