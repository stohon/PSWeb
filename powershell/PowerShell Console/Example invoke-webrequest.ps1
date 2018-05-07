. "C:\inetpub\wwwroot\PS\powershell\WebUtil.ps1"

write-in @"
{
    "url":"https://www.google.com"
}
"@

$results = Invoke-WebRequest -Uri $url -UseBasicParsing

write-out-all $results "WebRequest1"