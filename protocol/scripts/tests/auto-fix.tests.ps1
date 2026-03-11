# Pester Tests for Phase 2 Auto-Fix Scripts
# Parent Issue: #114 (Phase 2: Pattern-Specific Auto-Fixes)
# Success Criteria: S2, A2, A3 (test evidence)

$ScriptDir = Split-Path $PSScriptRoot -Parent
$TestDir = $PSScriptRoot
$GovernanceDir = "$env:USERPROFILE\.openclaw\governance"

$TestViolationsPath = "$TestDir\test-violations.jsonl"
$TestConfigPath = "$TestDir\test-config.json"
$TestAutoApplyLogPath = "$TestDir\test-auto-apply.log"

# Backup original violations
$OriginalViolationsPath = "$GovernanceDir\violations.jsonl"
if (Test-Path $OriginalViolationsPath) {
    Copy-Item $OriginalViolationsPath "$TestDir\backup-violations.jsonl" -Force
}

Describe "Auto-Fix Scripts - Unit Tests" {
    
    Context "auto-fix-servant-mode.ps1" {
        
        It "Detects recurring servant-mode phrases (>= 3 occurrences)" {
            # Create test violations
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: 'your servant'"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: 'your servant'"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-3).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: 'your servant'"; agentId = "main"}
            )
            
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            # Create test config
            $config = @{
                plugins = @{
                    entries = @{
                        "protocol-enforcer" = @{
                            config = @{
                                servantModePatterns = @("Great question")
                            }
                        }
                    }
                }
            }
            $config | ConvertTo-Json -Depth 10 | Out-File $TestConfigPath -Encoding UTF8
            
            if (Test-Path $TestAutoApplyLogPath) { Remove-Item $TestAutoApplyLogPath -Force }
            
            $output = & "$ScriptDir\auto-fix-servant-mode.ps1" `
                -ViolationsPath $TestViolationsPath `
                -OpenClawConfigPath $TestConfigPath `
                -AutoApplyLogPath $TestAutoApplyLogPath `
                -DryRun `
                2>&1 | Out-String
            
            $output | Should Match "Recurring phrases"
            $output | Should Match "your servant"
        }
        
        It "Respects minimum occurrence threshold" {
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: rare phrase"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: rare phrase"; agentId = "main"}
            )
            
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            $config = @{
                plugins = @{
                    entries = @{
                        "protocol-enforcer" = @{
                            config = @{
                                servantModePatterns = @()
                            }
                        }
                    }
                }
            }
            $config | ConvertTo-Json -Depth 10 | Out-File $TestConfigPath -Encoding UTF8
            
            $output = & "$ScriptDir\auto-fix-servant-mode.ps1" `
                -ViolationsPath $TestViolationsPath `
                -OpenClawConfigPath $TestConfigPath `
                -AutoApplyLogPath $TestAutoApplyLogPath `
                -DryRun `
                2>&1 | Out-String
            
            $output | Should Match "No phrases meet threshold"
        }
    }
    
    Context "auto-fix-threshold-tuning.ps1" {
        
        It "Analyzes violation frequency correctly" {
            $config = @{
                analysisWindow = @{
                    days = 7
                    driftThreshold = 0.10
                }
            }
            $config | ConvertTo-Json -Depth 10 | Out-File $TestConfigPath -Encoding UTF8
            
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "MEMORY_RETRIEVAL_VIOLATION"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); type = "MEMORY_RETRIEVAL_VIOLATION"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-3).ToString("o"); type = "MEMORY_RETRIEVAL_VIOLATION"; agentId = "main"}
            )
            
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            if (Test-Path $TestAutoApplyLogPath) { Remove-Item $TestAutoApplyLogPath -Force }
            
            $output = & "$ScriptDir\auto-fix-threshold-tuning.ps1" `
                -ConfigPath $TestConfigPath `
                -ViolationsPath $TestViolationsPath `
                -AutoApplyLogPath $TestAutoApplyLogPath `
                -AnalysisWindowDays 7 `
                -DryRun `
                2>&1 | Out-String
            
            $output | Should Match "Analyzing violations"
            $output | Should Match "Total: 3"
        }
    }
    
    Context "auto-fix-telegram-alerts.ps1" {
        
        It "Detects compliance below threshold" {
            $compliance = @{
                currentRate = 0.85
                lastUpdated = (Get-Date).ToString("o")
                windowDays = 7
            }
            $compliance | ConvertTo-Json | Out-File "$TestDir\test-compliance.json" -Encoding UTF8
            
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "MEMORY_RETRIEVAL_VIOLATION"; agentId = "main"}
            )
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            if (Test-Path $TestAutoApplyLogPath) { Remove-Item $TestAutoApplyLogPath -Force }
            
            $output = & "$ScriptDir\auto-fix-telegram-alerts.ps1" `
                -CompliancePath "$TestDir\test-compliance.json" `
                -ViolationsPath $TestViolationsPath `
                -AutoApplyLogPath $TestAutoApplyLogPath `
                -AlertThreshold 0.90 `
                -DryRun `
                2>&1 | Out-String
            
            $output | Should Match "COMPLIANCE BELOW THRESHOLD"
            
            Remove-Item "$TestDir\test-compliance.json" -ErrorAction SilentlyContinue
        }
        
        It "Passes when compliance above threshold" {
            $compliance = @{
                currentRate = 0.95
                lastUpdated = (Get-Date).ToString("o")
                windowDays = 7
            }
            $compliance | ConvertTo-Json | Out-File "$TestDir\test-compliance.json" -Encoding UTF8
            
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "MEMORY_RETRIEVAL_VIOLATION"; agentId = "main"}
            )
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            $output = & "$ScriptDir\auto-fix-telegram-alerts.ps1" `
                -CompliancePath "$TestDir\test-compliance.json" `
                -ViolationsPath $TestViolationsPath `
                -AutoApplyLogPath $TestAutoApplyLogPath `
                -AlertThreshold 0.90 `
                -DryRun `
                2>&1 | Out-String
            
            $output | Should Match "Compliance rate OK"
            
            Remove-Item "$TestDir\test-compliance.json" -ErrorAction SilentlyContinue
        }
    }
    
    Context "memory-recovery.ps1" {
        
        It "Generates recovery report for memory-related violations" {
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "MEMORY_RETRIEVAL_VIOLATION"; details = "Memory not retrieved"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); type = "VERIFICATION_BEFORE_CREATION_VIOLATION"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-3).ToString("o"); type = "HEARTBEAT_MD_WIPE_VIOLATION"; agentId = "main"}
            )
            
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            $output = & "$ScriptDir\memory-recovery.ps1" `
                -ViolationsPath $TestViolationsPath `
                -WorkspacePath "$ScriptDir\..\.." `
                -DryRun `
                2>&1 | Out-String
            
            $output | Should Match "MEMORY DOMAIN AUTO-RECOVERY REPORT"
        }
    }
}

