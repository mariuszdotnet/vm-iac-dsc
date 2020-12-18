#CONNECT ACCOUNT IF NEEDED (Manually)

Connect-AzAccount
Get-AzContext
Set-AzContext -SubscriptionId "TBD"

# Configure these first three variables

# Resource group within which to create the VMs

$rgName = "iac-vm-rg"
New-AzResourceGroup -Name $rgName -Location "Canada Central" -Force

# List of VMs to create
$vmNameList = @("vm05-vm")

# Create Password & Credential
$securePassword = ConvertTo-SecureString "TBD" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ("infinity", $securePassword);

# This should be a good set of default tags for new resources; other scripts exist to set AutoStartStop policy in bulk
$vmTags = @{AutoStartStop='{"stopTime": "6pm"}'; BusinessUnit="TBD"; DataClassification="DevTest"; Environment="DevTest"; Owner="user@email.com"}

# Required Constants
$locationName   = "Canada Central"
$vmDefaultSize  = "Standard_A2_v2"

$vNetRgName     = "vm-rg"
$vNetName       = "vm-rg-vnet"
$subNetName     = "default"
#$nsgName        = "TBD"
$vnet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $vNetRgName
$subnetId = (Get-AzVirtualNetworkSubnetConfig -Name $subNetName  -VirtualNetwork $vnet).Id


# Create each VM
Foreach($vmName in $vmNameList)
{
    Write-Output "Creating $vmName"
    $nicName = "$vmName.nic.001"
    $nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $rgName -Location $locationName -SubnetId $subnetId
    $vm = New-AzVMConfig -VMName $vmName -VMSize $vmDefaultSize
    $vm = Set-AzVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $credential -ProvisionVMAgent -PatchMode Manual -TimeZone "Eastern Standard Time"
    #$vm = Set-AzVMBootDiagnostic -VM $vm -Enable -ResourceGroupName "TBD" -StorageAccountName "TBD"
    $vm = Add-AzVMNetworkInterface -VM $vm -Id $nic.Id
    $vm = Set-AzVMSourceImage -VM $vm -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2012-R2-Datacenter' -Version latest

    New-AzVM -ResourceGroupName $rgName -Location $locationName -VM $vm -Tag $vmTags -AsJob

    Set-AzVMDscExtension -Version "2.77" `
        -ArchiveResourceGroupName "storage-account-rg" `
        -ResourceGroupName $rgName `
        -VMName $vmName `
        -ArchiveStorageAccountName "mariuszstorageaccount" `
        -ArchiveBlobName 'iis-install.ps1.zip' `
        -AutoUpdate -ConfigurationName 'IISInstall'
}


Get-Job -State Running

#Get-Job | Wait-Job
"All jobs completed"