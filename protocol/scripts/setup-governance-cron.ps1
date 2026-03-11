# Setup Governance Weekly Cron Job
# Creates a scheduled task to run governance-analyzer.ps1 every Wednesday at 9 AM
# Requires: Administrator privileges

param(
    [switch]$Remove,
    [switch]$WhatIf
)

$TaskName = "OpenClaw-Governance-Weekly"
$ScriptPath = "C:\Users\seval\.openclaw\workspace\protocol\scripts\governance-analyzer.ps1"

if ($Remove) {
    Write-Host "Removing scheduled task: $TaskName" -ForegroundColor Yellow
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Task removed (if it existed)" -ForegroundColor Green
    exit 0
}

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: This script requires Administrator privileges" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator', then run this script" -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Setup Governance Weekly Cron ===" -ForegroundColor Cyan
Write-Host "Task: $TaskName"
Write-Host "Script: $ScriptPath"
Write-Host "Schedule: Every Wednesday at 9:00 AM"
Write-Host ""

# Check if task already exists
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($existingTask) {
    Write-Host "Task already exists. Updating..." -ForegroundColor Yellow
}

# Create action
$action = New-ScheduledTaskAction -Execute "pwsh" -Argument "-NoProfile -WindowStyle Hidden -File `"$ScriptPath`" -GenerateProposals"

# Create trigger (weekly, Wednesday 9 AM)
$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Wednesday -At 9am

# Create principal (run as current user, highest privileges)
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType S4U -RunLevel Highest

if ($WhatIf) {
    Write-Host "[WhatIf] Would create/update scheduled task with:" -ForegroundColor Cyan
    Write-Host "  Action: pwsh -NoProfile -WindowStyle Hidden -File `"$ScriptPath`" -GenerateProposals"
    Write-Host "  Trigger: Weekly on Wednesday at 9:00 AM"
    Write-Host "  Principal: $env:USERNAME (highest privileges)"
    exit 0
}

# Register the task
try {
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -Principal $principal -Force -ErrorAction Stop
    Write-Host "✓ Scheduled task created successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "To verify:" -ForegroundColor Cyan
    Write-Host "  Get-ScheduledTask -TaskName `"$TaskName`""
    Write-Host ""
    Write-Host "To run manually:" -ForegroundColor Cyan
    Write-Host "  Start-ScheduledTask -TaskName `"$TaskName`""
    Write-Host ""
    Write-Host "To remove:" -ForegroundColor Cyan
    Write-Host "  Unregister-ScheduledTask -TaskName `"$TaskName`" -Confirm:`$false"
} catch {
    Write-Host "ERROR: Failed to create scheduled task" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}
