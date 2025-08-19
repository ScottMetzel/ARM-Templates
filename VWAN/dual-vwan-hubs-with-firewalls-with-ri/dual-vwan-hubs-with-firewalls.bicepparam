using './dual-vwan-hubs-with-firewalls.bicep'

param VWANResourceGroupName = 'Prod-RG-VWAN-01'
param VWANHub1ResourceGroupName = 'Prod-RG-VWANHub-01'
param VWANHub2ResourceGroupName = 'Prod-RG-VWANHub-02'
param AzureFirewallPolicyResourceGroupName = 'Prod-RG-FirewallPolicy-01'
param AzureFirewall1ResourceGroupName = 'Prod-RG-Firewall-01'
param AzureFirewall2ResourceGroupName = 'Prod-RG-Firewall-02'
param VWANName = 'Prod-VWAN-Core-01'
param VWANLocation = 'westus2'
param VWANHub1Name = 'Prod-Hub-Core-01'
param VWANHub1Location = 'westus2'
param VWANHub1InternetTrafficRoutingPolicyEnabled = true
param VWANHub1PrivateTrafficRoutingPolicyEnabled = true
param VWANHub1AddressPrefix = '10.100.0.0/23'
param VWANHub1VPNGatewayName = 'Prod-VPNVNG-Core-01'
param VWANHub1ExpressRouteGatewayName = 'Prod-EXRVNG-Core-01'
param VWANHub2Name = 'Prod-Hub-Core-02'
param VWANHub2Location = 'westus3'
param VWANHub2InternetTrafficRoutingPolicyEnabled = true
param VWANHub2PrivateTrafficRoutingPolicyEnabled = true
param VWANHub2AddressPrefix = '10.100.2.0/23'
param VWANHub2VPNGatewayName = 'Prod-VPNVNG-Core-02'
param VWANHub2ExpressRouteGatewayName = 'Prod-EXRVNG-Core-02'
param AzureFirewallPolicyName = 'Prod-AFWP-Core-01'
param AzureFirewallPolicyLocation = 'westus2'
param AzureFirewall1Name = 'Prod-AFW-Core-01'
param AzureFirewall2Name = 'Prod-AFW-Core-02'
