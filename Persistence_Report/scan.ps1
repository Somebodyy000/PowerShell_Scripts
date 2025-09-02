$MainPath = "C:\Reports"    # Change to your folder path

$ReportPath = "$MainPath\persistence_report_$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"

if (!(Test-Path $MainPath)) {
    New-Item -ItemType Directory -Path $MainPath | Out-Null
}



"=== Persistence Report ===" | Out-File $ReportPath

"Generated: $(Get-Date)" | Out-File $ReportPath -Append

"==================================" | Out-File $ReportPath -Append

"`n" | Out-File $ReportPath -Append


"=======================" | Out-File $ReportPath -Append
"=== Scheduled Tasks ===" | Out-File $ReportPath -Append
"=======================" | Out-File $ReportPath -Append
"" | Out-File $ReportPath -Append

# Takes too long to search them all
# schtasks /query /fo LIST /v | Out-File $ReportPath -Append

# Instead filter by if contains the keywords:   powershell   cmd.exe   \.bat   \.vbs   \.js
schtasks /query /fo LIST /v | Select-String -Pattern "powershell|cmd.exe|\.bat|\.vbs|\.js" | Out-File $ReportPath -Append

"`n" | Out-File $ReportPath -Append
Write-Host "Scheduled Tasks completed."



"=========================" | Out-File $ReportPath -Append
"=== Registry Autoruns ===" | Out-File $ReportPath -Append
"=========================" | Out-File $ReportPath -Append
"" | Out-File $ReportPath -Append

$autorunKeys = @(
    "HKCU\Software\Microsoft\Windows\CurrentVersion\Run",
    "HKLM\Software\Microsoft\Windows\CurrentVersion\Run"
)

foreach ($key in $autorunKeys) {
    "Checking: $key" | Out-File $ReportPath -Append
    try {
        reg query $key | Out-File $ReportPath -Append
    } catch {
        "Key not found: $key" | Out-File $ReportPath -Append
    }
    "`n" | Out-File $ReportPath -Append
}
Write-Host "Registry Autoruns completed."



"=======================" | Out-File $ReportPath -Append
"=== Startup Folders ===" | Out-File $ReportPath -Append
"=======================" | Out-File $ReportPath -Append
"" | Out-File $ReportPath -Append

$startupPaths = @(
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
)

foreach ($path in $startupPaths) {
    "Listing: $path" | Out-File $ReportPath -Append
    Get-ChildItem -Path $path -Force -ErrorAction SilentlyContinue | 
        Select-Object FullName, Length, LastWriteTime | 
        Format-Table -AutoSize | Out-String | 
        Out-File $ReportPath -Append
    "`n" | Out-File $ReportPath -Append
}
Write-Host "Startup Folders completed."

"========================" | Out-File $ReportPath -Append
"=== Running Services ===" | Out-File $ReportPath -Append
"========================" | Out-File $ReportPath -Append

Get-Service | Where-Object {$_.Status -eq "Running"} | Sort-Object DisplayName | Format-Table Name, DisplayName, Status, StartType | Out-String | Out-File $ReportPath -Append

"`n" | Out-File $ReportPath -Append
Write-Host "Running Services completed."



"=========================================================" | Out-File $ReportPath -Append
"=== PowerShell Script Block Execution (Event ID 4104) ===" | Out-File $ReportPath -Append
"=========================================================" | Out-File $ReportPath -Append
"" | Out-File $ReportPath -Append

try {
    Get-WinEvent -LogName Microsoft-Windows-PowerShell/Operational -MaxEvents 150 |
    Where-Object {$_.Id -eq 4104} |
    Select-Object TimeCreated, Id, Message |
    Format-Table -AutoSize | Out-String | Out-File $ReportPath -Append
} catch { "Failed to read PowerShell logs." | Out-File $ReportPath -Append }

"`n" | Out-File $ReportPath -Append
Write-Host "PowrShell Script Block Execution completed."



"===================================================" | Out-File $ReportPath -Append
"=== PowerShell Process Creation (Event ID 4688) ===" | Out-File $ReportPath -Append
"===================================================" | Out-File $ReportPath -Append
"" | Out-File $ReportPath -Append

try {
    $PowershellProcesses = Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4688} -MaxEvents 150 | Where-Object { $_.Message -match "powershell" }

    if ($PowershellProcesses) {
        $PowershellProcesses | Select-Object TimeCreated, Id, Message | Format-Table -AutoSize | Out-String | Out-File $ReportPath -Append
    } else {
        "No Security log for Powershell processes found." | Out-File $ReportPath -Append
    }
} catch { 
    "Failed to read Security logs for PowerShell processes." | Out-File $ReportPath -Append 
}

"`n" | Out-File $ReportPath -Append
Write-Host "PowerShell Process Creation completed."



"=================================================" | Out-File $ReportPath -Append
"=== Cloud Connections (Dropbox/Yandex/pCloud) ===" | Out-File $ReportPath -Append
"=================================================" | Out-File $ReportPath -Append
"" | Out-File $ReportPath -Append

$cloudDomains = "dropbox","yandex","pcloud"

try {
    $events = Get-WinEvent -LogName Security -MaxEvents 100 -ErrorAction Stop
} catch {
    Write-Host "Failed to query Security log: $_"
    "Failed to query Security log: $_" | Out-File $ReportPath -Append
}

foreach ($domain in $cloudDomains) {
    try {
        $matches = $events | Where-Object {$_.Message -match $domain}

        if ($matches) {
            $matches | Select-Object TimeCreated, Id, Message | Format-Table -AutoSize | Out-String | Out-File $ReportPath -Append
        } else {
            "No matches found for $domain" | Out-File $ReportPath -Append
        }
    } catch {
        "Error while checking for $domain : $_" | Out-File $ReportPath -Append
    }
    "" | Out-File $ReportPath -Append
}

"`n" | Out-File $ReportPath -Append
Write-Host "Cloud Connections completed."
Write-Host ""



"" | Out-File $ReportPath -Append
"=== End of Report ===" | Out-File $ReportPath -Append
"" | Out-File $ReportPath -Append

Write-Host "Forensic report complete. Saved to $ReportPath"
