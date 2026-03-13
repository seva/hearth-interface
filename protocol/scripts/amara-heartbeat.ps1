# Amara — Heartbeat Integration
# Runs every heartbeat to log violations, update compliance, check thresholds

param(
    [string]$OutputPath = "$env:USERPROFILE\.openclaw\governance",
    [switch]$AlertOnCritical
)

$ErrorActionPreference = "Stop"

# Ensure governance directory exists
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$violationsPath = Join-Path $OutputPath "violations.jsonl"
$compliancePath = Join-Path $OutputPath "compliance.json"

# ============================================================================
# This script is called by HEARTBEAT.md to:
# 1. Check for new violations since last heartbeat
# 2. Update compliance metrics
# 3. Alert if thresholds exceeded
#
# Note: Actual violation logging happens in protocol-enforcer.ts
# This script focuses on metrics and alerting
# ============================================================================

function Get-ExistingCompliance {
    if (Test-Path $compliancePath) {
        return Get-Content $compliancePath -Raw | ConvertFrom-Json
    }
    return $null
}

function Calculate-ComplianceMetrics {
    param([string]$ViolationsPath)
    
    if (!(Test-Path $ViolationsPath)) {
        return @{
            complianceRate = 100
            totalViolations = 0
            recoveredCount = 0
        }
    }
    
    $violations = Get-Content $ViolationsPath | ForEach-Object {
        $_ | ConvertFrom-Json
    }
    
    # 7-day window
    $cutoff = (Get-Date).AddDays(-7)
    $recentViolations = $violations | Where-Object {
        [DateTime]::Parse($_.timestamp) -gt $cutoff
    }
    
    $total = $recentViolations.Count
    $recovered = ($recentViolations | Where-Object { $_.recovered -eq $true }).Count
    
    $complianceRate = if ($total -eq 0) { 100 } else { [Math]::Round(($recovered / $total) * 100, 2) }
    
    return @{
        complianceRate = $complianceRate
        totalViolations = $total
        recoveredCount = $recovered
    }
}

function Calculate-Drift {
    param(
        [double]$CurrentRate,
        [object]$PreviousCompliance
    )
    
    if ($null -eq $PreviousCompliance -or $null -eq $PreviousCompliance.complianceRate) {
        return 0
    }
    
    $previousRate = [double]$PreviousCompliance.complianceRate
    $drift = [Math]::Round($CurrentRate - $previousRate, 2)
    
    return $drift
}

function Write-Alert {
    param(
        [string]$Level,
        [string]$Message
    )
    
    $alert = [PSCustomObject]@{
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        level = $Level
        message = $Message
    }
    
    $alertPath = Join-Path $OutputPath "alerts.jsonl"
    $alert | ConvertTo-Json -Compress | Add-Content $alertPath -Encoding UTF8
}

# ============================================================================
# Main Execution
# ============================================================================

$previousCompliance = Get-ExistingCompliance
$metrics = Calculate-ComplianceMetrics -ViolationsPath $violationsPath
$drift = Calculate-Drift -CurrentRate $metrics.complianceRate -PreviousCompliance $previousCompliance

# Update compliance.json
$complianceData = [PSCustomObject]@{
    complianceRate = $metrics.complianceRate
    drift = $drift
    totalViolations = $metrics.totalViolations
    recoveredCount = $metrics.recoveredCount
    windowDays = 7
    lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    previousRate = if ($previousCompliance) { $previousCompliance.complianceRate } else { $null }
}

$complianceData | ConvertTo-Json -Depth 10 | Set-Content $compliancePath -Encoding UTF8

# Check thresholds and alert if needed
if ($metrics.complianceRate -lt 50) {
    Write-Alert -Level "CRITICAL" -Message "Compliance rate dropped to $($metrics.complianceRate)%"
    if ($AlertOnCritical) {
        Write-Host "[!!] CRITICAL: Compliance rate $($metrics.complianceRate)% - immediate review needed" -ForegroundColor Red
    }
} elseif ($drift -gt 10) {
    Write-Alert -Level "WARNING" -Message "Drift detected: +$drift% week-over-week"
    if ($AlertOnCritical) {
        Write-Host "[!] WARNING: Drift +$drift% detected - review recommended" -ForegroundColor Yellow
    }
}

# Output summary for heartbeat log
Write-Host "[Amara] Compliance: $($metrics.complianceRate)% | Drift: $drift% | Violations (7d): $($metrics.totalViolations)" -ForegroundColor Cyan

exit 0
