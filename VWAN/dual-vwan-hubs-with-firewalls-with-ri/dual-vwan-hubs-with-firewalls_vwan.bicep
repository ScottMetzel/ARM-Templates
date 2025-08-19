param VWANName string = 'Prod-VWAN-Core-01'
param VWANLocation string = 'westus2'

resource VWAN 'Microsoft.Network/virtualWans@2024-07-01' = {
  name: VWANName
  location: VWANLocation
  properties: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    type: 'Standard'
  }
}

output vwanId string = VWAN.id
