##Requires AlphaFS Module
##https://gallery.technet.microsoft.com/scriptcenter/1abd77a5-9c0b-4a2b-acef-90dbb2b84e85
Import-Module -Name 'C:\NTFSSecurity\AlphaFS.dll'
Clear-Host


foreach ($folder in Get-ChildItem -Path <#Destination Directory#> -Recurse -Directory)
{
$username = $folder
Add-NTFSAccess -Path "<# Destination Directory #>\$Username" -Account "CONTOSO\$username" -AccessRights FullControl
Write-Host "Permissions assigned for folder of $Username"
}
