. "$env:PSConsole\powershell\WebUtil.ps1"

write-in @"
{
    "siteCollectionURL":"https://localhost"
}
"@

Add-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue

$out = Get-SPSite $siteCollectionURL | Select-Object Url, Port, CompatibilityLevel, Usage, WriteLocked

write-out $out "SPSite1"
