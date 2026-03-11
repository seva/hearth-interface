# Auto-Fix: Servant-Mode Pattern Auto-Expand
# Detects new servant-mode phrases appearing 3+ times in violations
# Auto-adds them to servantModePatterns config (low-risk, additive change)
#
# Parent Epic: #114 (Phase 2: Pattern-Specific Auto-Fixes)
# Risk Tier: Low
# Cap: Counts toward 3/week auto-apply limit

param(
    [string]$ViolationsPath = "$env:USERPROFILE\.openclaw\governance\violations.jsonl",
    [string]$ConfigPath = "$env:USERPROFILE\.openclaw\governance\config.json",
    [string]$OpenClawConfigPath = "$env:USERPROFILE\.openclaw\openclaw.json",
    [string]$AutoApplyLogPath = "$env:USERPROFILE\.openclaw\governance\auto-apply.log",
    [int]$MinOccurrences = 3,
    [int]$AnalysisWindowDays = 7,
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

function Extract-ServantPhrases {
    param([array]$Violations)
    
    $phrases = @()
    foreach ($v in $Violations) {
        if ($v.type -eq "SERVANT_MODE" -and $v.details) {
            # Extract phrase from details like: "Servant-mode phrase detected: 'your servant'"
            if ($v.details -match 'detected:\s*["\x27]([^"\x27]+)["\x27]') {
                $phrases += $matches[1]
            }
            # Alternative format: "Phrase 'your servant' triggered servant-mode"
            elseif ($v.details -match "Phrase\s*['\x27]([^'\x27]+)['\x27]") {
                $phrases += $matches[1]
            }
        }
    }
    
    return $phrases
}

# Main execution
Write-Host "=== Auto-Fix: Servant-Mode Pattern Auto-Expand ===" -ForegroundColor Cyan
Write-Host "Analysis Window: $AnalysisWindowDays days"
Write-Host "Min Occurrences: $MinOccurrences"
Write-Host ""

# Check auto-apply cap
if (-not (Test-AutoApplyCap -AutoApplyLogPath $AutoApplyLogPath)) {
    Write-Host "Exiting: Auto-apply cap reached for this week" -ForegroundColor Yellow
    exit 0
}

# Load violations
$Violations = @()
if (Test-Path $ViolationsPath) {
    $Lines = Get-Content $ViolationsPath | Where-Object { $_.Trim() }
    $CutoffDate = (Get-Date).AddDays(-$AnalysisWindowDays)
    
    foreach ($Line in $Lines) {
        try {
            $Violation = $Line | ConvertFrom-Json
            $ViolationTime = [DateTime]::Parse($Violation.timestamp)
            if ($ViolationTime -ge $CutoffDate) {
                $Violations += $Violation
            }
        } catch {
            if ($Verbose) { Write-Warning "Failed to parse: $Line" }
        }
    }
}

Write-Host "Violations analyzed (last $AnalysisWindowDays days): $($Violations.Count)"

# Extract servant-mode phrases
$AllPhrases = Extract-ServantPhrases -Violations $Violations
Write-Host "Servant-mode phrases found: $($AllPhrases.Count)"

if ($AllPhrases.Count -eq 0) {
    Write-Host "No servant-mode violations detected in analysis window" -ForegroundColor Gray
    exit 0
}

# Group by phrase and find recurring ones
$PhraseGroups = $AllPhrases | Group-Object
$RecurringPhrases = $PhraseGroups | Where-Object { $_.Count -ge $MinOccurrences }

Write-Host "`nRecurring phrases (>= $MinOccurrences occurrences):" -ForegroundColor Cyan
if ($RecurringPhrases.Count -eq 0) {
    Write-Host "  No phrases meet threshold" -ForegroundColor Gray
    exit 0
}

foreach ($Group in $RecurringPhrases) {
    Write-Host "  '$($Group.Name)': $($Group.Count) occurrences"
}

# Load current config
$CurrentPatterns = @()
if (Test-Path $OpenClawConfigPath) {
    try {
        $Config = Get-Content $OpenClawConfigPath | ConvertFrom-Json
        if ($Config.plugins -and $Config.plugins.entries -and $Config.plugins.entries."protocol-enforcer") {
            $enforcerConfig = $Config.plugins.entries."protocol-enforcer".config
            if ($enforcerConfig.servantModePatterns) {
                $CurrentPatterns = @($enforcerConfig.servantModePatterns)
            }
        }
    } catch {
        Write-Log "Failed to load openclaw.json: $_" "ERROR"
        exit 1
    }
}

Write-Host "`nCurrent servant-mode patterns: $($CurrentPatterns.Count)"

# Find new patterns to add
$PatternsToAdd = @()
foreach ($Group in $RecurringPhrases) {
    $phrase = $Group.Name
    if ($CurrentPatterns -notcontains $phrase) {
        $PatternsToAdd += @{
            Phrase = $phrase
            Occurrences = $Group.Count
        }
    } else {
        Write-Host "  Already tracked: '$phrase'" -ForegroundColor Gray
    }
}

if ($PatternsToAdd.Count -eq 0) {
    Write-Host "`nAll recurring phrases already tracked" -ForegroundColor Green
    exit 0
}

Write-Host "`nNew patterns to add: $($PatternsToAdd.Count)" -ForegroundColor Yellow

# Apply auto-fixes
foreach ($Pattern in $PatternsToAdd) {
    $phrase = $Pattern.Phrase
    $occurrences = $Pattern.Occurrences
    
    Write-Host "`nProcessing: '$phrase' ($occurrences occurrences)" -ForegroundColor Cyan
    
    if ($DryRun) {
        Write-Host "  [DRY RUN] Would add to servantModePatterns" -ForegroundColor Yellow
        Write-Host "  [DRY RUN] Would log to auto-apply.log" -ForegroundColor Yellow
        continue
    }
    
    # Add to config
    try {
        $Config = Get-Content $OpenClawConfigPath | ConvertFrom-Json
        
        # Ensure structure exists
        if (-not $Config.plugins) { $Config.plugins = @{ entries = @{} } }
        if (-not $Config.plugins.entries) { $Config.plugins.entries = @{} }
        if (-not $Config.plugins.entries."protocol-enforcer") { 
            $Config.plugins.entries."protocol-enforcer" = @{ config = @{ servantModePatterns = @() } }
        }
        if (-not $Config.plugins.entries."protocol-enforcer".config) {
            $Config.plugins.entries."protocol-enforcer".config = @{ servantModePatterns = @() }
        }
        if (-not $Config.plugins.entries."protocol-enforcer".config.servantModePatterns) {
            $Config.plugins.entries."protocol-enforcer".config.servantModePatterns = @()
        }
        
        # Add pattern
        $Config.plugins.entries."protocol-enforcer".config.servantModePatterns += $phrase
        
        # Save config
        $Config | ConvertTo-Json -Depth 10 | Set-Content $OpenClawConfigPath
        Write-Host "  ? Added to openclaw.json" -ForegroundColor Green
    } catch {
        Write-Log "Failed to update config: $_" "ERROR"
        continue
    }
    
    # Log to auto-apply.log
    try {
        $LogEntry = @{
            timestamp = (Get-Date -Format "o")
            action = "AUTO_EXPAND_SERVANT_PATTERNS"
            pattern = $phrase
            occurrences = $occurrences
            analysisWindowDays = $AnalysisWindowDays
            minOccurrences = $MinOccurrences
            rollback = "Remove '$phrase' from servantModePatterns in openclaw.json"
            riskTier = "low"
            sessionId = $env:SESSION_ID
        } | ConvertTo-Json -Compress
        
        # Ensure directory exists
        $logDir = Split-Path $AutoApplyLogPath -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        
        Add-Content -Path $AutoApplyLogPath -Value $LogEntry
        Write-Host "  ? Logged to auto-apply.log" -ForegroundColor Green
        Write-Host "  Rollback: $($LogEntry.rollback | ConvertFrom-Json).rollback" -ForegroundColor Gray
    } catch {
        Write-Log "Failed to log auto-apply: $_" "ERROR"
    }
}

Write-Host "`n=== Auto-Fix Complete ===" -ForegroundColor Cyan
Write-Host "Patterns added: $($PatternsToAdd.Count)"
Write-Host "Remaining auto-applies this week: $((Test-AutoApplyCap -AutoApplyLogPath $AutoApplyLogPath -MaxPerWeek 3))"
