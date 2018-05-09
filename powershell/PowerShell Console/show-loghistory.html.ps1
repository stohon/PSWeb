. "$env:PSConsole\powershell\WebUtil.ps1"

write-in @"
{
    "numDaysOld": 1
}
"@

$outString = ""
Get-ChildItem -Path "$env:PSConsole\logs" |
    ? { $_.LastWriteTime -gt (Get-Date).AddDays(-$numDaysOld) } |
    sort LastWriteTime -Descending |
    % {
        $outString += "<span>" + $_.LastWriteTime + "</span> - <a target='_blank' href='./logs/" + $_.Name + "'>" + $_.Name + "</a><br/>" 
    }

write-out $outString "history"