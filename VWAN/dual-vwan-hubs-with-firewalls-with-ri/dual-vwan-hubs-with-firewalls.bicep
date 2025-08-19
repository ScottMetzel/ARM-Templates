param VWANResourceGroupName string = 'Prod-RG-VWAN-01'
param VWANHub1ResourceGroupName string = 'Prod-RG-VWANHub-01'
param VWANHub2ResourceGroupName string = 'Prod-RG-VWANHub-02'
param AzureFirewallPolicyResourceGroupName string = 'Prod-RG-FirewallPolicy-01'
param AzureFirewall1ResourceGroupName string = 'Prod-RG-Firewall-01'
param AzureFirewall2ResourceGroupName string = 'Prod-RG-Firewall-02'
param VWANName string
param VWANLocation string = 'westus2'
param VWANHub1Name string
param VWANHub1Location string = 'westus2'
param VWANHub1InternetTrafficRoutingPolicyEnabled bool = true
param VWANHub1PrivateTrafficRoutingPolicyEnabled bool = true
param VWANHub1AddressPrefix string
param VWANHub1VPNGatewayName string
param VWANHub1ExpressRouteGatewayName string
param VWANHub2Name string
param VWANHub2Location string = 'westus3'
param VWANHub2InternetTrafficRoutingPolicyEnabled bool = true
param VWANHub2PrivateTrafficRoutingPolicyEnabled bool = true
param VWANHub2AddressPrefix string
param VWANHub2VPNGatewayName string
param VWANHub2ExpressRouteGatewayName string
param AzureFirewallPolicyName string
param AzureFirewallPolicyLocation string = 'westus2'
param AzureFirewall1Name string
param AzureFirewall2Name string

// Set Target Scope to Subscription
targetScope = 'subscription'

// Create VWAN Resource Group
resource VWANRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  location: VWANLocation
  name: VWANResourceGroupName
  properties: {}
}

// Create VWAN Hub 1 Resource Group
resource VWANHub1RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  location: VWANHub1Location
  name: VWANHub1ResourceGroupName
  properties: {}
}

// Create VWAN Hub 2 Resource Group
resource VWANHub2RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  location: VWANHub2Location
  name: VWANHub2ResourceGroupName
  properties: {}
}

// Create Azure Firewall Policy Resource Group
resource AzureFirewallPolicyRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  location: AzureFirewallPolicyLocation
  name: AzureFirewallPolicyResourceGroupName
  properties: {}
}

// Create Azure Firewall 1 Resource Group
resource AzureFirewall1RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  location: VWANHub1Location
  name: AzureFirewall1ResourceGroupName
  properties: {}
}

// Create Azure Firewall 2 Resource Group
resource AzureFirewall2RG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  location: VWANHub2Location
  name: AzureFirewall2ResourceGroupName
  properties: {}
}

// Create VWAN
module vwanModule 'dual-vwan-hubs-with-firewalls_vwan.bicep' = {
  name: 'deployVWAN'
  scope: resourceGroup(VWANResourceGroupName)
  dependsOn: [
    VWANRG
  ]
  params: {
    VWANName: VWANName
    VWANLocation: VWANLocation
  }
}

// Create VWAN Hub 1
module vwanHub1Module 'dual-vwan-hubs-with-firewalls_vwanHub.bicep' = {
  name: 'deployVWANHub1'
  scope: resourceGroup(VWANHub1ResourceGroupName)
  dependsOn: [
    VWANHub1RG
  ]
  params: {
    VWANRID: vwanModule.outputs.vwanId
    VWANHubLocation: VWANHub1Location
    VWANHubName: VWANHub1Name
    VWANHubAddressPrefix: VWANHub1AddressPrefix
    VWANHubVPNGatewayName: VWANHub1VPNGatewayName
    VWANHubExpressRouteGatewayName: VWANHub1ExpressRouteGatewayName
  }
}

