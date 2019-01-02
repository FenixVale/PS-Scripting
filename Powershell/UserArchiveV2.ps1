[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$host.ui.RawUI.WindowTitle = "User Archival Tool"
F-ExConnect

<#This script will depend on several files to execute fully. For the import functionality, there needs to exist a comma-delimited file named "userlist.csv" for the
software to import and read, to execute the archive for many users. This script also requires .Net Framework for the GUI functions, and access to an exchange server
although the exchange functionality can be removed. AD Users/Computers is needed for the user searching, and 7zip for the actual archiving.#>

Clear-Host

Function Show-Menu
    {
    param (
        [string]$Title = 'User Archival Tool'
          )
          Write-Host "==================== $Title ==================="
          Write-Host "=                                                          ="
          Write-Host "=                1) Archive Single User                    ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=                2) Archive List of Users                  ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=                3) View Instructions                      ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=                4) EXIT UTILITY                           ="
          Write-Host "=                                                          ="
          Write-Host "============================================================"
    }

Function F-Single
    {
    Write-Verbose -Message "Generating users from Active Directory" -Verbose
    $ADUsers = Get-ADUser -Filter * -SearchBase "CN=Users,DC=WedgePC,DC=COM" | Select-Object -Property Name,SamAccountName,SID | Sort-Object Name | Out-GridView -Title "AD User List"
    $CurrUser = [Microsoft.VisualBasic.Interaction]::InputBox("Please enter the username (SamAccountName) of the user that you would like to archive into the text box.","Single User Archive")
    $Term = Get-Date -UFormat "%Y%m%d"
    F-RunArchive -Title "Archiving..."
    $ShellWindow = New-Object -ComObject wscript.shell
    $PopUp = $ShellWindow.popup("'$CurrUser' has been processed.",0)
    Pause
    Clear-Host
    }

Function F-Import
    {
    Write-Verbose -Message "Importing userlist.csv" -Verbose

    ##Import formatted CSV
    $Userlist = Import-csv -Delimiter "," -Path "\\192.168.30.24\UPDArchives\Userlist.CSV"

    ##Recursively run the command for each user in the document
    foreach ($User in $Userlist)
        {
         ##Set Termination Date
         $Term = $User.TerminationDate

         ##Configure UsrSearch with the username
         $CurrUser = $User.SAM

         ##Output this termination date and the username
         Write-Host
         Write-Host "- - - - -"
         Write-Host $CurrUser

         ##Invoke the Archiving function
         F-RunArchive -Title 'Archiving...'
        }

        Pause
        Clear-Host
    }

Function F-Readme
    {
    \\192.168.30.24\Computrex\Scripts\UsrArchiving\Readme.txt
    Clear-Host
    }

Function F-ExConnect
    {
	$ExLogin = $env:USERDOMAIN + "\" + $env:USERNAME
	$Cred = (Get-Credential -UserName $ExLogin -Message "Enter password")
	$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://xex.wedgepc.com/powershell -AllowRedirection -Credential $Cred
	Import-PSSession $Session
    }

Function F-RunArchive
    {
    
    ##Get user data based on input and parse the First and Last name for formatting, parse SID to its own variable
    Try {$UsrData = Get-ADUser -Identity $CurrUser -ErrorAction Stop}
    Catch 
        {
        Write-Host "- - - - -"
        Write-Host "$UsrData"
        Write-Host "Error: User Not Found"
        Write-Host "- - - - -"
        Continue
        }

    $FirstN = ($UsrData.GivenName).trim()
    $LastN = ($UsrData.Surname).trim()
    $userFolder = "\\192.168.30.24\UPDArchives\" + "$LastN"+", "+"$FirstN"
    $userSID = $UsrData.SID
    $userFile = "$Term" + $LastN + $FirstN


    ##Check for directory, and if it doesnt exist, create directory for the user, print success##
    If (!(Test-Path "$userFolder"))
        {
        New-Item -ItemType directory -Path $userFolder
        Write-Host
        Write-Host "- - - - - - - - -"
        Write-Host "Directory Created Successfully"
        }

    Else
        {
        Write-Host "- - - - - - - - -"
        Write-Host "Directory Exists - $userFolder"
        }

    ##Determine location of VHDX##
    $Path1 = "\\192.168.30.24\UPD\UVHD-"+$userSID+".vhdx"
    $Path2 = "\\192.168.30.24\UPD2\UVHD-"+$userSID+".vhdx"

    If (Test-Path "$Path1" -PathType leaf)
        {$UPDPath = "\\192.168.30.24\UPD\"}
    ElseIf (Test-Path "$Path2" -PathType leaf) 
        {$UPDPath = "\\192.168.30.24\UPD2\"}
    Else 
        {Write-Host 'Error: No VHDX Available' | Continue}


    if (Test-Path "$userFolder") 
        {
        Write-Verbose -Message "Waiting for VHDX archive to complete..." -Verbose
        set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  
        $Source = "$UPDPath"+"UVHD-"+"$userSID"+".vhdx" 
        $Target = "$userFolder\$userFile.7z"

        sz a -mx3 -bsp1 $Target $Source | Out-Null
        Write-Host "VHDX Archived: $userFolder"
        $ARCStatus = "Added"
        ####Remove-Item -Path "$UPDPath$Filename"
        }    

        if (!(Test-Path "$userFolder\$userFile.7z"))
        {
        Write-Host "No VHDX Archived"
        $ARCStatus = "Failed"
        }

    ##RUN PST CREATION##
    F-ExportMailbox
   
    ##Update Archive with PST if it exists.
    If (Test-Path "$userFolder\$userSearch.pst")
        {   
        Write-Verbose -Message "Waiting for PST archive to complete..." -Verbose
        set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  
        $BackupPST = "$userFolder\$userSearch.pst"
        $Source = "$BackupPST" 
        $Target = "$userFolder\$userFile.7z"
        sz a -mx3 -bsp1 $Target $Source | Out-Null
        Write-Host "PST Archived: $userFolder"
        $PSTStatus = "PST Added"
        }
    
    ##Otherwise, inform no PST available.
    ElseIf (!(Test-Path "$userFolder\$userSearch.pst"))
        {
        Write-Host 'No PST Archived.'
        $PSTStatus = "No PST"
        }

    ##Output Results to CSV and Append it if necessary
    $archiveResults = [PSCustomObject]
        @{
        Username = $usrData.SAM
        Name = "$userFolder"
        TerminationDate = "$Term"
        Archive = "$ARCStatus"
        PST = "$PSTStatus"
        }
    $archiveResults | Select-Object -Property Username,Name,TerminationDate,Archive,Pst | Export-CSV -Path "\\192.168.30.24\UPDArchives\Results-$TDate.csv" -Append -NoTypeInformation
    }

Function F-ExportMailbox
    {
    $PSTPath = Join-Path -Path $userFolder -ChildPath ('{0}.pst' -f $UsrData.SAM)
    Write-Verbose ("Exporting mailbox '{0}' to folder '{1}'" -f $UsrData.SAM, $PSTPath) -Verbose
    Try {Get-MailboxStatistics -Identity $UsrData.SAM -ErrorAction Stop} Catch 
        {
        Write-Host "Error: Mailbox Not Found"
        Continue
        }
    
    New-MailboxExportRequest -Mailbox $User.SAM -Name $User.SAM -FilePath $PstPath

    If (Get-MailboxExportRequest -Mailbox $User.SAM -Name $User.SAM -Status In-Progress)
    {
        Write-Host -NoNewline "Waiting for export to complete..."
        While(!(Get-MailboxExportRequest -Mailbox $User.SAM -Name $User.SAM -Status Completed))
            {
            #Sleep for a  few minutes
            Write-Host -NoNewline "."
            Start-Sleep -s 60
            }

        Write-Host "Done."
    }
    ElseIf(Get-MailboxExportRequest -Mailbox $User.SAM -Name $User.SAM -Status Failed) {Write-Host "Export Request Failed."}
    Else {Write-Host "No Mailbox to Export."}
}

Do
    {
    Show-Menu -Title "User Archiving Tool"
    $MenuOption = Read-Host "Select your option from the list above"

    Switch ($MenuOption)
        {
        '1'
            {F-Single}

        '2'
            {F-Import}

        '3'
            {F-Readme}

        '4'
            {Return}
        }
    }
Until ($MenuOption -eq '4')
