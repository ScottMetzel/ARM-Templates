[CmdletBinding()]
param (
    [parameter(
        Mandatory = $true
    )]
    [ValidateNotNullOrEmpty()]
    [System.String]$LocalVirtualNetworkResourceID,
    [parameter(
        Mandatory = $true
    )]
    [ValidateNotNullOrEmpty()]
    [System.Collections.Arraylist]$RemoteVirtualNetworkResourceIDs,
    [parameter(
        Mandatory = $false
    )]
    [ValidateSet(
        "Local",
        "Remote",
        "All",
        IgnoreCase = $true
    )]
    [System.String]$Output = "All"
)

$InformationPreference = "Continue"
$ErrorActionPreference = "Stop"

# Get all the regions the account is currently connected to. The display names will be used as part of the peering name.
Write-Information -MessageData "Getting Azure regions."
[System.Collections.Arraylist]$GetAzLocations = @()
Get-AzLocation | ForEach-Object -Process {
    $GetAzLocations.Add($_) | Out-Null
}

# Parse the local Virtual Network RID so context can be determined and VNET, found.
Write-Information -MessageData "Parsing single local Virtual Network."
[System.Collections.ArrayList]$SingleVNETParsed = $LocalVirtualNetworkResourceID.Split("/")
[System.String]$SingleVNETSubscriptionID = $SingleVNETParsed[2]
[System.String]$SingleVNETResourceGroupName = $SingleVNETParsed[4]
[System.String]$SingleVNETName = $SingleVNETParsed[8]

# Get the current context and set it in case it's not correct.
Write-Information -MessageData "Getting current context."
$GetAzContext = Get-AzContext

if ($SingleVNETSubscriptionID -eq $GetAzContext.Subscription.Id) {
    Write-Information -MessageData "Current context equals desired context for local single Virtual Network."
}
else {
    Write-Information -MessageData "Current context does not equal context for local single Virtual Network."
    Get-AzSubscription -SubscriptionId $SingleVNETSubscriptionID | Set-AzContext
}

# Get the local VNET and set the formatted location name to be used in the peering name.
Write-Information -MessageData "Getting single local Virtual Network and its location."
$GetSingleAzVNET = Get-AzVirtualNetwork -ResourceGroupName $SingleVNETResourceGroupName -Name $SingleVNETName
[System.String]$SingleAzVNETLocation = $GetSingleAzVNET.Location
[System.String]$SingleAzVNETLocationDisplayName = ($GetAzLocations | Where-Object -FilterScript { $SingleAzVNETLocation -eq $_.Location }).DisplayName
[System.String]$SingleAzVNETLocationDisplayNameFormatted = $SingleAzVNETLocationDisplayName.Replace(" ", "")

# Now work on the remote VNETs, going through the same motions as was done for the local VNET.
Write-Information -MessageData "Working on peer virtual networks."
[System.Int32]$c = 1
[System.Int32]$VNETCount = $RemoteVirtualNetworkResourceIDs.Count
[System.Collections.ArrayList]$LocalVNETPeeringNames = @()
[System.Collections.ArrayList]$RemoteVNETPeeringNames = @()

foreach ($RID in $RemoteVirtualNetworkResourceIDs) {
    # Parse the Resource ID
    Write-Information -MessageData "Parsing Virtual Network: '$c' of: '$VNETCount' Virtual Networks."
    [System.Collections.ArrayList]$VNETParsed = $RID.Split("/")
    [System.String]$VNETSubscriptionID = $VNETParsed[2]
    [System.String]$VNETResourceGroupName = $VNETParsed[4]
    [System.String]$VNETName = $VNETParsed[8]
    Write-Information -MessageData "Working on Virtual Network: '$VNETName'. '$c' of: '$VNETCount' Virtual Networks."

    # If the local VNET RID equals the current RID, skip altogether (can't create a peering of a VNET to itself)
    if ($LocalVirtualNetworkResourceID -eq $RID) {
        Write-Warning -Message "Found local Virtual Network resource ID in remote Virtual Network resource ID list. Skipping it."
    }
    else {
        # Get the current context and set it accordingly.
        Write-Information -MessageData "Getting current context."
        $GetAzContext2 = Get-AzContext

        if ($VNETSubscriptionID -eq $GetAzContext2.Subscription.Id) {
            Write-Information -MessageData "Current context equals desired context for remote Virtual Network."
        }
        else {
            Write-Information -MessageData "Current context does not equal context for remote Virtual Network."
            Get-AzSubscription -SubscriptionId $VNETSubscriptionID | Set-AzContext
        }

        # Now set the formatted remote VNET location name.
        Write-Information -MessageData "Getting Virtual Network and its location."
        $GetAzVNET = Get-AzVirtualNetwork -ResourceGroupName $VNETResourceGroupName -Name $VNETName
        [System.String]$AzVNETLocation = $GetAzVNET.Location
        [System.String]$AzVNETLocationDisplayName = ($GetAzLocations | Where-Object -FilterScript { $AzVNETLocation -eq $_.Location }).DisplayName
        [System.String]$AzVNETLocationDisplayNameFormatted = $AzVNETLocationDisplayName.Replace(" ", "")

        # Concatenate strings to create the local VNET peering name.
        Write-Information -MessageData "Creating local virtual network peering name."
        [System.String]$LocalVNETPeerName = [System.String]::Concat($SingleVNETName, "_", $SingleAzVNETLocationDisplayNameFormatted, "_to_", $VNETName, "_", $AzVNETLocationDisplayNameFormatted, "_01")

        Write-Information -MessageData "Local Virtual Network peering name is: '$LocalVNETPeerName'."
        $LocalVNETPeeringNames.Add($LocalVNETPeerName) | Out-Null

        # Concatentate strings to create the remote VNET peering name.
        Write-Information -MessageData "Creating remote virtual network peering name."
        [System.String]$RemoteVNETPeerName = [System.String]::Concat($VNETName, "_", $AzVNETLocationDisplayNameFormatted, "_to_", $SingleVNETName, "_", $SingleAzVNETLocationDisplayNameFormatted, "_01")

        Write-Information -MessageData "Remote Virtual Network peering name is: '$RemoteVNETPeerName'."
        $RemoteVNETPeeringNames.Add($RemoteVNETPeerName) | Out-Null
    }

    # If all VNETs have been accounted for, report as much, otherwise move on to the next remote VNET
    if ($c -ge $VNETCount) {
        Write-Information -MessageData "All done."
    }
    else {
        Write-Information -MessageData "Moving on to next virtual network."
    }
    $c++
}

# Now output the results and exit
Write-Information -MessageData "Outputting results."
switch ($Output) {
    "Local" {
        Write-Information -MessageData "Outputting local peering names:"
        $LocalVNETPeeringNames
    }
    "Remote" {
        Write-Information -MessageData "Outputting remote peering names."
        $RemoteVNETPeeringNames
    }
    default {
        Write-Information -MessageData "Outputting local and remote peering names."
        @($LocalVNETPeeringNames, $RemoteVNETPeeringNames)
    }
}