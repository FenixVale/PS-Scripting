Add-PSSnapin Microsoft.Exchange.Management.Powershell.SnapIn;

##Import formatted CSV
$Users = Import-csv -Delimiter "," -Path "\\#PATH##\Userlist.CSV"

##Export the user's mailbox from Exchange
foreach ($User in $Users)
{
$UsrSearch = $User.SAM
$UsrFolder = $User.Lastname+", "+$User.Firstname
New-Item -ItemType Directory -Path "\\#PATH##\$UsrFolder"
New-MailboxExportRequest -Mailbox $UsrSearch -FilePath "\\#PATH##\$UsrFolder\$UsrSearch.pst"
Get-MailboxExportRequest -Status Completed
}
