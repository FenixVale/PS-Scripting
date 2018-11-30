Get-ADUser -Filter * -SearchBase "CN=Users,DC=contoso,DC=COM" -Properties DisplayName | % {Set-ADUser $_ -replace @{msExchRecipientDisplayType="1073741824"}}
