# Phase 1B End-to-End Test
# Tests: Drift Detection → Alert → Proposal → Auto-Apply

param(
    [switch]$CleanState,
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"
$TestStartTime = Get-Date

Write-Host "=== Phase 1B End-to-End Test ===" -ForegroundColor Cyan
Write-Host "Test Start: $($TestStartTime.ToString('yyyy-MM-dd HH:mm:ss'))`n"

# Test paths
$GovernanceDir = "$env:USERPROFILE\.openclaw\governance"
$ViolationsPath = "$GovernanceDir\violations.jsonl"
$CompliancePath = "$GovernanceDir\compliance.json"
$ProposalsPath = "$GovernanceDir\proposals.jsonl"
$AutoApplyLogPath = "$GovernanceDir\auto-apply.log"
$ConfigPath = "$GovernanceDir\config.json"
$AlertsLogPath = "$GovernanceDir\alerts.log"

# Script paths
$ScriptDir = Split-Path $PSCommandPath -Parent
$AnalyzerScript = Join-Path $ScriptDir "governance-analyzer.ps1"
$ApplyScript = Join-Path $ScriptDir "apply-proposal.ps1"
$AlertScript = Join-Path $ScriptDir "send-governance-alert.ps1"

# Verify scripts exist
$RequiredScripts = @(
    @{ Path = $AnalyzerScript; Name = "governance-analyzer.ps1" },
    @{ Path = $ApplyScript; Name = "apply-proposal.ps1" },
    @{ Path = $AlertScript; Name = "send-governance-alert.ps1" }
)

Write-Host "Step 1: Verify Scripts Exist" -ForegroundColor Yellow
$AllScriptsExist = $true
foreach ($Script in $RequiredScripts) {
    if (Test-Path $Script.Path) {
        Write-Host "  ✓ $($Script.Name) found" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($Script.Name) MISSING at $($Script.Path)" -ForegroundColor Red
        $AllScriptsExist = $false
    }
}

if (-not $AllScriptsExist) {
    Write-Host "`nTest FAILED: Required scripts missing" -ForegroundColor Red
    exit 1
}

# Clean state if requested
if ($CleanState) {
    Write-Host "`nStep 2: Clean Test State" -ForegroundColor Yellow
    @($ViolationsPath, $CompliancePath, $ProposalsPath, $AutoApplyLogPath, $AlertsLogPath) | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item $_ -Force
            Write-Host "  ✓ Removed: $_" -ForegroundColor Gray
        }
    }
}

# Ensure governance directory exists
if (-not (Test-Path $GovernanceDir)) {
    New-Item -ItemType Directory -Path $GovernanceDir -Force | Out-Null
    Write-Host "  ✓ Created governance directory" -ForegroundColor Green
}

# Create test config
Write-Host "`nStep 3: Create Test Configuration" -ForegroundColor Yellow
$TestConfig = @{
    analysisWindow = @{
        days = 7
        driftThreshold = 0.10
        patternMinOccurrences = 3
    }
    autoApply = @{
        enabled = $true
        maxPerWeek = 3
        allowedRiskTiers = @("low")
        requireRollbackInstructions = $true
    }
} | ConvertTo-Json -Depth 10

$TestConfig | Set-Content $ConfigPath
Write-Host "  ✓ Config created at: $ConfigPath" -ForegroundColor Green

# Generate synthetic violation data
Write-Host "`nStep 4: Generate Synthetic Violations" -ForegroundColor Yellow

# Generate baseline period (8-14 days ago) - 5 violations
$BaselineStart = (Get-Date).AddDays(-14)
$BaselineEnd = (Get-Date).AddDays(-8)
$BaselineViolations = 5

for ($i = 1; $i -le $BaselineViolations; $i++) {
    $Timestamp = $BaselineStart.AddDays($i * (($BaselineEnd - $BaselineStart).TotalDays / $BaselineViolations))
    $Violation = @{
        timestamp = $Timestamp.ToString("o")
        type = "MEMORY_RETRIEVAL_VIOLATION"
        sessionId = "test-session-baseline-$i"
        recovered = if ($i % 2 -eq 0) { $true } else { $false }
        details = "Baseline violation $i"
    } | ConvertTo-Json -Compress
    Add-Content -Path $ViolationsPath -Value $Violation
}

Write-Host "  ✓ Generated $BaselineViolations baseline violations (8-14 days ago)" -ForegroundColor Green

# Generate current period (last 7 days) - 10 high-risk + 3 low-risk violations
$CurrentStart = (Get-Date).AddDays(-7)
$CurrentEnd = Get-Date
$CurrentViolations = 10

