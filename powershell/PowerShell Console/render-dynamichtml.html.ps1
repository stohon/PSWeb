. "$env:PSConsole\powershell\WebUtil.ps1"

write-out (ConvertFrom-Json '{ "name": "Some object", "value": 10 }') "numberIn1"

write-out-outstring "{{psresults.DataObjects.length}}" "html rendering"