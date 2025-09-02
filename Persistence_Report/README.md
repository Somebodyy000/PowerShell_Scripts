# Windows Persistence Report Script

This PowerShell script generates a report of potential persistence mechanisms and suspicious activities on a Windows machine (with a Intel CPU).
It collects information from scheduled tasks, registry autoruns, startup folders, running services, PowerShell execution logs, process creation logs, and cloud connection traces.

The output is saved in a timestamped text file under the default path `C:\Reports`, or if you choose to change, change the `$MainPath` variable.

---

## Overview

- [Motivation](#motivation)
- [Sections Collected](#sections-collected)
  - [1. Scheduled Tasks](#1-scheduled-tasks)
  - [2. Registry Autoruns](#2-registry-autoruns)
  - [3. Startup Folders](#3-startup-folders)
  - [4. Running Services](#4-running-services)
  - [5. PowerShell Script Block Logging (Event ID 4104)](#5-powershell-script-block-logging-(event-id-4104))
  - [6. PowerShell Process Creation (Event ID 4688)](#6-powershell-process-creation-(event-id-4688))
  - [7. Cloud Connections (Dropbox, Yandex, pCloud)](#7-cloud-connections-(dropbox,yandex,-pcloud))
- [Usage](#usage)
- [Report Location](#report-location)
- [Report Example](#report-example)
- [Forensic Relevance](#forensic-relevance)
- [Limitations](#limitations)

---

## Motivation

This script was made as a practical forensic help after learning about a new technique used by the APT37 group.
The group has been hiding the RoKRAT (Remote Access Trojan) malware inside JPEG image files, and exploiting mspaint.exe as a living-off-the-land binary (LOLBin) to help evade detection, and steal data.

---

## Sections Collected

### 1. Scheduled Tasks

- Runs:
```powershell
 
  schtasks /query /fo LIST /v
 
```

- Filters output for suspicious executables/scripts:
  - `powershell`
  - `cmd.exe`
  - `.bat`, `.vbs`, `.js`
- Helps detect malicious tasks configured for persistence.

### 2. Registry Autoruns

- Checks common autorun registry keys:
  - `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`
  - `HKLM\Software\Microsoft\Windows\CurrentVersion\Run`
- Lists programs set to run at user or system startup.
- Useful for spotting persistence via registry keys.

### 3. Startup Folders

- Enumerates:
  - `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup`
  - `%ProgramData%\Microsoft\Windows\Start Menu\Programs\StartUp`
- Lists file path, size, and last modified date.
- Attackers often place shortcuts or executables here to get persistence.

### 4. Running Services

- Lists all currently running services:
  - Name
  - DisplayName
  - Status
  - StartType
- Useful for spotting malicious or unexpected services configured to auto-start.

### 5. PowerShell Script Block Logging (Event ID 4104)

- Collects from:
  - `Microsoft-Windows-PowerShell/Operational` event log
- Event ID `4104` records PowerShell script blocks executed.
- Helps identify malicious or obfuscated scripts executed on the host.

### 6. PowerShell Process Creation (Event ID 4688)

- Collects from:
  - Window `Security` event log
- Filters for:
  - Event ID `4688` (new process created)
  - Only processes containing `"powershell"`
- Useful for tracking when powershell was launched, including command-line arguments.

### 7. Cloud Connections (Dropbox, Yandex, pCloud)

- Scans last 100 events from the Windows `Security` log.
- Looks for keywords:
  - `dropbox`
  - `yandex`
  - `pcloud`
- Helps detect signs of cloud storage services used for data exfiltration or C2 activity.

## Usage

Run powershell as Administrator:

```powershell
 
  powershell -ExecutionPolicy Bypass -File .\scan.ps1
 
```

Default output will be saved under:
```makefile
 
  C:\Reports\persistence_report_<...>.txt
 
```

## Report Location

- Default folder: `C:\Reports`
- Report file: `persistence_report_<...>.txt`

- If `C:\Reports` or the chosen path does not exist, the script will automatically create it.

---

## Report Example

```
 
=== Persistence Report ===
Generated: 09/02/2025 00:00:00
==================================


=======================
=== Scheduled Tasks ===
=======================

TaskName: \UpdateCheck
Task To Run: powershell.exe -ExecutionPolicy Bypass -File C:\Users\Public\update.ps1




=========================
=== Registry Autoruns ===
=========================

Checking: HKLM\Software\Microsoft\Windows\CurrentVersion\Run
Updater    REG_SZ    C:\Users\Public\malware.exe

...
 
```

## Forensic Relevance

This script is intended for incident response and forensic triage.
It focuses on persistence techniques and suspicious activity that attackers commonly use:

- Scheduled tasks
- Registry run keys
- Startup folders
- Malicious services
- PowerShell abuse
- Cloud storage exfiltration

## Limitations

- Only a subset of autorun registry is checked (attackers may use others).
- Startup folder enumeration may miss alternate persistence paths.
- `Get-WinEvent` queries can be slow on large logs; maximum of 150 events for performance.


