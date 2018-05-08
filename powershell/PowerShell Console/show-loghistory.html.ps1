. "C:\inetpub\wwwroot\PS\powershell\WebUtil.ps1"

write-in @"
{
    "numDaysOld": 1
}
"@

$outString = ""
Get-ChildItem -Path "C:\inetpub\wwwroot\PS\logs" |
    ? { $_.LastWriteTime -gt (Get-Date).AddDays(-$numDaysOld) } |
    sort LastWriteTime -Descending |
    % {
        $outString += "<span>" + $_.LastWriteTime + "</span> - <a target='_blank' href='./logs/" + $_.Name + "'>" + $_.Name + "</a><br/>" 
    }

write-out $outString "history"