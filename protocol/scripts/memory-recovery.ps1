# Memory Domain Auto-Recovery (Servant-Mode Pattern)
# Reads governance/violations.jsonl, identifies memory-related violations,
# maps violation domain → memory topic file, and outputs recovery suggestions.
#
# Parent Epic: #116 (Phase 2: Pattern-Specific Auto-Fixes)
# Pattern: Servant-mode auto-expand — when agent violates memory protocol, auto-suggest correct recovery path
# Risk Tier: Low (read-only analysis + suggestion output)
#
# Usage:
#   .\memory-recovery.ps1
#   .\memory-recovery.ps1 -ViolationsPath "C:\path\to\violations.jsonl"
#   .\memory-recovery.ps1 -Verbose

param(
    [string]$ViolationsPath = "$env:USERPROFILE\.openclaw\governance\violations.jsonl",
    [string]$WorkspacePath = "$env:USERPROFILE\.openclaw\workspace",
    [string]$OutputPath = "$env:USERPROFILE\.openclaw\governance\memory-recovery.log",
    [switch]$Verbose,
    [switch]$DryRun
)

# Memory-related violation types and their domain mappings
$MemoryViolationMap = @{
    # Memory retrieval violations
    "MEMORY_RETRIEVAL_VIOLATION" = @{
        Domain = "memory-retrieval"
        TopicFile = "memory/topics/project-management.md"
        RecoverySuggestion = "Read memory/topics/project-management.md before next action to check existing context"
    }
    "MEMORY_NOT_RETRIEVED" = @{
        Domain = "memory-retrieval"
        TopicFile = "memory/topics/project-management.md"
        RecoverySuggestion = "Read memory/topics/project-management.md before next action to verify prior work"
    }
    
    # Verification before creation violations
    "VERIFICATION_BEFORE_CREATION_VIOLATION" = @{
        Domain = "verification"
        TopicFile = "memory/topics/project-management.md"
        RecoverySuggestion = "Read memory/topics/project-management.md and check existing files before creating new ones"
    }
    
    # Heartbeat protocol violations
    "HEARTBEAT_PROTOCOL_FAILURE" = @{
        Domain = "heartbeat"
        TopicFile = "memory/topics/operational-log.md"
        RecoverySuggestion = "Read memory/topics/operational-log.md and HEARTBEAT.md before next heartbeat cycle"
    }
    "HEARTBEAT_MD_WIPE_VIOLATION" = @{
        Domain = "heartbeat"
        TopicFile = "memory/topics/operational-log.md"
        RecoverySuggestion = "Read memory/topics/operational-log.md and review HEARTBEAT.md protocol before modifying"
    }
    
    # Policy structure violations
    "POLICY_STRUCTURE_VIOLATION" = @{
        Domain = "policy-structure"
        TopicFile = "memory/topics/legal-compliance.md"
        RecoverySuggestion = "Read memory/topics/legal-compliance.md and policies/POLICIES.md before creating policies"
    }
    "POLICY_VIOLATION" = @{
        Domain = "policy-compliance"
        TopicFile = "memory/topics/legal-compliance.md"
        RecoverySuggestion = "Read memory/topics/legal-compliance.md and review violated policy before proceeding"
    }
    
    # Data exfiltration violations
    "PRIVATE_DATA_EXFILTRATION" = @{
        Domain = "security"
        TopicFile = "memory/topics/security.md"
        RecoverySuggestion = "Read memory/topics/security.md before any external communication or data sharing"
    }
    
    # Servant-mode violations
    "SERVANT_MODE" = @{
        Domain = "servant-mode"
        TopicFile = "memory/topics/seva-world.md"
        RecoverySuggestion = "Read memory/topics/seva-world.md to review servant-mode protocol and identity boundaries"
    }
    
    # External communications
    "EXTERNAL_COMMS_VIOLATION" = @{
        Domain = "external-comms"
        TopicFile = "memory/topics/legal-compliance.md"
        RecoverySuggestion = "Read memory/topics/legal-compliance.md before any external communication"
    }
}

# Fallback mapping for unknown memory-related violations
$DefaultRecovery = @{
    Domain = "general"
    TopicFile = "AGENTS.md"
    RecoverySuggestion = "Read AGENTS.md and MEMORY.md to review core protocols before proceeding"
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "o"
    $logEntry = "[$timestamp] [$Level] $Message"
    Write-Host $logEntry -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARN") { "Yellow" } else { "Green" })
    return $logEntry
}