// Create VWAN Hub 2
module vwanHub2Module 'dual-vwan-hubs-with-firewalls_vwanHub.bicep' = {
  name: 'deployVWANHub2'
  scope: resourceGroup(VWANHub2ResourceGroupName)
  dependsOn: [
    VWANHub2RG
  ]
  params: {
    VWANRID: vwanModule.outputs.vwanId
    VWANHubLocation: VWANHub2Location
    VWANHubName: VWANHub2Name
    VWANHubAddressPrefix: VWANHub2AddressPrefix
    VWANHubVPNGatewayName: VWANHub2VPNGatewayName
    VWANHubExpressRouteGatewayName: VWANHub2ExpressRouteGatewayName
  }
}

// Create Azure Firewall Policy
module azureFirewallPolicyModule 'dual-vwan-hubs-with-firewalls_firewall-policy.bicep' = {
  name: 'deployAzureFirewallPolicy'
  scope: resourceGroup(AzureFirewallPolicyResourceGroupName)
  dependsOn: [
    AzureFirewallPolicyRG
  ]
  params: {
    AzureFirewallPolicyName: AzureFirewallPolicyName
    AzureFirewallPolicyLocation: AzureFirewallPolicyLocation
  }
}

// Create Azure Firewall 1
module azureFirewall1Module 'dual-vwan-hubs-with-firewalls_firewall.bicep' = {
  name: 'deployAzureFirewall1'
  scope: resourceGroup(AzureFirewall1ResourceGroupName)
  dependsOn: [
    AzureFirewall1RG
  ]
  params: {
    AzureFirewallName: AzureFirewall1Name
    AzureFirewallLocation: VWANHub1Location
    AzureFirewallPolicyId: azureFirewallPolicyModule.outputs.AzureFirewallPolicyId
    VWANHubId: vwanHub1Module.outputs.vwanHubId
  }
}

// Create Azure Firewall 2
module azureFirewall2Module 'dual-vwan-hubs-with-firewalls_firewall.bicep' = {
  name: 'deployAzureFirewall2'
  scope: resourceGroup(AzureFirewall2ResourceGroupName)
  dependsOn: [
    AzureFirewall2RG
  ]
  params: {
    AzureFirewallName: AzureFirewall2Name
    AzureFirewallLocation: VWANHub2Location
    AzureFirewallPolicyId: azureFirewallPolicyModule.outputs.AzureFirewallPolicyId
    VWANHubId: vwanHub2Module.outputs.vwanHubId
  }
}

// Create Routing Intent Policy on VWAN Hub 1
module routingIntentPolicy1Module 'dual-vwan-hubs-with-firewalls_routing-intent.bicep' = {
  name: 'deployRoutingIntentPolicy1'
  scope: resourceGroup(VWANHub1ResourceGroupName)
  params: {
    VWANHubName: vwanHub1Module.outputs.vwanHubName
    VWANHubId: vwanHub1Module.outputs.vwanHubId
    AzureFirewallName: AzureFirewall1Name
    AzureFirewallId: azureFirewall1Module.outputs.AzureFirewallId
    internetTrafficRoutingPolicy: VWANHub1InternetTrafficRoutingPolicyEnabled
    privateTrafficRoutingPolicy: VWANHub1PrivateTrafficRoutingPolicyEnabled
  }
}

// Create Routing Intent Policy on VWAN Hub 2
module routingIntentPolicy2Module 'dual-vwan-hubs-with-firewalls_routing-intent.bicep' = {
  name: 'deployRoutingIntentPolicy2'
  scope: resourceGroup(VWANHub2ResourceGroupName)
  params: {
    VWANHubName: vwanHub2Module.outputs.vwanHubName
    VWANHubId: vwanHub2Module.outputs.vwanHubId
    AzureFirewallName: AzureFirewall2Name
    AzureFirewallId: azureFirewall2Module.outputs.AzureFirewallId
    internetTrafficRoutingPolicy: VWANHub2InternetTrafficRoutingPolicyEnabled
    privateTrafficRoutingPolicy: VWANHub2PrivateTrafficRoutingPolicyEnabled
  }
}
