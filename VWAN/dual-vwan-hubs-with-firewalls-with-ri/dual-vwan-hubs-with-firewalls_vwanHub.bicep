param VWANRID string
param VWANHubLocation string
param VWANHubName string
param VWANHubAddressPrefix string
param VWANHubVPNGatewayName string
param VWANHubExpressRouteGatewayName string

resource vwanHub 'Microsoft.Network/virtualHubs@2024-07-01' = {
  name: VWANHubName
  location: VWANHubLocation
  properties: {
    virtualWan: {
      id: VWANRID
    }
    addressPrefix: VWANHubAddressPrefix
  }
}

resource vwanHubVPNGateway 'Microsoft.Network/virtualHubs/vpnGateways@2024-07-01' = {
  name: VWANHubVPNGatewayName
  parent: vwanHub
  properties: {
    scaleUnits: 2
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: []
      }
    }
    virtualHub: {
      id: vwanHub.id
    }
  }
}

resource vwanHubExpressRouteGateway 'Microsoft.Network/virtualHubs/expressRouteGateways@2024-07-01' = {
  name: VWANHubExpressRouteGatewayName
  parent: vwanHub
  properties: {
    scaleUnits: 2
    virtualHub: {
      id: vwanHub.id
    }
  }
}
output vwanHubId string = vwanHub.id
output vwanHubName string = vwanHub.name
output vwanHubVPNGatewayId string = vwanHubVPNGateway.id
output vwanHubExpressRouteGatewayId string = vwanHubExpressRouteGateway.id
