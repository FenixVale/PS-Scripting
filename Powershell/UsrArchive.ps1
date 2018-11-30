$host.ui.RawUI.WindowTitle = "User Archival Tool"
$TDate = Get-Date -UFormat "%Y%m%d"
Clear-Host

##Archive Function
function Invoke-Archive
{
    ##Get user data based on input and parse the First and Last name for formatting, parse SID to its own variable
    $UsrData = Get-ADUser -Identity $UsrSearch
    $NameF=$UsrData.surname+$UsrData.GivenName
    $SID=$UsrData.sid
    
    ##Check for directory, and if it doesnt exist, create directory for the user, print success
    $UsrFolder=($UsrData.surname+", "+$UsrData.GivenName).trim()
    If (!(Test-Path "\\IP\UPD Archives\$UsrFolder"))
    {
    New-Item -ItemType directory -Path "\\IP\UPD Archives\$UsrFolder"
    Write-Host
    Write-Host "Directory Created Successfully"
    }
        If (Test-Path "\\IP\UPD\UVHD-$SID.vhdx")
        {
        $UPDPath = "\\IP\UPD\UVHD-$SID.vhdx"

        }
        ElseIf (Test-Path "\\IP\UPD2\UVHD-$SID.vhdx")
        {
        $UPDPath = "\\IP\UPD2\UVHD-$SID.vhdx"
        }
        Else
        {
        Write-Host 'Error: Destination not found - No VHDX Available'
        }
    }
    ##Compress the VD based on SID search, print success or failure
    Compress-Archive -LiteralPath "$UPDPath" -CompressionLevel Fastest -DestinationPath "\\IP\UPD Archives\$UsrFolder\$Term$NameF.zip"
    Write-Host $UPDPath + "Test"
    If (Test-Path "\\IP\UPD Archives\$UsrFolder\$Term$NameF.zip")
    {
    Write-Host "Archive Created Successfully in the following directory: "\\xfiles\UPD Archives\$UsrFolder""
    $ARCStatus = "Success"
    ####Remove-Item -Path $Path
    }
    ElseIf (!(Test-Path "\\IP\UPD Archives\$UsrFolder\$Term$NameF.zip"))
    {
    Write-Host "Archive creation unsuccessful"
    $ARCStatus = "Failed"
    }

    ##Update Archive with PST if it exists.
    If (Test-Path "\\IP\UPD Archives\$UsrFolder\$NameF.pst")
    {
    Compress-Archive -U -LiteralPath "\\IP\UPD Archives\$UsrFolder\$NameF.pst" -CompressionLevel Fastest -DestinationPath "\\IP\UPD Archives\$UsrFolder\$Term$NameF.zip"
    Write-Host
    Write-Host 'Archive updated with PST.'
    ####Remove-Item -Path "\\IP\UPD Archivs\$UsrFolder\$NameF.pst"
    $PSTStatus = "PST Added"
    }
    ##Otherwise, inform no PST available.
    ElseIf (!(Test-Path "\\IP\UPD Archives\$UsrFolder\$NameF.pst"))
    {
    Write-Host 'No PST to add to Archive.'
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
    $archiveResults | Select-Object -Property Username,Name,TerminationDate,Archive,Pst | Export-CSV -Path "\\IP\UPD Archives\Results-$TDate.csv" -Append -NoTypeInformation
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
            Write-Host
            Write-Host
            Write-Host "User Complete."
            Write-Host "Results output to Archive Folder as 'Results-$TDate.csv'"
            Write-Host
            Pause
            Clear-Host
            }
        '2'
            {
            ##Import formatted CSV
            $Users = Import-csv -Delimiter "," -Path "\\IP\UPD Archives\Userlist.CSV"

            ##Recursively run the command for each user in the document
            foreach ($User in $Users)
                {
                ##Set Termination Date
                $Term = $User.TerminationDate

                ##Configure UsrSearch with the username
                $UsrSearch = $User.SAM

                ##Output this termination date and the username
                Write-Host $Term
                Write-Host $UsrSearch
                Write-Host
                Write-Host

                ##Invoke the Archiving function
                Invoke-Archive -Title 'Archiving...'
                }

            Write-Host
            Write-Host 'User List Complete.'
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
