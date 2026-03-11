# Auto-Fix: Threshold Auto-Tuning
# Analyzes violation patterns and auto-adjusts governance thresholds within safe bounds
# Examples: analysisWindow, driftThreshold, compliance alerts
#
# Parent Epic: #114 (Phase 2: Pattern-Specific Auto-Fixes)
# Risk Tier: Low (adjusts within pre-defined safe bounds only)
# Cap: Counts toward 3/week auto-apply limit

param(
    [string]$ConfigPath = "$env:USERPROFILE\.openclaw\governance\config.json",
    [string]$ViolationsPath = "$env:USERPROFILE\.openclaw\governance\violations.jsonl",
    [string]$AutoApplyLogPath = "$env:USERPROFILE\.openclaw\governance\auto-apply.log",
    [string]$CompliancePath = "$env:USERPROFILE\.openclaw\governance\compliance.json",
    [int]$AnalysisWindowDays = 30,
    [switch]$DryRun,
    [switch]$Verbose
)

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "o"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARN") { "Yellow" } else { "Green" })
    return $logEntry
}

function Test-AutoApplyCap {
    param(
        [string]$AutoApplyLogPath,
        [int]$MaxPerWeek = 3
    )
    
    if (-not (Test-Path $AutoApplyLogPath)) {
        return $true
    }
    
    $WeekAgo = (Get-Date).AddDays(-7)
    $RecentApplies = Get-Content $AutoApplyLogPath | Where-Object {
        try {
            $entry = $_ | ConvertFrom-Json
            [DateTime]::Parse($entry.timestamp) -ge $WeekAgo
        } catch {
            $false
        }
    }
    
    $count = @($RecentApplies).Count
    if ($count -ge $MaxPerWeek) {
        Write-Log "Auto-apply cap reached: $count/$MaxPerWeek this week" "WARN"
        return $false
    }
    
    Write-Log "Auto-apply usage: $count/$MaxPerWeek this week"
    return $true
}

# Safe bounds for threshold tuning (hardcoded limits)
$SafeBounds = @{
    analysisWindowDays = @{ min = 3; max = 14; default = 7 }
    driftThreshold = @{ min = 0.05; max = 0.20; default = 0.10 }
    complianceAlertThreshold = @{ min = 0.80; max = 0.95; default = 0.90 }
    idleWatchdogStalenessMinutes = @{ min = 15; max = 120; default = 30 }
}

function Analyze-ViolationFrequency {
    param(
        [string]$ViolationsPath,
        [int]$WindowDays
    )
    
    if (-not (Test-Path $ViolationsPath)) {
        return @{ total = 0; perDay = 0; trend = "stable" }
    }
    
    $CutoffDate = (Get-Date).AddDays(-$WindowDays)
    $Violations = @()
    
    $Lines = Get-Content $ViolationsPath | Where-Object { $_.Trim() }
    foreach ($Line in $Lines) {
        try {
            $V = $Line | ConvertFrom-Json
            $VTime = [DateTime]::Parse($V.timestamp)
            if ($VTime -ge $CutoffDate) {
                $Violations += $V
            }
        } catch {
            # Skip malformed lines
        }
    }
    
    $perDay = $Violations.Count / $WindowDays
    
    # Calculate trend (compare first half vs second half of window)
    $HalfWindow = $WindowDays / 2
    $FirstHalf = $Violations | Where-Object { 
        [DateTime]::Parse($_.timestamp) -lt (Get-Date).AddDays(-$HalfWindow)
    }
    $SecondHalf = $Violations | Where-Object {
        [DateTime]::Parse($_.timestamp) -ge (Get-Date).AddDays(-$HalfWindow)
    }
    
    $trend = "stable"
    if ($SecondHalf.Count -gt ($FirstHalf.Count * 1.5)) {
        $trend = "increasing"
    } elseif ($FirstHalf.Count -gt ($SecondHalf.Count * 1.5)) {
        $trend = "decreasing"
    }
    
    return @{
        total = $Violations.Count
        perDay = [Math]::Round($perDay, 2)
        trend = $trend
        firstHalf = $FirstHalf.Count
        secondHalf = $SecondHalf.Count
    }
}

