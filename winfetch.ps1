$osName = (Get-CimInstance -Class Win32_OperatingSystem).Caption
$os = Get-CimInstance -Class Win32_OperatingSystem -Property Caption, Version, LastBootUpTime, RegisteredUser, Organization
$system = Get-CimInstance -Class Win32_ComputerSystem -Property Model, SystemType, TotalPhysicalMemory
$cpu = Get-CimInstance Win32_Processor -Property Name, NumberOfCores, MaxClockSpeed
$gpu = Get-CimInstance -Namespace "root/CIMv2" -Class Win32_VideoController -Property Name
$colors = @("Red", "Green", "Yellow", "Blue", "Magenta", "Cyan", "White")
$osName = ($os.Caption -split 'Single')[0].Trim()
$osVersion = $os.Version
$uptime = (Get-Date) - $os.LastBootUpTime
$uptimeFormatted = '{0:D2}:{1:D2}' -f $uptime.Hours, $uptime.Minutes
$username = $env:USERNAME
$hostname = $env:COMPUTERNAME
$systemModel = $system.Model
$systemType = $system.SystemType
$cpuName =  ($cpu.Name -split 'with')[0].Trim() 
$cpuCount = $cpu.NumberOfCores
$cpuSpeed = $cpu.MaxClockSpeed
$gpu = $gpu.Name
$freeSpace = [math]::Round((Get-PSDrive -Name 'C').Free / 1GB)
$usedSpace = [math]::Round((Get-PSDrive -Name 'C').Used / 1GB)
$totalSpace=$freeSpace+$usedSpace
$shell=pwsh --version
$ramUsage = [math]::Round(((Get-CimInstance -ClassName Win32_OperatingSystem).TotalVisibleMemorySize - (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory)/1MB , 2)
$ramTotal = [math]::Round(((Get-CimInstance -ClassName Win32_OperatingSystem).TotalVisibleMemorySize)/1MB , 2)
$ramPercentage = [math]::Round(($ramUsage / $ramTotal) * 100)
#################################
#battery
$battery = Get-CimInstance -ClassName Win32_Battery
$status = $battery.BatteryStatus
$percentage = $battery.EstimatedChargeRemaining

$numblock=[math]::Round($percentage/10)

$spce=10-$numblock
#################################
function getres {
    param ()

    Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;

        public class screenreso
        {
            [DllImport("user32.dll")]
            public static extern IntPtr GetDC(IntPtr hwnd);

            [DllImport("gdi32.dll")]
            public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

            public static string getscreenreso()
            {
                IntPtr hdc = GetDC(IntPtr.Zero);
                int width = GetDeviceCaps(hdc, 118);
                int height = GetDeviceCaps(hdc, 117);
                return $"{width} x {height}";
            }
        }
"@

    $screenResolution = [screenreso]::getscreenreso()
    Write-Output $screenResolution
}
$res = getres
########################################
#terminal
$programs = 'powershell', 'pwsh', 'winpty-agent', 'cmd', 'zsh', 'bash', 'fish', 'env', 'nu', 'elvish', 'csh', 'tcsh', 'python', 'xonsh'
if ($PSVersionTable.PSEdition.ToString() -ne 'Core') {
    $parent = Get-Process -Id (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $PID" -Property ParentProcessId -CimSession $cimSession).ParentProcessId -ErrorAction Ignore
    for () {
        if ($parent.ProcessName -in $programs) {
            $parent = Get-Process -Id (Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($parent.ID)" -Property ParentProcessId -CimSession $cimSession).ParentProcessId -ErrorAction Ignore
            continue
        }
        break
    }
} else {
    $parent = (Get-Process -Id $PID).Parent
    for () {
        if ($parent.ProcessName -in $programs) {
            $parent = (Get-Process -Id $parent.ID).Parent
            continue
        }
        break
    }
}

$terminal = switch ($parent.ProcessName) {
    { $PSItem -in 'explorer', 'conhost' } { 'Windows Console' }
    'Console' { 'Console2/Z' }
    'ConEmuC64' { 'ConEmu' }
    'WindowsTerminal' { 'Windows Terminal' }
    'FluentTerminal.SystemTray' { 'Fluent Terminal' }
    'Code' { 'Visual Studio Code' }
    default { $PSItem }
}

if (-not $terminal) {
    $terminal = "$e[91m(Unknown)"
}

########################################
    
$OutputEncoding = [System.Text.Encoding]::UTF8
Write-Host "                                 $username@$hostname" -ForegroundColor Green
Write-Host "                               ┌───────────────────────────────┐ " -ForegroundColor Green
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan   
Write-Host "      OS: " -NoNewline -ForegroundColor Yellow
Write-Host $osName
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      Version: " -NoNewline -ForegroundColor Yellow
Write-Host $osVersion
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      Host: " -NoNewline -ForegroundColor Yellow
Write-Host $systemModel
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      CPU: " -NoNewline -ForegroundColor Yellow
Write-Output "$cpuName ($cpuCount)@$cpuSpeed MHz"
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      GPU: " -NoNewline -ForegroundColor Yellow
Write-Host $gpu
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host -NoNewline "      Uptime: " -ForegroundColor Yellow
Write-Host $uptimeFormatted "hrs"
Write-Host "░░░░░░░░░░░░░░░░░░░░░░░░░░" -NoNewline  -ForegroundColor cyan
Write-Host -NoNewline "      Shell: " -ForegroundColor Yellow
Write-Host $shell
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      Terminal: " -NoNewline -ForegroundColor Yellow
Write-Host $terminal
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host -NoNewline "      Resolution: " -ForegroundColor Yellow
Write-Host $res
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      Disk free: " -NoNewline -ForegroundColor Yellow
Write-Host "$freeSpace GB/$totalSpace GB"
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      Memory: " -NoNewline -ForegroundColor Yellow
Write-host $ramUsage "GB/"$ramTotal "GB" -NoNewline 
if($ramPercentage -ge 91){Write-host "($ramPercentage%)" -ForegroundColor red}
else{ Write-host "($ramPercentage%)"}
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      Type: " -NoNewline -ForegroundColor Yellow
Write-Host $systemType
Write-Host "████████████░░████████████" -NoNewline  -ForegroundColor cyan
Write-Host "      Battery: " -NoNewline -ForegroundColor Yellow
Write-Host "$percentage" -NoNewline 
Write-Host "%  " -NoNewline 
if ($status -eq 2 ){Write-Host ("█" * $numblock) -NoNewline -ForegroundColor green}
else{if ($numblock -ge 7 ){Write-Host ("█" * $numblock) -NoNewline -ForegroundColor green}
if ($numblock -ge 3 -and $numblock -lt 7 ){Write-Host ("█" * $numblock) -NoNewline -ForegroundColor yellow}
if ($numblock -lt 3 ){Write-Host ("█" * $numblock) -NoNewline -ForegroundColor red}}
Write-Host ("░" * $spce)-NoNewline
if($status -eq 2){Write-host "⚡" -NoNewline} 


Write-Host "`n                               └───────────────────────────────┘" -ForegroundColor Green

Write-HOst "                                         " -NoNewline
foreach ($color in $colors) {
    Write-Host " " -ForegroundColor $color -NoNewline 
}
Write-Host
