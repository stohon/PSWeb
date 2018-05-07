. "C:\inetpub\wwwroot\PS\powershell\WebUtil.ps1"
. "C:\inetpub\wwwroot\PS\powershell\Monitoring\Common\MachineTypes.ps1"

write-in @"
{
    "serverList":["localhost", "L154TEC006072.ams.bnymellon.net"]
}
"@

$global:cpuAndMemoryDetails = @()

$serverList | ForEach-Object { 
                $cpuAndMemoryDetail = New-Object CPUAndMemoryDetail
                $cpuAndMemoryDetail.ServerName = $_

                $loadPerc = Get-WmiObject win32_processor -ComputerName $cpuAndMemoryDetail.ServerName | 
                                Measure-Object -property LoadPercentage -Average | 
                                Select-Object Average
                $cpuAndMemoryDetail.LoadPercentage = $loadPerc.Average

                $OS = Get-WmiObject Win32_OperatingSystem  -computername $cpuAndMemoryDetail.ServerName
                $cpuAndMemoryDetail.FreePhysicalMemory = [math]::Round($OS.FreePhysicalMemory / 1MB, 1)
                $cpuAndMemoryDetail.TotalVisibleMemorySize = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 1)

                $Global:cpuAndMemoryDetails += @($cpuAndMemoryDetail)
            }

write-out $global:cpuAndMemoryDetails "CPUMemory1"