param vmName string
param adminUserName string
param adminPassword string {
  secure: true
}

param sku string {
  default: '2016-Datacenter'
  allowed: [
    '2008-R2-SP1'
    '2012-Datacenter'
    '2012-R2-Datacenter'
    '2016-Nano-Server'
    '2016-Datacenter-with-Containers'
    '2016-Datacenter'
    '2019-Datacenter'
  ]
  metadata: {
    'description': 'The Windows version for the VM. This will pick a fully patched image of this given Windows version.'
  }
}

param vmSize string {
  default: 'Standard_D2_v3'
  metadata: {
    description: 'Size of the virtual machine.'
  }
}

param location string {
  default: resourceGroup().location
  metadata: {
    description: 'location for all resources'
  }
}

param subnetId string

param privateIPAllocationMethod string {
  default: 'Dynamic'
  allowed:[
    'Static'
    'Dynamic'
  ]
}

resource Nic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'nic1'
  location: location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource VM 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: sku
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: Nic.id
        }
      ]
    }
  }
}