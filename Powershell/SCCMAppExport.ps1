[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic') | Out-Null
$host.ui.RawUI.WindowTitle = "SCCM App Export Utility"
Clear-Host

    If(Test-Path 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1' -PathType Leaf)
        {
        Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
        Write-Verbose "ConfigMgr Module found and imported" -Verbose
        }
        Else
        {
        Write-Verbose "ConfigMgr Console not installed or Powershell Module not found. Script cannot be executed" -Verbose
        }

    CD 001:
    $exPath = "C:\Scripts\SCCMAppCatalog.csv"
    Get-CMApplication -Fast | select LocalizedDisplayName,CI_UniqueID | Sort LocalizedDisplayName | Export-CSV -Path $exPath -NoTypeInformation
    Write-Verbose "Exporting Application IDs to $Path" -Verbose

    CD C:

    $Appfile = Import-CSV -Delimiter "," -Path "C:\Scripts\SCCMAppCatalog.csv"

    Write-Verbose "Creating XML File ..." -Verbose
    Foreach ($Line in $Appfile)
        {
        $Label = $Line.LocalizedDisplayName
        $ID = $Line.CI_UniqueID -Replace '^.*Application_' -Replace '/.*'

        $xmlOut = ".\UIApps.xml"

        Write-Output "<Application Id=""$ID"" Label=""$Label"" Name=""$Label"" />" >> $xmlOut
        }
    Write-Verbose "Application entries exported to $xmlOut" -Verbose
