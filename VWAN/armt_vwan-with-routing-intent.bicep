param VWANName string = 'Lab-VWAN-Core-01'

@allowed(
  [
    'westus2'
    'westus3'
    'westus'
    'westcentralus'
    'southcentralus'
    'northcentralus'
    'eastus'
    'eastus2'
    'centralus'
  ]
)
param VWANRegion string = 'westus2'
param VWANHubName string = 'Lab-VHUB-Core-01'

@allowed(
  [
    'westus2'
    'westus3'
    'westus'
    'westcentralus'
    'southcentralus'
    'northcentralus'
    'eastus'
    'eastus2'
    'centralus'
  ]
)
param VWANHubRegion string = 'westus2'
param VWANHubAddressSpace string = '10.100.0.0/23'
param AzureFirewallName string = 'Lab-AZFW-Core-01'
param AzureFirewallPolicyName string = 'Lab-AZFWP-Core-01'

resource VWAN 'Microsoft.Network/virtualWans@2023-04-01' = {
  name: VWANName
  location: VWANRegion
  properties: {
    allowBranchToBranchTraffic: true
    allowVnetToVnetTraffic: true
    disableVpnEncryption: false
    type: 'Standard'
  }
}

resource VWANHub 'Microsoft.Network/virtualHubs@2023-04-01' = {
  name: VWANHubName
  location: VWANHubRegion
  properties: {
    addressPrefix: VWANHubAddressSpace
    allowBranchToBranchTraffic: true
    hubRoutingPreference: 'ASPath'
    preferredRoutingGateway: 'ExpressRoute'
    virtualRouterAutoScaleConfiguration: {
      minCapacity: 2
    }
    virtualWan: {
      id: VWAN.id
    }
  }
}

resource VWANHubName_noneRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2023-04-01' = {
  parent: VWANHub
  name: 'noneRouteTable'
  properties: {
    routes: []
    labels: [ 'none' ]
  }
}

resource AzureFirewallPolicy 'Microsoft.Network/firewallPolicies@2023-04-01' = {
  name: AzureFirewallPolicyName
  location: VWANHubRegion
  properties: {
    sku: {
      tier: 'Premium'
    }
    threatIntelMode: 'Alert'
  }
}

resource AzureFirewall 'Microsoft.Network/azureFirewalls@2023-04-01' = {
  name: AzureFirewallName
  location: VWANHubRegion
  properties: {
    firewallPolicy: {
      id: AzureFirewallPolicy.id
    }
    hubIPAddresses: {
      publicIPs: {
        count: 1
      }
    }
    sku: {
      name: 'AZFW_Hub'
      tier: 'Premium'
    }
    virtualHub: {
      id: VWANHub.id
    }
  }
}

resource VWANHubName_hubRoutingIntent 'Microsoft.Network/virtualHubs/routingIntent@2023-04-01' = {
  parent: VWANHub
  name: 'hubRoutingIntent'
  properties: {
    routingPolicies: [
      {
        name: 'Internet'
        destinations: [ 'Internet' ]
        nextHop: AzureFirewall.id
      }
      {
        name: 'PrivateTraffic'
        destinations: [ 'PrivateTraffic' ]
        nextHop: AzureFirewall.id
      }
    ]
  }
}

resource VWANHubName_defaultRouteTable 'Microsoft.Network/virtualHubs/hubRouteTables@2023-11-01' = {
  parent: VWANHub
  name: 'defaultRouteTable'
  properties: {
    routes: [
      {
        name: 'private_traffic'
        destinationType: 'CIDR'
        destinations: [ '20.30.40.0/24' ]
        nextHopType: 'ResourceId'
        nextHop: AzureFirewall.id
      }
    ]
    labels: [ 'default' ]
  }
  dependsOn: [ VWANHubName_hubRoutingIntent ]
}
