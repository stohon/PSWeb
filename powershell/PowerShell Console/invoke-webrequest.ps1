. "$env:PSConsole\powershell\WebUtil.ps1"

write-in @"
{
    "url":"https://www.google.com"
}
"@

$results = Invoke-WebRequest -Uri $url -UseBasicParsing

write-out $results "WebRequest1"