function Calculate-OptimalThreshold {
    param(
        [string]$ThresholdName,
        [object]$CurrentConfig,
        [object]$ViolationStats
    )
    
    $bounds = $SafeBounds[$ThresholdName]
    if (-not $bounds) {
        return $null
    }
    
    $currentValue = $CurrentConfig.$ThresholdName
    if (-not $currentValue) {
        $currentValue = $bounds.default
    }
    
    # Adjustment logic based on violation patterns
    $adjustment = 0
    
    if ($ThresholdName -eq "analysisWindowDays") {
        # More violations → longer window for better pattern detection
        if ($ViolationStats.trend -eq "increasing" -and $ViolationStats.perDay -gt 2) {
            $adjustment = 2
            Write-Log "Increasing analysis window: high violation rate ($($ViolationStats.perDay)/day)"
        }
        # Few violations → shorter window for faster response
        elseif ($ViolationStats.perDay -lt 0.5) {
            $adjustment = -1
            Write-Log "Decreasing analysis window: low violation rate ($($ViolationStats.perDay)/day)"
        }
    }
    
    elseif ($ThresholdName -eq "driftThreshold") {
        # Increasing violations → relax threshold temporarily
        if ($ViolationStats.trend -eq "increasing") {
            $adjustment = 0.02
            Write-Log "Relaxing drift threshold: violation trend increasing"
        }
        # Stable/decreasing → tighten threshold
        elseif ($ViolationStats.trend -eq "decreasing" -and $ViolationStats.perDay -lt 1) {
            $adjustment = -0.01
            Write-Log "Tightening drift threshold: violation trend decreasing"
        }
    }
    
    elseif ($ThresholdName -eq "complianceAlertThreshold") {
        # High violation rate → lower alert threshold (alert sooner)
        if ($ViolationStats.perDay -gt 3) {
            $adjustment = -0.05
            Write-Log "Lowering alert threshold: high violation rate"
        }
    }
    
    # Apply adjustment within bounds
    $newValue = $currentValue + $adjustment
    $newValue = [Math]::Max($bounds.min, [Math]::Min($bounds.max, $newValue))
    
    # Only recommend if change is meaningful
    if ([Math]::Abs($newValue - $currentValue) -lt 0.001) {
        return $null
    }
    
    return @{
        name = $ThresholdName
        current = $currentValue
        proposed = [Math]::Round($newValue, 4)
        reason = "Violation analysis: $($ViolationStats.perDay)/day, trend: $($ViolationStats.trend)"
    }
}

function Get-ComplianceRate {
    param([string]$CompliancePath)
    
    if (-not (Test-Path $CompliancePath)) {
        return $null
    }
    
    try {
        $compliance = Get-Content $CompliancePath | ConvertFrom-Json
        return $compliance.currentRate
    } catch {
        return $null
    }
}

# Main execution
Write-Host "=== Auto-Fix: Threshold Auto-Tuning ===" -ForegroundColor Cyan
Write-Host "Analysis Window: $AnalysisWindowDays days"
Write-Host ""

# Check auto-apply cap
if (-not (Test-AutoApplyCap -AutoApplyLogPath $AutoApplyLogPath)) {
    Write-Host "Exiting: Auto-apply cap reached for this week" -ForegroundColor Yellow
    exit 0
}

# Load current config
if (-not (Test-Path $ConfigPath)) {
    Write-Log "Config file not found: $ConfigPath" "ERROR"
    exit 1
}

try {
    $Config = Get-Content $ConfigPath | ConvertFrom-Json
} catch {
    Write-Log "Failed to parse config: $_" "ERROR"
    exit 1
}

