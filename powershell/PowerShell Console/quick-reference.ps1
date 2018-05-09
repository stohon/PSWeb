. "$env:PSConsole\powershell\WebUtil.ps1"

write-out "test"

write-out ([Environment]::GetEnvironmentVariable('PSConsole')).ToString()