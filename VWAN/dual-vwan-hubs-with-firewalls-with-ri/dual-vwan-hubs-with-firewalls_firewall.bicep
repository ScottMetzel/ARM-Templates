param AzureFirewallName string
param AzureFirewallLocation string
param AzureFirewallPolicyId string
param VWANHubId string

resource AzureFirewall 'Microsoft.Network/azureFirewalls@2024-07-01' = {
  name: AzureFirewallName
  location: AzureFirewallLocation
  properties: {
    sku: {
      tier: 'Premium'
    }
    virtualHub: {
      id: VWANHubId
    }
    firewallPolicy: {
      id: AzureFirewallPolicyId
    }
  }
}

output AzureFirewallId string = AzureFirewall.id