Describe "Auto-Fix Scripts - Integration Tests" {
    
    Context "3/Week Auto-Apply Cap Enforcement" {
        
        It "Blocks auto-apply when cap reached (3/week)" {
            # Create auto-apply log with 3 entries this week
            $testLogEntries = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); action = "AUTO_EXPAND_SERVANT_PATTERNS"; pattern = "test1"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); action = "AUTO_TUNING_THRESHOLD"; thresholdName = "test2"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-3).ToString("o"); action = "TELEGRAM_COMPLIANCE_ALERT"; complianceRate = 0.85}
            )
            
            $testLogEntries | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestAutoApplyLogPath -Encoding UTF8
            
            $config = @{
                plugins = @{
                    entries = @{
                        "protocol-enforcer" = @{
                            config = @{
                                servantModePatterns = @()
                            }
                        }
                    }
                }
            }
            $config | ConvertTo-Json -Depth 10 | Out-File $TestConfigPath -Encoding UTF8
            
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: new phrase"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: new phrase"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-3).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: new phrase"; agentId = "main"}
            )
            
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            $output = & "$ScriptDir\auto-fix-servant-mode.ps1" `
                -ViolationsPath $TestViolationsPath `
                -OpenClawConfigPath $TestConfigPath `
                -AutoApplyLogPath $TestAutoApplyLogPath `
                -DryRun `
                2>&1 | Out-String
            
            $output | Should Match "Auto-apply cap reached"
            $output | Should Match "3/3"
        }
        
        It "Allows auto-apply when cap not reached" {
            $testLogEntries = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); action = "AUTO_EXPAND_SERVANT_PATTERNS"; pattern = "test1"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); action = "AUTO_TUNING_THRESHOLD"; thresholdName = "test2"}
            )
            
            $testLogEntries | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestAutoApplyLogPath -Encoding UTF8
            
            $config = @{
                plugins = @{
                    entries = @{
                        "protocol-enforcer" = @{
                            config = @{
                                servantModePatterns = @()
                            }
                        }
                    }
                }
            }
            $config | ConvertTo-Json -Depth 10 | Out-File $TestConfigPath -Encoding UTF8
            
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: new phrase"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: new phrase"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-3).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: new phrase"; agentId = "main"}
            )
            
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            $output = & "$ScriptDir\auto-fix-servant-mode.ps1" `
                -ViolationsPath $TestViolationsPath `
                -OpenClawConfigPath $TestConfigPath `
                -AutoApplyLogPath $TestAutoApplyLogPath `
                -DryRun `
                2>&1 | Out-String
            
            $output | Should Match "Auto-apply usage: 2/3"
            $output | Should Not Match "Auto-apply cap reached"
        }
    }
    
    Context "Auto-Apply Logging with Rollback Instructions" {
        
        It "Logs auto-apply with rollback instructions" {
            if (Test-Path $TestAutoApplyLogPath) { Remove-Item $TestAutoApplyLogPath -Force }
            
            $config = @{
                plugins = @{
                    entries = @{
                        "protocol-enforcer" = @{
                            config = @{
                                servantModePatterns = @()
                            }
                        }
                    }
                }
            }
            $config | ConvertTo-Json -Depth 10 | Out-File $TestConfigPath -Encoding UTF8
            
            $testViolations = @(
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-1).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: test phrase"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-2).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: test phrase"; agentId = "main"},
                [PSCustomObject]@{timestamp = (Get-Date).AddDays(-3).ToString("o"); type = "SERVANT_MODE"; details = "Servant-mode phrase detected: test phrase"; agentId = "main"}
            )
            
            $testViolations | ForEach-Object { $_ | ConvertTo-Json -Compress } | Out-File $TestViolationsPath -Encoding UTF8
            
            & "$ScriptDir\auto-fix-servant-mode.ps1" `
                -ViolationsPath $TestViolationsPath `
                -OpenClawConfigPath $TestConfigPath `
                -AutoApplyLogPath $TestAutoApplyLogPath `
                2>&1 | Out-Null
            
            Test-Path $TestAutoApplyLogPath | Should Be $true
            
            $logEntry = Get-Content $TestAutoApplyLogPath | Select-Object -Last 1 | ConvertFrom-Json
            
            $logEntry.action | Should Be "AUTO_EXPAND_SERVANT_PATTERNS"
            $logEntry.timestamp | Should Not BeNullOrEmpty
            $logEntry.rollback | Should Not BeNullOrEmpty
            $logEntry.riskTier | Should Be "low"
        }
    }
}

