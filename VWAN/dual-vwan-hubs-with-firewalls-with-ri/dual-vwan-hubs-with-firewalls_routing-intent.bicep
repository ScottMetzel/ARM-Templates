param VWANHubName string
param VWANHubId string
param AzureFirewallName string
param AzureFirewallId string
param internetTrafficRoutingPolicy bool = true
param privateTrafficRoutingPolicy bool = true
// NOTE: vWAN Routing Intent and Policy requires either InternetTrafficRoutingPolicy or PrivateTrafficRoutingPolicy to be true, otherwise feature will be disabled.

resource VWANHub 'Microsoft.Network/virtualHubs@2024-07-01' existing = {
  name: VWANHubName
}

resource HubFirewall 'Microsoft.Network/azureFirewalls@2023-04-01' existing = {
  name: AzureFirewallName
}

resource RoutingIntent 'Microsoft.Network/virtualHubs/routingIntent@2024-07-01' = {
  parent: VWANHub
  name: '${VWANHubName}-RoutingIntent'
  properties: {
    routingPolicies: (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == true)
      ? [
          {
            name: 'PublicTraffic'
            destinations: [
              'Internet'
            ]
            nextHop: HubFirewall.id
          }
          {
            name: 'PrivateTraffic'
            destinations: [
              'PrivateTraffic'
            ]
            nextHop: HubFirewall.id
          }
        ]
      : (internetTrafficRoutingPolicy == true && privateTrafficRoutingPolicy == false)
          ? [
              {
                name: 'PublicTraffic'
                destinations: [
                  'Internet'
                ]
                nextHop: HubFirewall.id
              }
            ]
          : [
              {
                name: 'PrivateTraffic'
                destinations: [
                  'PrivateTraffic'
                ]
                nextHop: HubFirewall.id
              }
            ]
  }
}

output routingIntentId string = RoutingIntent.id
output routingIntentName string = RoutingIntent.name
