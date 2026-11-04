# Device Cleanup Automation (Intune + Entra)

## Overview
This project provides PowerShell scripts for identifying and cleaning up stale devices
in Microsoft Intune and Microsoft Entra ID.

The initial focus is on mobile devices (iOS and Android) managed by the MDM team.

---

## Objectives
- Identify devices inactive for 2+ years
- Reduce stale / non-compliant device counts
- Improve device inventory hygiene
- Prepare for automated cleanup via Azure Automation

---

## Scope (Current Phase)
- iOS
- iPadOS
- Android (including Android Enterprise)

---

## Project Structure

DeviceCleanup/
│
├── scripts/
│   ├── get-stale-mobile-devices.ps1
│   ├── disable-mobile-devices.ps1
│   ├── remove-mobile-devices.ps1
│   └── remove-autopilot.ps1
│
├── config/
│   └── settings.ps1
│
├── tests/
│   └── test-run.ps1      # Safe validation script (no changes made)
│
├── reports/
│   └── (generated CSV output)
│
├── logs/
│   └── (execution logs)
│
└── README.md