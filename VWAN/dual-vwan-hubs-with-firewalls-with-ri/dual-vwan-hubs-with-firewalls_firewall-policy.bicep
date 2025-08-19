param AzureFirewallPolicyName string
param AzureFirewallPolicyLocation string

resource AzureFirewallPolicy 'Microsoft.Network/firewallPolicies@2024-07-01' = {
  name: AzureFirewallPolicyName
  location: AzureFirewallPolicyLocation
  properties: {
    threatIntelMode: 'Alert'
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
  }
}

output AzureFirewallPolicyId string = AzureFirewallPolicy.id
output AzureFirewallPolicyName string = AzureFirewallPolicy.name