function Get-MemoryTopicFiles {
    param([string]$WorkspacePath)
    
    $topicFiles = @()
    $topicsPath = Join-Path $WorkspacePath "memory\topics"
    
    if (Test-Path $topicsPath) {
        $topicFiles = Get-ChildItem -Path $topicsPath -Filter "*.md" -File | ForEach-Object {
            "memory/topics/$($_.Name)"
        }
    }
    
    # Also include root memory files
    $memoryFiles = @("AGENTS.md", "MEMORY.md", "HEARTBEAT.md")
    foreach ($file in $memoryFiles) {
        $fullPath = Join-Path $WorkspacePath $file
        if (Test-Path $fullPath) {
            $topicFiles += $file
        }
    }
    
    return $topicFiles
}

function Get-RecoverySuggestion {
    param(
        [string]$ViolationType,
        [string]$Details
    )
    
    # Check if violation type has a specific mapping
    if ($MemoryViolationMap.ContainsKey($ViolationType)) {
        return $MemoryViolationMap[$ViolationType]
    }
    
    # Check for partial matches (e.g., "MEMORY_*" violations)
    foreach ($key in $MemoryViolationMap.Keys) {
        if ($ViolationType -like "*$key*" -or $key -like "*$ViolationType*") {
            return $MemoryViolationMap[$key]
        }
    }
    
    # Check if details mention specific domains
    $detailsLower = $Details.ToLower()
    if ($detailsLower -match "memory|retriev") {
        return $MemoryViolationMap["MEMORY_RETRIEVAL_VIOLATION"]
    }
    if ($detailsLower -match "heartbeat") {
        return $MemoryViolationMap["HEARTBEAT_PROTOCOL_FAILURE"]
    }
    if ($detailsLower -match "policy|governance") {
        return $MemoryViolationMap["POLICY_VIOLATION"]
    }
    if ($detailsLower -match "security|private|exfil") {
        return $MemoryViolationMap["PRIVATE_DATA_EXFILTRATION"]
    }
    if ($detailsLower -match "servant|identity") {
        return $MemoryViolationMap["SERVANT_MODE"]
    }
    if ($detailsLower -match "verif|creat") {
        return $MemoryViolationMap["VERIFICATION_BEFORE_CREATION_VIOLATION"]
    }
    
    # Return default recovery
    return $DefaultRecovery
}

function Analyze-Violations {
    param(
        [string]$ViolationsPath,
        [int]$AnalysisWindowDays = 30
    )
    
    $violations = @()
    $cutoffDate = (Get-Date).AddDays(-$AnalysisWindowDays)
    
    if (-not (Test-Path $ViolationsPath)) {
        Write-Log "Violations file not found: $ViolationsPath" "ERROR"
        return @()
    }
    
    $lines = Get-Content $ViolationsPath | Where-Object { $_.Trim() }
    
    foreach ($line in $lines) {
        try {
            $violation = $line | ConvertFrom-Json
            $violationTime = [DateTime]::Parse($violation.timestamp)
            
            if ($violationTime -ge $cutoffDate) {
                $violations += $violation
            }
        } catch {
            if ($Verbose) {
                Write-Warning "Failed to parse violation: $line"
            }
        }
    }
    
    return $violations
}

function Generate-RecoveryReport {
    param(
        [array]$Violations,
        [string]$WorkspacePath
    )
    
    $report = @()
    $domainGroups = @{}
    
    # Group violations by domain
    foreach ($v in $Violations) {
        $recovery = Get-RecoverySuggestion -ViolationType $v.type -Details $v.details
        
        if (-not $domainGroups.ContainsKey($recovery.Domain)) {
            $domainGroups[$recovery.Domain] = @{
                Violations = @()
                TopicFile = $recovery.TopicFile
                RecoverySuggestion = $recovery.RecoverySuggestion
                ViolationTypes = @{}
            }
        }
        
        $domainGroups[$recovery.Domain].Violations += $v
        
        # Track violation types
        if (-not $domainGroups[$recovery.Domain].ViolationTypes.ContainsKey($v.type)) {
            $domainGroups[$recovery.Domain].ViolationTypes[$v.type] = 0
        }
        $domainGroups[$recovery.Domain].ViolationTypes[$v.type]++
    }
    
    # Generate report
    $report += "=" * 80
    $report += "MEMORY DOMAIN AUTO-RECOVERY REPORT"
    $report += "Generated: $(Get-Date -Format 'o')"
    $report += "Violations Analyzed: $($Violations.Count)"
    $report += "=" * 80
    $report += ""
    
    foreach ($domain in $domainGroups.Keys) {
        $group = $domainGroups[$domain]
        $violationCount = @($group.Violations).Count
        
        $report += "DOMAIN: $domain"
        $report += "-" * 40
        $report += "Topic File: $($group.TopicFile)"
        $report += "Violation Count: $violationCount"
        $report += ""
        $report += "Violation Types:"
        foreach ($type in $group.ViolationTypes.Keys) {
            $report += "  - $type : $($group.ViolationTypes[$type]) occurrence(s)"
        }
        $report += ""
        $report += "RECOVERY SUGGESTION:"
        $report += "  > $($group.RecoverySuggestion)"
        $report += ""
        $report += "Sample Violations:"
        for ($i = 0; $i -lt [Math]::Min(3, $violationCount); $i++) {
            $v = $group.Violations[$i]
            $report += "  [$($v.timestamp)] $($v.type): $($v.details)"
        }
        $report += ""
        $report += "=" * 80
        $report += ""
    }
    
    # Summary
    $report += "SUMMARY"
    $report += "-" * 40
    $report += "Total Domains Affected: $($domainGroups.Keys.Count)"
    $report += ""
    $report += "Quick Recovery Commands:"
    foreach ($domain in $domainGroups.Keys) {
        $group = $domainGroups[$domain]
        $topicFile = Join-Path $WorkspacePath $group.TopicFile
        if (Test-Path $topicFile) {
            $report += "  Get-Content '$topicFile'  # For domain: $domain"
        } else {
            $report += "  # File not found: $($group.TopicFile)  # For domain: $domain"
        }
    }
    $report += ""
    $report += "=" * 80
    
    return $report
}