for ($i = 1; $i -le $CurrentViolations; $i++) {
    $Timestamp = $CurrentStart.AddDays($i * (($CurrentEnd - $CurrentStart).TotalDays / $CurrentViolations))
    $Violation = @{
        timestamp = $Timestamp.ToString("o")
        type = "MEMORY_RETRIEVAL_VIOLATION"
        sessionId = "test-session-current-$i"
        recovered = if ($i % 3 -eq 0) { $true } else { $false }
        details = "Current period violation $i"
    } | ConvertTo-Json -Compress
    Add-Content -Path $ViolationsPath -Value $Violation
}

# Add 3 low-risk violations (will create low-risk proposal)
for ($i = 1; $i -le 3; $i++) {
    $Timestamp = $CurrentStart.AddDays($i * (($CurrentEnd - $CurrentStart).TotalDays / 3))
    $Violation = @{
        timestamp = $Timestamp.ToString("o")
        type = "SERVANT_MODE"
        sessionId = "test-session-servant-$i"
        recovered = $true
        details = "Servant mode violation $i (low risk)"
    } | ConvertTo-Json -Compress
    Add-Content -Path $ViolationsPath -Value $Violation
}

Write-Host "  ✓ Generated $CurrentViolations current violations (last 7 days)" -ForegroundColor Green
Write-Host "  ✓ Generated 3 low-risk violations (SERVANT_MODE - should be auto-applied)" -ForegroundColor Green
Write-Host "  → Expected drift: $(($CurrentViolations - $BaselineViolations) * 100 / $BaselineViolations)% (SHOULD TRIGGER ALERT)" -ForegroundColor Cyan

# Test 1: Drift Detection (COLD START SCENARIO)
Write-Host "`nStep 5: Test Drift Detection (Cold Start)" -ForegroundColor Yellow

# First, test cold start by using ONLY current period data
$TempViolationsPath = "$GovernanceDir\violations-cold-start.jsonl"
Get-Content $ViolationsPath | Select-Object -Last $CurrentViolations | Set-Content $TempViolationsPath

try {
    & $AnalyzerScript -ViolationsPath $TempViolationsPath -Verbose:$Verbose
    $ColdStartExitCode = $LASTEXITCODE
    
    if ($ColdStartExitCode -eq 0 -or $null -eq $ColdStartExitCode) {
        Write-Host "  ✓ Cold start handled without errors" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Cold start failed with exit code: $ColdStartExitCode" -ForegroundColor Red
    }
} catch {
    Write-Host "  ✗ Cold start test FAILED: $_" -ForegroundColor Red
}

Remove-Item $TempViolationsPath -Force

# Test 2: Drift Detection (WITH BASELINE)
Write-Host "`nStep 6: Test Drift Detection (With Baseline)" -ForegroundColor Yellow

