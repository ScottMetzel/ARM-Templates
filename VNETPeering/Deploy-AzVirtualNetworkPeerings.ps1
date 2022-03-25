[System.String]$NowString = Get-Date -Format FileDateTimeUniversal
[System.String]$DeploymentName = [System.String]::Concat("CreateVNETPeerings_", $NowString)
[System.String]$LocalVNETRID = "/subscriptions/8ba4ba22-77b6-4573-b28c-8ccc4b7854eb/resourceGroups/Dev-RG-NetworkInfrastructure-09/providers/Microsoft.Network/virtualNetworks/Dev-VNET-Hub-09"
[System.String]$LocalVNETResourceGroupName = $LocalVNETRID.SPlit("/")[4]
$RemoteVirtualNetworkRIDs = (Get-AzVirtualNetwork | Where-Object -FilterScript { ($_.Name -like "*Hub*") -and ($_.Id -ne $LocalVNETRID) }).Id

[System.Collections.ArrayList]$RemoteVirtualNetworkAllowVNETAccess = @()
[System.Collections.ArrayList]$RemoteVirtualNetworkAllowForwardedTraffic = @()
[System.Collections.ArrayList]$RemoteVirtualNetworkAllowGatewayTransit = @()
[System.Collections.ArrayList]$RemoteVirtualNetworkUseRemoteGateways = @()

$RemoteVirtualNetworkRIDs | ForEach-Object -Process {
    $RemoteVirtualNetworkAllowVNETAccess.Add($true) | Out-Null
    $RemoteVirtualNetworkAllowForwardedTraffic.Add($true) | Out-Null
    $RemoteVirtualNetworkAllowGatewayTransit.Add($true) | Out-Null
    $RemoteVirtualNetworkUseRemoteGateways.Add($false) | Out-Null
}

$PeeringNames = C:\Users\scottmetzel\Repos\GitHub\ScottMetzel\ARM-Templates\VNETPeering\Create-AzVirtualNetworkPeeringStrings.ps1 -LocalVirtualNetworkResourceID $LocalVNETRID -RemoteVirtualNetworkResourceIDs $RemoteVirtualNetworkRIDs

[System.Collections.Hashtable]$ParameterTable = @{
    "LocalVirtualNetworkResourceID"             = $LocalVNETRID;
    "LocalVirtualNetworkPeeringNames"           = $PeeringNames[0];
    "LocalVirtualNetworkAllowVNETAccess"        = $true;
    "LocalVirtualNetworkAllowForwardedTraffic"  = $true;
    "LocalVirtualNetworkAllowGatewayTransit"    = $true;
    "LocalVirtualNetworkUseRemoteGateways"      = $false;
    "RemoteVirtualNetworkPeeringResourceIDs"    = $RemoteVirtualNetworkRIDs;
    "RemoteVirtualNetworkPeeringNames"          = $PeeringNames[1];
    "RemoteVirtualNetworkAllowVNETAccess"       = $RemoteVirtualNetworkAllowVNETAccess;
    "RemoteVirtualNetworkAllowForwardedTraffic" = $RemoteVirtualNetworkAllowForwardedTraffic;
    "RemoteVirtualNetworkAllowGatewayTransit"   = $RemoteVirtualNetworkAllowGatewayTransit;
    "RemoteVirtualNetworkUseRemoteGateways"     = $RemoteVirtualNetworkUseRemoteGateways;
}

New-AzResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $LocalVNETResourceGroupName -Mode "Incremental" -TemplateParameterObject $ParameterTable -TemplateFile "C:\Users\scottmetzel\Repos\GitHub\ScottMetzel\ARM-Templates\VNETPeering\VNETPeerings.json" -Verbose