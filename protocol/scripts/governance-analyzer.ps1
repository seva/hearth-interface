# Governance Analyzer - Adaptive Immunity MVP
# Parses violations.jsonl, computes 7-day compliance metrics, detects drift, identifies patterns

param(
    [string]$ViolationsPath = "$env:USERPROFILE\.openclaw\governance\violations.jsonl",
    [string]$CompliancePath = "$env:USERPROFILE\.openclaw\governance\compliance.json",
    [string]$ProposalsPath = "$env:USERPROFILE\.openclaw\governance\proposals.jsonl",
    [string]$ConfigPath = "$env:USERPROFILE\.openclaw\governance\config.json",
    [switch]$GenerateProposals,
    [switch]$Verbose
)

# Helper function for pattern recommendations (DEFINED FIRST)
function Get-PatternRecommendation {
    param([string]$Type)
    
    switch ($Type) {
        "MEMORY_RETRIEVAL_VIOLATION" { return "Add automatic memory_search() call before write operations to memory/ files" }
        "MEMORY_RETRIEVAL_RECOVERY" { return "Consider lowering retrieval threshold or expanding valid query patterns" }
        "MESSAGE_VIOLATION" { return "Update signature injection or servant-mode pattern list" }
        "SERVANT_MODE" { return "Review and expand servant-mode pattern blacklist" }
        "BOOT_SEQUENCE_INCOMPLETE" { return "Strengthen boot sequence detection or add reminder notifications" }
        "IDLE_WATCHDOG_STALE" { return "Reduce stale limit or add proactive §4 reminders" }
        "IDLE_WATCHDOG_RECOVERY" { return "Consider more aggressive §4 auto-execution" }
        default { return "Review violation context and consider threshold adjustment" }
    }
}

# Telegram alert function - delegates to send-governance-alert.ps1 (DEFINED FIRST)
function Send-GovernanceAlert {
    param(
        [string[]]$AlertReasons,
        [double]$ComplianceRate,
        [bool]$DriftDetected,
        [double]$DriftPercentage,
        [int]$TotalViolations,
        [string]$ConfigPath
    )
    
    $ScriptDir = Split-Path $PSCommandPath -Parent
    $AlertScript = Join-Path $ScriptDir "send-governance-alert.ps1"
    
    if (-not (Test-Path $AlertScript)) {
        Write-Host "  ⚠️  Alert script not found: $AlertScript" -ForegroundColor Yellow
        return
    }
    
    # Build args for alert script
    $ReasonArgs = $AlertReasons | ForEach-Object { "'$_'" }
    $ReasonArrayStr = "@($($ReasonArgs -join ', '))"
    
    & $AlertScript `
        -AlertReasons $AlertReasons `
        -ComplianceRate $ComplianceRate `
        -DriftDetected $DriftDetected `
        -DriftPercentage $DriftPercentage `
        -TotalViolations $TotalViolations `
        -ConfigPath $ConfigPath
}

# Load configuration
$Config = if (Test-Path $ConfigPath) {
    Get-Content $ConfigPath | ConvertFrom-Json
} else {
    @{
        analysisWindow = @{
            days = 7
            driftThreshold = 0.10
            patternMinOccurrences = 3
        }
        autoApply = @{
            enabled = $true
            maxPerWeek = 3
            allowedRiskTiers = @("low")
        }
    }
}

$Days = $Config.analysisWindow.days
$DriftThreshold = $Config.analysisWindow.driftThreshold
$PatternMinOccurrences = $Config.analysisWindow.patternMinOccurrences

Write-Host "=== Governance Analyzer ===" -ForegroundColor Cyan
Write-Host "Analysis Window: $Days days"
Write-Host "Drift Threshold: $($DriftThreshold * 100)%"
Write-Host "Pattern Min Occurrences: $PatternMinOccurrences"
Write-Host ""

# Calculate date range
$EndDate = Get-Date
$StartDate = $EndDate.AddDays(-$Days)

Write-Host "Date Range: $($StartDate.ToString('yyyy-MM-dd')) to $($EndDate.ToString('yyyy-MM-dd'))"
Write-Host ""