# Main execution
Write-Host "=== Memory Domain Auto-Recovery ===" -ForegroundColor Cyan
Write-Host "Workspace: $WorkspacePath"
Write-Host "Violations Path: $ViolationsPath"
Write-Host ""

# Verify workspace exists
if (-not (Test-Path $WorkspacePath)) {
    Write-Log "Workspace not found: $WorkspacePath" "ERROR"
    exit 1
}

# Get available memory topic files
$topicFiles = Get-MemoryTopicFiles -WorkspacePath $WorkspacePath
Write-Host "Available memory topic files: $($topicFiles.Count)" -ForegroundColor Gray
if ($Verbose) {
    foreach ($f in $topicFiles) {
        Write-Host "  - $f" -ForegroundColor Gray
    }
}
Write-Host ""

# Analyze violations
Write-Host "Analyzing violations (last 30 days)..."
$violations = Analyze-Violations -ViolationsPath $ViolationsPath -AnalysisWindowDays 30
Write-Host "Violations found: $($violations.Count)" -ForegroundColor $(if ($violations.Count -eq 0) { "Yellow" } else { "Green" })

if ($violations.Count -eq 0) {
    Write-Host "No violations to analyze. Exiting." -ForegroundColor Gray
    exit 0
}

# Filter to memory-related violations
$memoryRelatedViolations = $violations | Where-Object {
    $recovery = Get-RecoverySuggestion -ViolationType $_.type -Details $_.details
    $recovery.Domain -ne "unknown"
}

Write-Host "Memory-related violations: $($memoryRelatedViolations.Count)" -ForegroundColor Cyan
Write-Host ""

# Generate recovery report
$report = Generate-RecoveryReport -Violations $memoryRelatedViolations -WorkspacePath $WorkspacePath

# Output report
Write-Host "`n=== RECOVERY REPORT ===" -ForegroundColor Cyan
foreach ($line in $report) {
    Write-Host $line
}

# Save to log file
if (-not $DryRun) {
    try {
        # Ensure directory exists
        $logDir = Split-Path $OutputPath -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        
        $report | Out-File -FilePath $OutputPath -Encoding UTF8
        Write-Host "`nReport saved to: $OutputPath" -ForegroundColor Green
    } catch {
        Write-Log "Failed to save report: $_" "ERROR"
    }
}

# Output machine-readable summary (for programmatic use)
Write-Host "`n=== MACHINE-READABLE SUMMARY ===" -ForegroundColor Cyan
$summary = @{
    timestamp = Get-Date -Format "o"
    totalViolations = $violations.Count
    memoryRelatedViolations = $memoryRelatedViolations.Count
    recoverySuggestions = @()
}

$domainGroups = @{}
foreach ($v in $memoryRelatedViolations) {
    $recovery = Get-RecoverySuggestion -ViolationType $v.type -Details $v.details
    if (-not $domainGroups.ContainsKey($recovery.Domain)) {
        $domainGroups[$recovery.Domain] = @{
            domain = $recovery.Domain
            topicFile = $recovery.TopicFile
            recoverySuggestion = $recovery.RecoverySuggestion
            violationCount = 0
            violationTypes = @()
        }
    }
    $domainGroups[$recovery.Domain].violationCount++
    if ($domainGroups[$recovery.Domain].violationTypes -notcontains $v.type) {
        $domainGroups[$recovery.Domain].violationTypes += $v.type
    }
}

$summary.recoverySuggestions = $domainGroups.Values

$summary | ConvertTo-Json -Depth 5

Write-Host "`n=== Memory Domain Auto-Recovery Complete ===" -ForegroundColor Cyan
