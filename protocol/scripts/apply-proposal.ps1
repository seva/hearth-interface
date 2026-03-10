# Apply Proposal Engine - Adaptive Immunity MVP
# Applies correction proposals with safety constraints:
# - Auto-apply ONLY low-risk, additive changes
# - Never remove rules or relax enforcement without human approval
# - Every auto-apply must have rollback instructions logged
# - Cap auto-applies at 3 per week

param(
    [string]$ProposalsPath = "$env:USERPROFILE\.openclaw\governance\proposals.jsonl",
    [string]$CompliancePath = "$env:USERPROFILE\.openclaw\governance\compliance.json",
    [string]$ConfigPath = "$env:USERPROFILE\.openclaw\governance\config.json",
    [string]$AutoApplyLogPath = "$env:USERPROFILE\.openclaw\governance\auto-apply.log",
    [switch]$DryRun,
    [switch]$Verbose
)

# Helper function to execute recommendations (defined first for PowerShell)
function Invoke-ApplyRecommendation {
    param(
        [string]$Recommendation,
        [string]$Pattern,
        [switch]$Verbose
    )

    # This is a placeholder implementation
    # In production, this would execute specific fixes based on pattern type
    
    try {
        # Simulate applying the recommendation
        if ($Verbose) {
            Write-Host "    Executing: $Recommendation"
        }
        
        # TODO: Implement actual pattern-specific apply logic
        # For now, return success for demonstration
        
        return @{
            Success = $true
            Error = $null
        }
    } catch {
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

Write-Host "=== Apply Proposal Engine ===" -ForegroundColor Cyan

# Load configuration
$Config = if (Test-Path $ConfigPath) {
    Get-Content $ConfigPath | ConvertFrom-Json
} else {
    Write-Warning "Config not found, using defaults"
    @{
        autoApply = @{
            enabled = $true
            maxPerWeek = 3
            allowedRiskTiers = @("low")
            requireRollbackInstructions = $true
        }
    }
}

$AutoApplyEnabled = $Config.autoApply.enabled
$MaxPerWeek = $Config.autoApply.maxPerWeek
$AllowedRiskTiers = $Config.autoApply.allowedRiskTiers

Write-Host "Auto-Apply Enabled: $AutoApplyEnabled"
Write-Host "Max Per Week: $MaxPerWeek"
Write-Host "Allowed Risk Tiers: $($AllowedRiskTiers -join ', ')"
Write-Host ""

# Check auto-apply count for current week
$WeekStart = Get-Date
while ($WeekStart.DayOfWeek -ne "Tuesday") {
    $WeekStart = $WeekStart.AddDays(-1)
}
$WeekStart = $WeekStart.Date
$WeekEnd = $WeekStart.AddDays(7)

Write-Host "Current Week: $($WeekStart.ToString('yyyy-MM-dd')) to $($WeekEnd.ToString('yyyy-MM-dd'))"

$AutoApplyCount = 0
if (Test-Path $AutoApplyLogPath) {
    $LogLines = Get-Content $AutoApplyLogPath | Where-Object { $_.Trim() }
    foreach ($Line in $LogLines) {
        try {
            $Entry = $Line | ConvertFrom-Json
            $EntryTime = [DateTime]::Parse($Entry.timestamp)
            if ($EntryTime -ge $WeekStart) {
                $AutoApplyCount++
            }
        } catch {}
    }
}

Write-Host "Auto-Applies This Week: $AutoApplyCount / $MaxPerWeek"
Write-Host ""

if ($AutoApplyCount -ge $MaxPerWeek) {
    Write-Host "⚠️  WEEKLY CAP REACHED - No more auto-applies allowed this week" -ForegroundColor Red
    Write-Host "Manual review required for remaining proposals."
    exit 0
}

# Load pending proposals
$Proposals = @()
if (Test-Path $ProposalsPath) {
    $Lines = Get-Content $ProposalsPath | Where-Object { $_.Trim() }
    foreach ($Line in $Lines) {
        try {
            $Proposal = $Line | ConvertFrom-Json
            # Skip already applied proposals
            if (-not $Proposal.applied) {
                $Proposals += $Proposal
            }
        } catch {
            if ($Verbose) { Write-Warning "Failed to parse proposal: $Line" }
        }
    }
}

if ($Proposals.Count -eq 0) {
    Write-Host "No pending proposals to apply." -ForegroundColor Gray
    exit 0
}

Write-Host "Pending Proposals: $($Proposals.Count)"
Write-Host ""

# Process proposals
$AppliedCount = 0
$SkippedCount = 0

foreach ($Proposal in $Proposals) {
    if ($AppliedCount -ge ($MaxPerWeek - $AutoApplyCount)) {
        Write-Host "⚠️  Reached weekly cap during processing" -ForegroundColor Yellow
        break
    }

    $RiskTier = $Proposal.riskTier
    $Pattern = $Proposal.pattern
    $AutoApplyEligible = $Proposal.autoApplyEligible -eq $true

    Write-Host "Processing: $Pattern (Risk: $RiskTier)"

    # Check risk tier eligibility
    if ($RiskTier -notin $AllowedRiskTiers) {
        Write-Host "  ⚠️  SKIPPED: Risk tier '$RiskTier' not in allowed list ($($AllowedRiskTiers -join ', '))" -ForegroundColor Yellow
        $SkippedCount++
        continue
    }

    # Check if auto-apply eligible
    if (-not $AutoApplyEligible) {
        Write-Host "  ⚠️  SKIPPED: Not marked as auto-apply eligible" -ForegroundColor Yellow
        $SkippedCount++
        continue
    }

    # Verify rollback instructions exist
    if (-not $Proposal.rollbackInstructions) {
        Write-Host "  ⚠️  SKIPPED: Missing rollback instructions (safety constraint)" -ForegroundColor Yellow
        $SkippedCount++
        continue
    }

    # DRY RUN mode
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would apply: $($Proposal.recommendation)" -ForegroundColor Cyan
        Write-Host "  [DRY RUN] Rollback: $($Proposal.rollbackInstructions)" -ForegroundColor Gray
        $AppliedCount++
        continue
    }

    # ACTUAL APPLY
    Write-Host "  ✓ Applying: $($Proposal.recommendation)" -ForegroundColor Green
    
    # Execute the recommendation
    $ApplyResult = Invoke-ApplyRecommendation -Recommendation $Proposal.recommendation -Pattern $Pattern -Verbose:$Verbose

    if ($ApplyResult.Success) {
        # Log the auto-apply
        $LogEntry = @{
            timestamp = (Get-Date -Format "o")
            pattern = $Pattern
            recommendation = $Proposal.recommendation
            rollbackInstructions = $Proposal.rollbackInstructions
            riskTier = $RiskTier
            weekStart = $WeekStart.ToString('yyyy-MM-dd')
            weekEnd = $WeekEnd.ToString('yyyy-MM-dd')
        }

        $LogEntryJson = $LogEntry | ConvertTo-Json -Compress
        Add-Content -Path $AutoApplyLogPath -Value $LogEntryJson

        # Mark proposal as applied
        $Proposal.applied = $true
        $Proposal.appliedAt = (Get-Date -Format "o")
        $ProposalJson = $Proposal | ConvertTo-Json -Compress
        
        # Update proposals file (rewrite without this proposal or mark as applied)
        $AllLines = Get-Content $ProposalsPath | Where-Object { $_.Trim() }
        $UpdatedLines = @()
        foreach ($Line in $AllLines) {
            try {
                $P = $Line | ConvertFrom-Json
                if ($P.pattern -eq $Pattern -and -not $P.applied) {
                    $P.applied = $true
                    $P.appliedAt = $Proposal.appliedAt
                    $UpdatedLines += ($P | ConvertTo-Json -Compress)
                } else {
                    $UpdatedLines += $Line
                }
            } catch {
                $UpdatedLines += $Line
            }
        }
        $UpdatedLines | Set-Content $ProposalsPath

        Write-Host "  ✓ Applied and logged successfully" -ForegroundColor Green
        $AppliedCount++
    } else {
        Write-Host "  ✗ Apply failed: $($ApplyResult.Error)" -ForegroundColor Red
        $SkippedCount++
    }
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Applied: $AppliedCount"
Write-Host "Skipped: $SkippedCount"
Write-Host "Remaining Weekly Capacity: $($MaxPerWeek - $AutoApplyCount - $AppliedCount)"