# Parse violations.jsonl
$Violations = @()
if (Test-Path $ViolationsPath) {
    $Lines = Get-Content $ViolationsPath | Where-Object { $_.Trim() }
    foreach ($Line in $Lines) {
        try {
            $Violation = $Line | ConvertFrom-Json
            $ViolationTime = [DateTime]::Parse($Violation.timestamp)
            if ($ViolationTime -ge $StartDate) {
                $Violations += $Violation
            }
        } catch {
            if ($Verbose) { Write-Warning "Failed to parse line: $Line" }
        }
    }
}

$TotalViolations = $Violations.Count
Write-Host "Total Violations (last $Days days): $TotalViolations"

# Group by type
$ViolationsByType = $Violations | Group-Object -Property type | ForEach-Object {
    @{
        Type = $_.Name
        Count = $_.Count
        Recovered = ($_.Group | Where-Object { $_.recovered -eq $true }).Count
        Blocked = ($_.Group | Where-Object { $_.recovered -eq $false }).Count
    }
}

Write-Host "`nViolations by Type:" -ForegroundColor Yellow
foreach ($V in $ViolationsByType) {
    $Recovered = if ($V.Recovered) { $V.Recovered } else { 0 }
    $Blocked = if ($V.Blocked) { $V.Blocked } else { 0 }
    $RecoveryRate = if ($V.Count -gt 0) { ($Recovered / $V.Count * 100).ToString("F1") } else { "0.0" }
    Write-Host "  $($V.Type): $($V.Count) (Recovered: $Recovered, Blocked: $Blocked, Recovery Rate: $RecoveryRate%)"
}

# Calculate compliance rate (recovered / total)
$TotalRecovered = ($Violations | Where-Object { $_.recovered -eq $true }).Count
$ComplianceRate = if ($TotalViolations -gt 0) { $TotalRecovered / $TotalViolations } else { 1.0 }
Write-Host "`nCompliance Rate: $($ComplianceRate.ToString("P2"))" -ForegroundColor $(if ($ComplianceRate -ge 0.9) { "Green" } elseif ($ComplianceRate -ge 0.7) { "Yellow" } else { "Red" })

# Detect drift (compare to previous period)
$PreviousStartDate = $StartDate.AddDays(-$Days)
$PreviousViolations = @()
if (Test-Path $ViolationsPath) {
    $Lines = Get-Content $ViolationsPath | Where-Object { $_.Trim() }
    foreach ($Line in $Lines) {
        try {
            $Violation = $Line | ConvertFrom-Json
            $ViolationTime = [DateTime]::Parse($Violation.timestamp)
            if ($ViolationTime -ge $PreviousStartDate -and $ViolationTime -lt $StartDate) {
                $PreviousViolations += $Violation
            }
        } catch {}
    }
}

$PreviousTotal = $PreviousViolations.Count

# COLD-START FIX: Handle case where no previous period data exists
if ($PreviousTotal -eq 0) {
    Write-Host "`nDrift Analysis:" -ForegroundColor Yellow
    Write-Host "  Previous Period Violations: $PreviousTotal (COLD START - no historical data)"
    Write-Host "  Current Period Violations: $TotalViolations"
    Write-Host "  Drift: N/A (cannot calculate without baseline)"
    Write-Host "  Drift Detected: false (skipped due to cold start)"
    $DriftPercentage = 0
    $DriftDetected = $false
    $ColdStart = $true
} else {
    $DriftPercentage = ($TotalViolations - $PreviousTotal) / $PreviousTotal
    $DriftDetected = $DriftPercentage -gt $DriftThreshold
    $ColdStart = $false
    
    Write-Host "`nDrift Analysis:" -ForegroundColor $(if ($DriftDetected) { "Red" } else { "Green" })
    Write-Host "  Previous Period Violations: $PreviousTotal"
    Write-Host "  Current Period Violations: $TotalViolations"
    Write-Host "  Drift: $($DriftPercentage.ToString("P2"))"
    Write-Host "  Drift Detected: $DriftDetected (threshold: $($DriftThreshold * 100)%)"
}

