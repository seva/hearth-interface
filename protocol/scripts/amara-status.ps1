# Amara — Governance Sentinel Status Report
# Reports compliance health, violations, drift, and auto-fix quota

param(
    [switch]$Verbose,
    [switch]$Json,
    [string]$OutputPath = "$env:USERPROFILE\.openclaw\governance",
    [string]$WorkspaceRoot = "$env:USERPROFILE\.openclaw\workspace"
)

$ErrorActionPreference = "Stop"

# Ensure governance directory exists
if (!(Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
}

$violationsPath = Join-Path $OutputPath "violations.jsonl"
$compliancePath = Join-Path $OutputPath "compliance.json"

# ============================================================================
# Helper Functions
# ============================================================================

function Get-ComplianceData {
    if (Test-Path $compliancePath) {
        $data = Get-Content $compliancePath -Raw | ConvertFrom-Json
        
        # Handle both formats: new Amara format and legacy governance-analyzer format
        if ($data.metrics) {
            # Legacy format from governance-analyzer.ps1
            return [PSCustomObject]@{
                complianceRate = [Math]::Round($data.metrics.complianceRate * 100, 2)
                drift = [Math]::Round($data.metrics.driftPercentage * 100, 2)
                totalViolations = $data.metrics.totalViolations
                windowDays = $data.windowDays
                lastUpdated = $data.lastAnalysis
            }
        } else {
            # New Amara format
            return $data
        }
    }
    return [PSCustomObject]@{
        complianceRate = 0
        drift = 0
        totalViolations = 0
        windowDays = 7
        lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    }
}

function Get-RecentViolations {
    param([int]$Limit = 10)
    
    if (!(Test-Path $violationsPath)) {
        return @()
    }
    
    Get-Content $violationsPath -Tail $Limit | ForEach-Object {
        $_ | ConvertFrom-Json
    }
}

function Get-RecurringPatterns {
    param([int]$Threshold = 3)
    
    # Priority 1: Read from compliance.json patterns (has severity info)
    if (Test-Path $compliancePath) {
        $data = Get-Content $compliancePath -Raw | ConvertFrom-Json
        if ($data.patterns) {
            return $data.patterns | Where-Object { $_.Occurrences -ge $Threshold } | ForEach-Object {
                [PSCustomObject]@{
                    Type = $_.Pattern
                    Count = $_.Occurrences
                    Severity = $_.Severity
                    Recommendation = $_.Recommendation
                }
            } | Sort-Object -Property Count -Descending
        }
    }
    
    # Fallback: read from violations.jsonl
    if (!(Test-Path $violationsPath)) {
        return @()
    }
    
    $violations = Get-Content $violationsPath | ForEach-Object {
        $_ | ConvertFrom-Json
    }
    
    $grouped = $violations | Group-Object -Property type | Where-Object { $_.Count -ge $Threshold }
    
    $grouped | ForEach-Object {
        $sample = $_.Group[0]
        [PSCustomObject]@{
            Type = $_.Name
            Count = $_.Count
            Severity = $sample.severity
            LastOccurrence = $sample.timestamp
        }
    } | Sort-Object -Property Count -Descending
}

function Get-StatusLevel {
    param(
        [double]$ComplianceRate,
        [double]$Drift
    )
    
    if ($ComplianceRate -lt 50) {
        return "ACTION_REQUIRED"
    } elseif ($Drift -gt 10) {
        return "DRIFT_DETECTED"
    } elseif ($ComplianceRate -ge 80 -and $Drift -lt 10) {
        return "COMPLIANT"
    } else {
        return "DEGRADED"
    }
}

function Get-StatusEmoji {
    param([string]$Status)
    
    switch ($Status) {
        "COMPLIANT" { return "[OK]" }
        "DRIFT_DETECTED" { return "[!]" }
        "ACTION_REQUIRED" { return "[!!]" }
        "DEGRADED" { return "[!]" }
        default { return "[?]" }
    }
}

# ============================================================================
# Main Execution
# ============================================================================

$compliance = Get-ComplianceData
$recentViolations = Get-RecentViolations -Limit 5
$recurringPatterns = Get-RecurringPatterns -Threshold 3
$statusLevel = Get-StatusLevel -ComplianceRate $compliance.complianceRate -Drift $compliance.drift
$statusEmoji = Get-StatusEmoji -Status $statusLevel

# Determine auto-fix quota (estimate from proposals file)
$proposalsPath = Join-Path $OutputPath "proposals.jsonl"
$autoFixesApplied = 0
if (Test-Path $proposalsPath) {
    $proposals = Get-Content $proposalsPath | ForEach-Object {
        $_ | ConvertFrom-Json
    }
    $autoFixesApplied = ($proposals | Where-Object { $_.status -eq "applied" -and $_.appliedAt -gt (Get-Date).AddDays(-7) }).Count
}
$autoFixQuota = 5
$autoFixRemaining = [Math]::Max(0, $autoFixQuota - $autoFixesApplied)

# ============================================================================
# Output
# ============================================================================

if ($Json) {
    # JSON output for programmatic use
    $result = [PSCustomObject]@{
        status = $statusLevel
        complianceRate = $compliance.complianceRate
        drift = $compliance.drift
        totalViolations = $compliance.totalViolations
        windowDays = $compliance.windowDays
        recurringPatterns = $recurringPatterns.Count
        autoFixQuotaUsed = $autoFixesApplied
        autoFixQuotaRemaining = $autoFixRemaining
        lastUpdated = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
    }
    $result | ConvertTo-Json -Depth 10
} else {
    # Human-readable output
    Write-Host ""
    Write-Host "[Amara | Governance Sentinel]" -ForegroundColor Cyan
    Write-Host "Status: $statusLevel $statusEmoji" -ForegroundColor $(if ($statusLevel -eq "COMPLIANT") { "Green" } elseif ($statusLevel -eq "ACTION_REQUIRED") { "Red" } else { "Yellow" })
    Write-Host ""
    Write-Host "Compliance: $($compliance.complianceRate)% (target: 80%)" -ForegroundColor $(if ($compliance.complianceRate -ge 80) { "Green" } else { "Yellow" })
    Write-Host "Drift: $($compliance.drift)% (threshold: 10%)" -ForegroundColor $(if ($compliance.drift -lt 10) { "Green" } else { "Red" })
    Write-Host "Violations (7d): $($compliance.totalViolations)"
    Write-Host ""
    
    if ($recurringPatterns.Count -gt 0) {
        Write-Host "Recurring Patterns:" -ForegroundColor Yellow
        foreach ($pattern in $recurringPatterns) {
            $severityColor = if ($pattern.Severity -eq "high") { "Red" } elseif ($pattern.Severity -eq "medium") { "Yellow" } elseif ($pattern.Severity -eq "low") { "Gray" } else { "Gray" }
            $severityDisplay = if ($pattern.Severity) { $pattern.Severity } else { "unknown" }
            Write-Host "  - $($pattern.Type) ($($pattern.Count)x, $severityDisplay)" -ForegroundColor $severityColor
        }
    }
    
    Write-Host "Auto-Fix Quota: $autoFixesApplied/$autoFixQuota used this week" -ForegroundColor $(if ($autoFixRemaining -gt 0) { "Green" } else { "Red" })
    
    if ($Verbose -and $recentViolations.Count -gt 0) {
        Write-Host ""
        Write-Host "Recent Violations:" -ForegroundColor Cyan
        foreach ($v in $recentViolations) {
            $recoveredStatus = if ($v.recovered) { "[OK]" } else { "[!]" }
            Write-Host "  [$($v.timestamp)] $($v.type) $recoveredStatus" -ForegroundColor Gray
        }
    }
    
    # Recommendations
    if ($statusLevel -eq "DRIFT_DETECTED" -or $statusLevel -eq "ACTION_REQUIRED") {
        Write-Host ""
        Write-Host "Recommendation:" -ForegroundColor Cyan
        if ($recurringPatterns.Count -gt 0) {
            $topPattern = $recurringPatterns[0]
            Write-Host "  Review auto-fix proposal for $($topPattern.Type) pattern" -ForegroundColor Yellow
        } else {
            Write-Host "  Run governance-analyzer.ps1 -GenerateProposals to create fix proposals" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Next Review: $((Get-Date).AddDays(7).ToString('MMMM dd'))" -ForegroundColor Gray
    Write-Host ""
}

exit 0
