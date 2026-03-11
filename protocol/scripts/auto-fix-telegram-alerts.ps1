# Auto-Fix: Telegram Compliance Alert
# Monitors compliance rate and sends Telegram alert when it drops below threshold
#
# Parent Epic: #114 (Phase 2: Pattern-Specific Auto-Fixes)
# Risk Tier: Low (read-only alert, no state changes)
# Cap: Counts toward 3/week auto-apply limit (alert frequency limited)

param(
    [string]$ConfigPath = "$env:USERPROFILE\.openclaw\governance\config.json",
    [string]$CompliancePath = "$env:USERPROFILE\.openclaw\governance\compliance.json",
    [string]$ViolationsPath = "$env:USERPROFILE\.openclaw\governance\violations.jsonl",
    [string]$AutoApplyLogPath = "$env:USERPROFILE\.openclaw\governance\auto-apply.log",
    [string]$TelegramBotToken,
    [string]$TelegramChatId,
    [double]$AlertThreshold = 0.90,
    [int]$CooldownHours = 24,
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

function Get-ComplianceRate {
    param(
        [string]$CompliancePath,
        [int]$WindowDays = 7
    )
    
    if (-not (Test-Path $CompliancePath)) {
        # Calculate from violations if compliance.json doesn't exist
        return Calculate-ComplianceFromViolations -ViolationsPath $ViolationsPath -WindowDays $WindowDays
    }
    
    try {
        $compliance = Get-Content $CompliancePath | ConvertFrom-Json
        return @{
            rate = $compliance.currentRate
            lastUpdated = $compliance.lastUpdated
            windowDays = $compliance.windowDays
        }
    } catch {
        return Calculate-ComplianceFromViolations -ViolationsPath $ViolationsPath -WindowDays $WindowDays
    }
}

function Calculate-ComplianceFromViolations {
    param(
        [string]$ViolationsPath,
        [int]$WindowDays = 7
    )
    
    if (-not (Test-Path $ViolationsPath)) {
        return @{ rate = 1.0; lastUpdated = (Get-Date -Format "o"); windowDays = $WindowDays }
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
    
    # Estimate tool calls (rough heuristic: 1 violation per ~50 tool calls)
    $estimatedToolCalls = $Violations.Count * 50
    if ($estimatedToolCalls -lt 10) { $estimatedToolCalls = 10 } # Minimum baseline
    
    $complianceRate = 1 - ($Violations.Count / $estimatedToolCalls)
    $complianceRate = [Math]::Max(0, [Math]::Min(1, $complianceRate))
    
    return @{
        rate = $complianceRate
        lastUpdated = (Get-Date -Format "o")
        windowDays = $WindowDays
        violations = $Violations.Count
    }
}

function Test-AlertCooldown {
    param(
        [string]$AutoApplyLogPath,
        [int]$CooldownHours
    )
    
    if (-not (Test-Path $AutoApplyLogPath)) {
        return $true
    }
    
    $CooldownAgo = (Get-Date).AddHours(-$CooldownHours)
    $RecentAlerts = Get-Content $AutoApplyLogPath | Where-Object {
        try {
            $entry = $_ | ConvertFrom-Json
            $entry.action -eq "TELEGRAM_COMPLIANCE_ALERT" -and
            [DateTime]::Parse($entry.timestamp) -ge $CooldownAgo
        } catch {
            $false
        }
    }
    
    $count = @($RecentAlerts).Count
    if ($count -gt 0) {
        $lastAlert = $RecentAlerts | Sort-Object { [DateTime]::Parse($_.timestamp) } | Select-Object -Last 1
        $lastAlertTime = [DateTime]::Parse($lastAlert.timestamp)
        $hoursSince = (Get-Date) - $lastAlertTime
        Write-Log "Alert on cooldown: last alert $($hoursSince.TotalHours.ToString('0.0')) hours ago" "WARN"
        return $false
    }
    
    return $true
}

function Send-TelegramAlert {
    param(
        [string]$BotToken,
        [string]$ChatId,
        [string]$Message
    )
    
    if (-not $BotToken -or -not $ChatId) {
        Write-Log "Telegram credentials not provided. Alert not sent." "WARN"
        return $false
    }
    
    $url = "https://api.telegram.org/bot$BotToken/sendMessage"
    $body = @{
        chat_id = $ChatId
        text = $Message
        parse_mode = "Markdown"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -ContentType "application/json"
        if ($response.ok) {
            Write-Log "Telegram alert sent successfully" "INFO"
            return $true
        } else {
            Write-Log "Telegram API error: $($response.description)" "ERROR"
            return $false
        }
    } catch {
        Write-Log "Failed to send Telegram alert: $_" "ERROR"
        return $false
    }
}

function Get-ComplianceTrend {
    param(
        [string]$ViolationsPath,
        [int]$WindowDays = 7
    )
    
    if (-not (Test-Path $ViolationsPath)) {
        return "stable"
    }
    
    $HalfWindow = $WindowDays / 2
    $CutoffDate = (Get-Date).AddDays(-$WindowDays)
    $HalfDate = (Get-Date).AddDays(-$HalfWindow)
    
    $FirstHalf = @()
    $SecondHalf = @()
    
    $Lines = Get-Content $ViolationsPath | Where-Object { $_.Trim() }
    foreach ($Line in $Lines) {
        try {
            $V = $Line | ConvertFrom-Json
            $VTime = [DateTime]::Parse($V.timestamp)
            if ($VTime -ge $CutoffDate) {
                if ($VTime -lt $HalfDate) {
                    $FirstHalf += $V
                } else {
                    $SecondHalf += $V
                }
            }
        } catch {
            # Skip malformed lines
        }
    }
    
    if ($SecondHalf.Count -gt ($FirstHalf.Count * 1.2)) {
        return "declining"
    } elseif ($FirstHalf.Count -gt ($SecondHalf.Count * 1.2)) {
        return "improving"
    } else {
        return "stable"
    }
}

# Main execution
Write-Host "=== Auto-Fix: Telegram Compliance Alert ===" -ForegroundColor Cyan
Write-Host "Alert Threshold: $([Math]::Round($AlertThreshold * 100, 1))%"
Write-Host "Cooldown: $CooldownHours hours"
Write-Host ""

# Check auto-apply cap
if (-not (Test-AutoApplyCap -AutoApplyLogPath $AutoApplyLogPath)) {
    Write-Host "Exiting: Auto-apply cap reached for this week" -ForegroundColor Yellow
    exit 0
}

# Check alert cooldown
if (-not (Test-AlertCooldown -AutoApplyLogPath $CooldownHours)) {
    Write-Host "Exiting: Alert on cooldown" -ForegroundColor Yellow
    exit 0
}

# Get compliance rate
Write-Host "Checking compliance rate..."
$compliance = Get-ComplianceRate -CompliancePath $CompliancePath -WindowDays 7
$currentRate = $compliance.rate
Write-Host "  Current rate: $([Math]::Round($currentRate * 100, 1))%"
Write-Host "  Threshold: $([Math]::Round($AlertThreshold * 100, 1))%"
Write-Host ""

# Check if alert needed
if ($currentRate -ge $AlertThreshold) {
    Write-Host "Compliance rate OK (above threshold)" -ForegroundColor Green
    exit 0
}

Write-Host "⚠️  COMPLIANCE BELOW THRESHOLD!" -ForegroundColor Red
Write-Host ""

# Get trend
$trend = Get-ComplianceTrend -ViolationsPath $ViolationsPath -WindowDays 7
Write-Host "Trend: $trend"

# Get recent violations for context
$recentViolations = @()
if (Test-Path $ViolationsPath) {
    $Lines = Get-Content $ViolationsPath | Where-Object { $_.Trim() } | Select-Object -Last 5
    foreach ($Line in $Lines) {
        try {
            $recentViolations += $Line | ConvertFrom-Json
        } catch {
            # Skip malformed lines
        }
    }
}

# Build alert message
$message = @"
⚠️ *Compliance Alert*

*Current Rate:* $([Math]::Round($currentRate * 100, 1))%
*Threshold:* $([Math]::Round($AlertThreshold * 100, 1))%
*Trend:* $trend

*Recent Violations:*
"@

foreach ($v in $recentViolations) {
    $type = $v.type
    $timestamp = [DateTime]::Parse($v.timestamp).ToString("MM/dd HH:mm")
    $message += "`n• [$timestamp] $type"
}

$message += @"

*Action Required:* Review violations and address root causes.

_Auto-generated by Phase 2 Auto-Fix (#118)_
"@

Write-Host "`nAlert message:" -ForegroundColor Cyan
Write-Host $message
Write-Host ""

# Send alert
if ($DryRun) {
    Write-Host "[DRY RUN] Would send Telegram alert" -ForegroundColor Yellow
    exit 0
}

# Try to get Telegram credentials from config
if (-not $TelegramBotToken -or -not $TelegramChatId) {
    try {
        $openclawConfig = Get-Content "$env:USERPROFILE\.openclaw\openclaw.json" | ConvertFrom-Json
        if ($openclawConfig.channels.telegram.botToken) {
            $TelegramBotToken = $openclawConfig.channels.telegram.botToken
        }
        # Chat ID is typically the user's Telegram ID - use a default or require parameter
        if (-not $TelegramChatId) {
            Write-Log "Telegram Chat ID not configured. Alert not sent." "WARN"
            Write-Host "To enable alerts, provide -TelegramChatId parameter or configure in openclaw.json"
            exit 0
        }
    } catch {
        Write-Log "Failed to load Telegram config: $_" "ERROR"
        exit 1
    }
}

$alertSent = Send-TelegramAlert -BotToken $TelegramBotToken -ChatId $TelegramChatId -Message $message

if ($alertSent) {
    # Log to auto-apply.log
    try {
        $LogEntry = @{
            timestamp = (Get-Date -Format "o")
            action = "TELEGRAM_COMPLIANCE_ALERT"
            complianceRate = $currentRate
            threshold = $AlertThreshold
            trend = $trend
            violationCount = $recentViolations.Count
            cooldownHours = $CooldownHours
            rollback = "N/A (alert is informational only)"
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
Write-Host "Alert sent: $alertSent"
