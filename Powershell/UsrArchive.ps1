$host.ui.RawUI.WindowTitle = "User Archival Tool"
$TDate = Get-Date -UFormat "%Y%m%d"
Clear-Host

##Archive Function
function Invoke-Archive
{
    ##Get user data based on input and parse the First and Last name for formatting, parse SID to its own variable
    Try {$UsrData = Get-ADUser -Identity $UsrSearch -ErrorAction Stop}
    
    Catch 
    {
    Write-Host "Error: User Not Found"
    Write-Host "- - - - -"
    Continue
    }

    $NameF=$UsrData.surname+$UsrData.GivenName
    $SID=$UsrData.sid
    $UsrFolder=(($UsrData.surname).trim()+", "+($UsrData.GivenName).trim())


    ##Check for directory, and if it doesnt exist, create directory for the user, print success##
    If (!(Test-Path "\\192.168.30.24\UPDArchives\$UsrFolder"))
    {
    New-Item -ItemType directory -Path "\\192.168.30.24\UPDArchives\$UsrFolder"
    Write-Host
    Write-Host "- - - - - - - - -"
    Write-Host "Directory Created Successfully"
    }

    Else
    {
    Write-Host "- - - - - - - - -"
    Write-Host "Directory Exists - \\192.168.30.24\UPDArchives\$UsrFolder"
    }

    ##Determine location of VHDX##
    $Path1 = "\\192.168.30.24\UPD\UVHD-$SID.vhdx"
    $Path2 = "\\192.168.30.24\UPD2\UVHD-$SID.vhdx"

        If (Test-Path "$Path1" -PathType leaf)
        {$UPDPath = "\\192.168.30.24\UPD\"}
        ElseIf (Test-Path "$Path2" -PathType leaf) {$UPDPath = "\\192.168.30.24\UPD2\"}
        Else {Write-Host 'Error: No VHDX Available'
        Continue}
        
        $UsrFile=($Term+$NameF).trim()

        if (Test-Path "\\192.168.30.24\UPDArchives\$UsrFolder") 
        {
        set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  
        $Source = "$UPDPath"+"UVHD-"+"$SID"+".vhdx" 
        $Target = "\\192.168.30.24\UPDArchives\$UsrFolder\$UsrFile.7z"

        sz a -mx3 -bsp1 $Target $Source | Out-Null
        Write-Host "VHDX Archived: \\xfiles\UPDArchives\$UsrFolder"
        $ARCStatus = "Success"
        ####Remove-Item -Path "$UPDPath$Filename"
        }    

        if (!(Test-Path "\\192.168.30.24\UPDArchives\$UsrFolder\$UsrFile.7z"))
        {
        Write-Host "No VHDX Archived"
        $ARCStatus = "Failed"
        }

   
    ##Update Archive with PST if it exists.
    If (Test-Path "\\192.168.30.24\UPDArchives\$UsrFolder\$UsrSearch.pst")
        {   
        set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  
        $BackupPST = "\\192.168.30.24\UPDArchives\$UsrFolder\$UsrSearch.pst"
        $Source = "$BackupPST" 
        $Target = "\\192.168.30.24\UPDArchives\$UsrFolder\$UsrFile.7z"

        sz a -mx3 -bsp1 $Target $Source | Out-Null


        Write-Host "PST Archived: \\xfiles\UPDArchives\$UsrFolder"
        ####Remove-Item -Path "\\192.168.30.24\UPDArchives\$UsrFolder\$NameF.pst"
        $PSTStatus = "PST Added"
        }
    
    ##Otherwise, inform no PST available.
    ElseIf (!(Test-Path "\\192.168.30.24\UPDArchives\$UsrFolder\$UsrSearch.pst"))
        {
        Write-Host 'No PST Archived.'
        $PSTStatus = "No PST"
        }

    ##Output Results to CSV and Append it if necessary
    $archiveResults = [PSCustomObject]@{
    Username = "$UsrSearch"
    Name = "$UsrFolder"
    TerminationDate = "$Term"
    Archive = "$ARCStatus"
    PST = "$PSTStatus"
    }
    $archiveResults | Select-Object -Property Username,Name,TerminationDate,Archive,Pst | Export-CSV -Path "\\192.168.30.24\UPDArchives\Results-$TDate.csv" -Append -NoTypeInformation
}

##Menu
function Show-Menu
{
    param (
        [string]$Title = 'User Archival Tool'
          )
          Write-Host "==================== $Title ===================="
          Write-Host "=                                                          ="
          Write-Host "=                   1) Archive User                        ="
          Write-Host "=                                                          ="
          Write-Host "=                                                          ="
          Write-Host "=                2) Archive List of Users                  ="
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
    Show-Menu -Title 'User Archival Tool'

    $selection = Read-Host "Please select an option from the list"
    switch ($selection)
        {
        '1'
            {
            ##User input for termination date
            $Term=Read-Host "Please enter the termination date as a single number in the format YYYYMMDD"

            ##User input for employee username
            $UsrSearch=Read-Host "Enter the Username of the employee in the format first initial, last name (EX: JDoe)"
            Write-Host 
            Write-Host

            ##Invoke the archiving function
            Invoke-Archive -Title 'Archival...'
            Write-Host "User Complete."
            Write-Host "- - - - - - - - -"
            Write-Host "Results output to Archive Folder as 'Results-$TDate.csv'"
            Write-Host
            Pause
            Clear-Host
            }
        '2'
            {
            ##Import formatted CSV
            $Users = Import-csv -Delimiter "," -Path "\\192.168.30.24\UPDArchives\Userlist.CSV"

            ##Recursively run the command for each user in the document
            foreach ($User in $Users)
                {
                ##Set Termination Date
                $Term = $User.TerminationDate

                ##Configure UsrSearch with the username
                $UsrSearch = $User.SAM

                ##Output this termination date and the username
                Write-Host
                Write-Host "- - - - -"
                Write-Host $UsrSearch

                ##Invoke the Archiving function
                Invoke-Archive -Title 'Archiving...'
                }

            Write-Host 'User List Complete.'
            Write-Host "- - - - - - - - -"
            Write-Host "Results output to Archive Folder as 'Results-$TDate.csv'"
            Write-Host
            pause
            Clear-Host
            }
        '3'
            {
            Clear-Host
            Write-Host "The use of this utility is for archiving terminated/resigned users' PST file and their Virtual Drives."
            Write-Host "This utility operates with specific file locations, and if these storage locations have changed, will need to be updated accordingly."
            Write-Host ""
            Write-Host "Option 1: Enter the Termination Date of the user, and their Username used to login (I.E: JDoe). The operation will run and export the results to the archival folder."
            Write-Host ""
            Write-Host "Option 2: Place a CSV file in the Archive folder using the Templae there. Execute Option 2, and it will automatically parse the file"
            Write-Host "and export the results to a CSV, appending it as necessary. For the Archive column, Success means an archive has been created/updated"
            Write-Host "and Failure only means that the archive already exists. For PST, PST Added means that their outlook PST has been added to the archive"
            Write-Host "and No PST simply means that either there was no PST to add, or one already exists in the archive."
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