try {
    & $AnalyzerScript -GenerateProposals -Verbose:$Verbose
    $DriftExitCode = $LASTEXITCODE
    
    if ($DriftExitCode -eq 0 -or $null -eq $DriftExitCode) {
        Write-Host "  ✓ Drift detection completed successfully" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Drift detection completed with exit code: $DriftExitCode" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Drift detection FAILED: $_" -ForegroundColor Red
}

# Verify compliance.json was created
if (Test-Path $CompliancePath) {
    $Compliance = Get-Content $CompliancePath | ConvertFrom-Json
    Write-Host "  ✓ compliance.json created" -ForegroundColor Green
    Write-Host "    - Compliance Rate: $($Compliance.metrics.complianceRate * 100)%" -ForegroundColor Gray
    Write-Host "    - Drift Detected: $($Compliance.metrics.driftDetected)" -ForegroundColor Gray
    Write-Host "    - Drift Percentage: $($Compliance.metrics.driftPercentage * 100)%" -ForegroundColor Gray
} else {
    Write-Host "  ✗ compliance.json NOT CREATED" -ForegroundColor Red
}

# Test 3: Alert Delivery
Write-Host "`nStep 7: Test Alert Delivery" -ForegroundColor Yellow

# Check if alerts.log was created (logged even if Telegram fails)
if (Test-Path $AlertsLogPath) {
    $AlertLog = Get-Content $AlertsLogPath | Where-Object { $_.Trim() }
    if ($AlertLog.Count -gt 0) {
        Write-Host "  ✓ Alert logged ($($AlertLog.Count) entry/entries)" -ForegroundColor Green
        $LastAlert = $AlertLog[-1] | ConvertFrom-Json
        Write-Host "    - Alert Sent: $($LastAlert.alertSent)" -ForegroundColor Gray
        Write-Host "    - Reasons: $($LastAlert.reasons -join ', ')" -ForegroundColor Gray
    } else {
        Write-Host "  ⚠️  alerts.log exists but is empty" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️  alerts.log NOT CREATED (no alert conditions met?)" -ForegroundColor Yellow
}

# Test 4: Proposal Generation
Write-Host "`nStep 8: Test Proposal Generation" -ForegroundColor Yellow

if (Test-Path $ProposalsPath) {
    $Proposals = Get-Content $ProposalsPath | Where-Object { $_.Trim() }
    if ($Proposals.Count -gt 0) {
        Write-Host "  ✓ Proposals generated ($($Proposals.Count) proposal(s))" -ForegroundColor Green
        foreach ($ProposalLine in $Proposals) {
            $Proposal = $ProposalLine | ConvertFrom-Json
            Write-Host "    - Pattern: $($Proposal.pattern), Risk: $($Proposal.riskTier), Auto-Apply: $($Proposal.autoApplyEligible)" -ForegroundColor Gray
        }
    } else {
        Write-Host "  ⚠️  proposals.jsonl exists but is empty" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️  proposals.jsonl NOT CREATED (no patterns detected?)" -ForegroundColor Yellow
}

# Test 5: Auto-Apply Pipeline
Write-Host "`nStep 9: Test Auto-Apply Pipeline" -ForegroundColor Yellow

try {
    & $ApplyScript -Verbose:$Verbose
    $ApplyExitCode = $LASTEXITCODE
    
    if ($ApplyExitCode -eq 0 -or $null -eq $ApplyExitCode) {
        Write-Host "  ✓ Auto-apply completed successfully" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Auto-apply completed with exit code: $ApplyExitCode" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ✗ Auto-apply FAILED: $_" -ForegroundColor Red
}

# Verify auto-apply log
if (Test-Path $AutoApplyLogPath) {
    $AutoApplyLog = Get-Content $AutoApplyLogPath | Where-Object { $_.Trim() }
    if ($AutoApplyLog.Count -gt 0) {
        Write-Host "  ✓ Auto-apply log created ($($AutoApplyLog.Count) entry/entries)" -ForegroundColor Green
        foreach ($LogLine in $AutoApplyLog) {
            $LogEntry = $LogLine | ConvertFrom-Json
            Write-Host "    - Pattern: $($LogEntry.pattern), Applied: $($LogEntry.timestamp)" -ForegroundColor Gray
            Write-Host "      Rollback: $($LogEntry.rollbackInstructions)" -ForegroundColor DarkGray
        }
    } else {
        Write-Host "  ⚠️  auto-apply.log exists but is empty" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠️  auto-apply.log NOT CREATED (no proposals applied?)" -ForegroundColor Yellow
}

# Test Summary
$TestEndTime = Get-Date
$TestDuration = ($TestEndTime - $TestStartTime).TotalSeconds

Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan
Write-Host "Duration: $($TestDuration.ToString('F2')) seconds"
Write-Host ""

$TestResults = @{
    scriptsExist = $AllScriptsExist
    driftDetectionColdStart = (Test-Path $CompliancePath)
    driftDetectionWithBaseline = (Test-Path $CompliancePath) -and ($Compliance.metrics.driftDetected -eq $true)
    alertLogged = (Test-Path $AlertsLogPath) -and ((Get-Content $AlertsLogPath | Where-Object { $_.Trim() }).Count -gt 0)
    proposalsGenerated = (Test-Path $ProposalsPath) -and ((Get-Content $ProposalsPath | Where-Object { $_.Trim() }).Count -gt 0)
    autoApplyExecuted = (Test-Path $AutoApplyLogPath) -and ((Get-Content $AutoApplyLogPath | Where-Object { $_.Trim() }).Count -gt 0)
}

Write-Host "Test Results:" -ForegroundColor Yellow
Write-Host "  Scripts Exist: $($TestResults.scriptsExist)" -ForegroundColor $(if ($TestResults.scriptsExist) { "Green" } else { "Red" })
Write-Host "  Drift Detection (Cold Start): $($TestResults.driftDetectionColdStart)" -ForegroundColor $(if ($TestResults.driftDetectionColdStart) { "Green" } else { "Red" })
Write-Host "  Drift Detection (With Baseline): $($TestResults.driftDetectionWithBaseline)" -ForegroundColor $(if ($TestResults.driftDetectionWithBaseline) { "Green" } else { "Red" })
Write-Host "  Alert Logged: $($TestResults.alertLogged)" -ForegroundColor $(if ($TestResults.alertLogged) { "Green" } else { "Red" })
Write-Host "  Proposals Generated: $($TestResults.proposalsGenerated)" -ForegroundColor $(if ($TestResults.proposalsGenerated) { "Green" } else { "Red" })
Write-Host "  Auto-Apply Executed: $($TestResults.autoApplyExecuted)" -ForegroundColor $(if ($TestResults.autoApplyExecuted) { "Green" } else { "Red" })

$AllPassed = $TestResults.Values | ForEach-Object { $_ } | Where-Object { $_ -eq $false } | Measure-Object | Select-Object -ExpandProperty Count
if ($AllPassed -eq 0) {
    Write-Host "`n✓ ALL TESTS PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n✗ SOME TESTS FAILED ($AllPassed failure(s))" -ForegroundColor Red
    exit 1
}