Write-Host "Current configuration:" -ForegroundColor Cyan
if ($Config.analysisWindow) {
    Write-Host "  analysisWindow.days: $($Config.analysisWindow.days)"
    Write-Host "  analysisWindow.driftThreshold: $($Config.analysisWindow.driftThreshold)"
}
Write-Host ""

# Analyze violations
Write-Host "Analyzing violations (last $AnalysisWindowDays days)..."
$ViolationStats = Analyze-ViolationFrequency -ViolationsPath $ViolationsPath -WindowDays $AnalysisWindowDays
Write-Host "  Total: $($ViolationStats.total)"
Write-Host "  Per day: $($ViolationStats.perDay)"
Write-Host "  Trend: $($ViolationStats.trend)"
Write-Host ""

# Get compliance rate
$complianceRate = Get-ComplianceRate -CompliancePath $CompliancePath
if ($complianceRate) {
    Write-Host "Current compliance rate: $([Math]::Round($complianceRate * 100, 1))%"
    Write-Host ""
}

# Calculate optimal thresholds
$adjustments = @()

$thresholdsToCheck = @("analysisWindowDays", "driftThreshold", "complianceAlertThreshold")
foreach ($threshold in $thresholdsToCheck) {
    $currentConfig = @{
        analysisWindowDays = $Config.analysisWindow.days
        driftThreshold = $Config.analysisWindow.driftThreshold
        complianceAlertThreshold = 0.90 # Default
    }
    
    $recommendation = Calculate-OptimalThreshold -ThresholdName $threshold -CurrentConfig $currentConfig -ViolationStats $ViolationStats
    if ($recommendation) {
        $adjustments += $recommendation
    }
}

if ($adjustments.Count -eq 0) {
    Write-Host "No threshold adjustments recommended (current values optimal)" -ForegroundColor Green
    exit 0
}

Write-Host "`nRecommended adjustments:" -ForegroundColor Yellow
foreach ($adj in $adjustments) {
    Write-Host "  $($adj.name): $($adj.current) → $($adj.proposed)"
    Write-Host "    Reason: $($adj.reason)"
}
Write-Host ""

# Apply adjustments
foreach ($adj in $adjustments) {
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would update $($adj.name)" -ForegroundColor Yellow
        continue
    }
    
    # Apply to config
    try {
        if ($adj.name -eq "analysisWindowDays") {
            $Config.analysisWindow.days = $adj.proposed
        }
        elseif ($adj.name -eq "driftThreshold") {
            $Config.analysisWindow.driftThreshold = $adj.proposed
        }
        elseif ($adj.name -eq "complianceAlertThreshold") {
            # Store in config for alert script to use
            if (-not $Config.alerts) { $Config.alerts = @{} }
            $Config.alerts.complianceThreshold = $adj.proposed
        }
        
        $Config | ConvertTo-Json -Depth 10 | Set-Content $ConfigPath
        Write-Log "Updated $($adj.name) to $($adj.proposed)"
    } catch {
        Write-Log "Failed to update config: $_" "ERROR"
        continue
    }
    
    # Log to auto-apply.log
    try {
        $LogEntry = @{
            timestamp = (Get-Date -Format "o")
            action = "AUTO_TUNING_THRESHOLD"
            thresholdName = $adj.name
            oldValue = $adj.current
            newValue = $adj.proposed
            reason = $adj.reason
            violationStats = $ViolationStats
            rollback = "Set $($adj.name) back to $($adj.current) in governance/config.json"
            riskTier = "low"
        } | ConvertTo-Json -Compress
        
        $logDir = Split-Path $AutoApplyLogPath -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        
        Add-Content -Path $AutoApplyLogPath -Value $LogEntry
        Write-Log "Logged to auto-apply.log"
    } catch {
        Write-Log "Failed to log auto-apply: $_" "ERROR"
    }
}

Write-Host "`n=== Auto-Fix Complete ===" -ForegroundColor Cyan
Write-Host "Thresholds adjusted: $($adjustments.Count)"