Describe "Auto-Fix Scripts - Bug Fixes Verification" {
    
    Context "Auto-Apply Log Field Validation" {
        
        It "All auto-apply log entries have non-null required fields" {
            $autoApplyLogPath = "$GovernanceDir\auto-apply.log"
            
            if (-not (Test-Path $autoApplyLogPath)) {
                Write-Host "SKIP: auto-apply.log does not exist yet" -ForegroundColor Yellow
                return
            }
            
            $entries = Get-Content $autoApplyLogPath | ForEach-Object {
                try { $_ | ConvertFrom-Json } catch { $null }
            } | Where-Object { $_ -ne $null }
            
            $failedChecks = @()
            foreach ($entry in $entries) {
                if (-not $entry.action) { $failedChecks += "action is null" }
                if (-not $entry.timestamp) { $failedChecks += "timestamp is null" }
                if (-not $entry.rollback) { $failedChecks += "rollback is null" }
                if (-not $entry.riskTier) { $failedChecks += "riskTier is null" }
            }
            
            if ($failedChecks.Count -gt 0) {
                throw "Field validation failed: $($failedChecks -join ', ')"
            }
        }
    }
}

# Cleanup
if (Test-Path $TestViolationsPath) { Remove-Item $TestViolationsPath -Force }
if (Test-Path $TestConfigPath) { Remove-Item $TestConfigPath -Force }
if (Test-Path $TestAutoApplyLogPath) { Remove-Item $TestAutoApplyLogPath -Force }
if (Test-Path "$TestDir\test-compliance.json") { Remove-Item "$TestDir\test-compliance.json" -Force }

# Restore original violations
if (Test-Path "$TestDir\backup-violations.jsonl") {
    Copy-Item "$TestDir\backup-violations.jsonl" $OriginalViolationsPath -Force
    Remove-Item "$TestDir\backup-violations.jsonl" -Force
}
