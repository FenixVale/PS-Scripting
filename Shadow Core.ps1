Clear-Host
function Show-Menu
{
    param (
        [string]$Title = 'CQI Shadow Utility'
          )
          Write-Host "==================== $Title ===================="
          Write-Host "=                                                          ="
          Write-Host "=                   1) List Sessions                       ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=                2) Connect To A Session                   ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=               3) How To Use This Utility                 ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=                   4) EXIT UTILITY                        ="
          Write-Host "=                                                          ="
          Write-Host "============================================================"
}
do
{
    Show-Menu -Title 'CQI Shadow Utility'

    $selection = Read-Host "Please select an option from the list"
    switch ($selection)
        {
        '1'
            {
            'Generating Session List....'

            Get-RDUserSession -ConnectionBroker "xRDWeb.wedgepc.com" | Sort-Object Username | ogv | ft Username, UnifiedSessionId, HostServer, SessionState
            Write-Host
            Write-Host
            Clear-Host
            }
        '2'
            {
            'You chose to Connect to a session.'
            Write-Host

            #Potential non-admin setting
            #wmic /namespace:\\root\CIMV2\TerminalServices PATH Win32_TSPermissionsSetting WHERE (TerminalName="RDP-Tcp") CALL AddAccount "WEDGEPC\RDP Shadow Users",2

            #User Input for ID / Server
            $hostsrvid = Read-Host "Please enter the HostServer the user is on"
            $usrid = Read-Host "Please enter the Session ID of the User"

            #Execute RDP with shadow to deisgnated ID and server, with control and consent prompt
            mstsc /shadow:$usrid /v:$hostsrvid /control
            Write-Host
            Write-Host
            pause
            Clear-Host
            }
        '3'
            {
            Clear-Host
            
            "            This utility is meant to be used by the CQI Team for the purposes of shadowing the sessions of 
            users on the Wedge Medical RDS Servers. These sessions are initiated with full control permissions, 
            and executed only with the approved consent of the user being shadowed.
            
            To use this utility, first select the `List Sessions` option to generate a list of all users currently 
            with an RDS session running. This list will be sorted Alphabetically, and you will need two pieces of 
            information from it.
            
            The first is the UnifiedSessionID of the user you're connecting to, and the second is the HostServer. 
            These two values will be listed beside eachother, and will be required for the connection portion.
            
            Next, select the `Connect to a Session` option. This will first ask you for the server the user is on. 
            For this, enter the HostServer
            that the user is connected to. The next will ask for the user's Session ID. This will be where you enter 
            the Unified Session ID you copied.
            
            For example, of JDoe is connected with the UnifiedSessionId of 26, and is connected on XRD2, you will enter 
            XRD2 for the server, then 26 for the ID
            
            Once you enter the ID, it will execute the process to connect, waiting first for the user to give consent.
            If the connection fails, the user either rejected the consent, or their session ended.
            
            If you have any questions or need help with this utility, please contact support@Computrex.com"
            Write-Host
            Write-Host
            Pause
            Clear-Host
            }
        '4'
            {
             Return
            }
    }
}
until ($selection -eq '4')