# Check if alerts need to be sent (AFTER drift detection)
$AlertNeeded = $false
$AlertReasons = @()

if ($DriftDetected) {
    $AlertNeeded = $true
    $AlertReasons += "Drift detected: $($DriftPercentage.ToString("P2")) increase week-over-week"
}

if ($ComplianceRate -lt 0.90) {
    $AlertNeeded = $true
    $AlertReasons += "Compliance rate below 90%: $($ComplianceRate.ToString("P2"))"
}

if ($AlertNeeded) {
    Write-Host "`n⚠️  ALERT CONDITIONS MET" -ForegroundColor Red
    foreach ($Reason in $AlertReasons) {
        Write-Host "  - $Reason" -ForegroundColor Yellow
    }
    
    # Send Telegram alert
    Send-GovernanceAlert -AlertReasons $AlertReasons -ComplianceRate $ComplianceRate -DriftDetected $DriftDetected -DriftPercentage $DriftPercentage -TotalViolations $TotalViolations -ConfigPath $ConfigPath
}

# Identify recurring patterns (3+ occurrences)
$Patterns = @()
$MatchingPatterns = $ViolationsByType | Where-Object { $_.Count -ge $PatternMinOccurrences }
if ($MatchingPatterns) {
    $Patterns = $MatchingPatterns | ForEach-Object {
        @{
            Pattern = $_.Type
            Occurrences = $_.Count
            Severity = if ($_.Count -ge 10) { "high" } elseif ($_.Count -ge 5) { "medium" } else { "low" }
            Recommendation = Get-PatternRecommendation -Type $_.Type
        }
    }
}

Write-Host "`nRecurring Patterns (>= $PatternMinOccurrences occurrences):" -ForegroundColor Cyan
if ($Patterns.Count -eq 0) {
    Write-Host "  No recurring patterns detected" -ForegroundColor Gray
} else {
    foreach ($P in $Patterns) {
        Write-Host "  $($P.Pattern): $($P.Occurrences) occurrences (Severity: $($P.Severity))"
        Write-Host "    Recommendation: $($P.Recommendation)" -ForegroundColor Gray
    }
}

# Generate compliance.json
$ViolationsByTypeDict = @{}
foreach ($V in $ViolationsByType) {
    $ViolationsByTypeDict[$V.Type] = $V.Count
}

$ComplianceReport = @{
    generatedAt = (Get-Date -Format "o")
    windowDays = $Days
    metrics = @{
        totalViolations = $TotalViolations
        violationsByType = $ViolationsByTypeDict
        complianceRate = [math]::Round($ComplianceRate, 4)
        driftDetected = $DriftDetected
        driftPercentage = [math]::Round($DriftPercentage, 4)
    }
    patterns = $Patterns
    lastAnalysis = (Get-Date -Format "o")
}

$ComplianceReport | ConvertTo-Json -Depth 10 | Set-Content $CompliancePath
Write-Host "`nCompliance report saved to: $CompliancePath" -ForegroundColor Green

# Generate proposals if requested
if ($GenerateProposals -and $Patterns.Count -gt 0) {
    Write-Host "`nGenerating correction proposals..." -ForegroundColor Cyan
    
    foreach ($Pattern in $Patterns) {
        $Proposal = @{
            timestamp = (Get-Date -Format "o")
            pattern = $Pattern.Pattern
            occurrences = $Pattern.Occurrences
            riskTier = $Pattern.Severity
            recommendation = $Pattern.Recommendation
            autoApplyEligible = ($Pattern.Severity -eq "low")
            rollbackInstructions = "Revert any configuration changes related to $($Pattern.Pattern)"
        }
        
        $ProposalJson = $Proposal | ConvertTo-Json -Compress
        Add-Content -Path $ProposalsPath -Value $ProposalJson
        
        Write-Host "  Proposal created: $($Pattern.Pattern) (Risk: $($Pattern.Severity))"
    }
    
    Write-Host "Proposals saved to: $ProposalsPath" -ForegroundColor Green
}

Write-Host "`n=== Analysis Complete ===" -ForegroundColor Cyan
