Import-Module RemoteDesktop 3>$null
Clear-Host
function Show-Menu
{
    param (
        [string]$Title = 'Shadow Utility'
          )
          Write-Host "==================== $Title ===================="
          Write-Host "=                                                          ="
          Write-Host "=                   1) Run Utility                         ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=               2) How To Use This Utility                 ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=                   3) EXIT UTILITY                        ="
          Write-Host "=                                                          ="
          Write-Host "============================================================"
}
do
{
    Show-Menu -Title 'Shadow Utility'

    $selection = Read-Host "Please select an option from the list"
    switch ($selection)
        {
        '1'
            {
            'Executing....'
            
            $ConnectionBroker = "<# Enter Collection Broker#>"
            $Collection = "<#Enter Collection Name#>"

            $rdshCollections = Get-WmiObject -Class Win32_RDSHCollection -Namespace "root\cimv2\rdms" -ComputerName $ConnectionBroker -Authentication PacketPrivacy -Impersonation Impersonate -ErrorAction Stop

            $WildCard = New-Object System.Management.Automation.WildcardPattern -ArgumentList $Collection, IgnoreCase
            $WildCardMatchesSh = ($rdshCollections | Where-Object { $WildCard.IsMatch($_.Name) })

            $collAliasToNameMap = @{}

            if($null -ne $WildCardMatchesSh)
            {
            foreach($match in $WildCardMatchesSh)
                {
                if(-not $collAliasToNameMap.ContainsKey($match.Alias))
                    {
                    $collAliasToNameMap.Add($match.Alias, $match.Name)
                    }
                }
            }

            $wmiQuery = "SELECT * FROM Win32_SessionDirectorySessionEx"

            $UserSessions = Get-WmiObject -ErrorAction Stop -Query $wmiQuery -ComputerName $ConnectionBroker -Authentication PacketPrivacy -Impersonation Impersonate `
            | Where-Object { $collAliasToNameMap.ContainsKey($_.CollectionAlias) } `
            | ForEach-Object {
                    New-Object Microsoft.RemoteDesktopServices.Management.RDUserSession `
                        -ArgumentList $_.ServerName, $_.SessionId, $_.UserName, $_.DomainName, $_.ServerIPAddress, $_.TSProtocol, `
                        $_.ApplicationType, $_.ResolutionWidth, $_.ResolutionHeight, $_.ColorDepth, $_.CreateTime, $_.DisconnectTime, $_.SessionState, `
                        $collAliasToNameMap[$_.CollectionAlias], $_.CollectionType, $_.UnifiedSessionId, $_.HostServer, $_.IdleTime, $_.RemoteFxEnabled
                         }

            $ActiveSessions = $UserSessions | Where-Object -Property SessionState -EQ "STATE_ACTIVE"
            $GridView = $ActiveSessions | Select-Object -Property CollectionName,UserName,HostServer,SessionID
            $Session = $GridView | Sort-Object Username | Out-GridView -Title "Remote Desktop Shadowing - Active Sessions" -OutputMode Single

            if($Session -eq $null)
            {
            # No session selected, user probably clicked Cancel
            return
            }

            mstsc /v:($Session.HostServer) /shadow:($Session.SessionId) /control | Out-Null
                        
            Write-Host
            Write-Host
            Clear-Host
            }
        '2'
            {
            Clear-Host
            Write-Host
            Write-Host
            
            "            This utility is meant to be used for the purposes of shadowing the sessions of 
            users on RDS Servers. These sessions are initiated with full control permissions, 
            and executed only with the approved consent of the user being shadowed.
            
            To use this utility, simply select option 1 to execute the actual program. This will generate a list of all users
            currently logged into their sessions, as well as the server they are connected to. Find the user you would like to
            connect to in the list, and simply click their name, and click 'OK' at the bottom of the window. This will initiate
            the connection. Once the user approves your connection request, a window will open with the shadow session of their
            desktop."
            Write-Host
            Write-Host
            Pause
            Clear-Host
            }
        '3'
            {
             Return
            }
    }
}
until ($selection -eq '3')
