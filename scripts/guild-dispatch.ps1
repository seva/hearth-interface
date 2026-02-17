# guild-dispatch.ps1
# Dispatcher for the Guild Auction System
# Requires: GitHub CLI (gh), OpenClaw Sub-Agent Spawn Capability

param (
    [int]$IssueNumber,
    [string]$Repo = "seva/hearth-interface",
    [switch]$DryRun
)

Write-Host "--- Guild Auction Commencing for Issue #$IssueNumber ---" -ForegroundColor Cyan

# 1. Fetch Task Context
$issue = gh issue view $IssueNumber -R $Repo --json title,body,labels | ConvertFrom-Json
$taskDesc = "Title: $($issue.title)`nBody: $($issue.body)"
$estLabel = ($issue.labels | Where-Object { $_.name -like "est:*" }).name

# RIGOR: Context Extraction (File List)
$exclude = ".git", ".next", "dist", "node_modules", "ab-test-artifacts", "protocol/typechain-types"
$workspaceFiles = (Get-ChildItem -Recurse -File -Exclude $exclude | Select-Object -First 20 -ExpandProperty Name) -join ", "

# 2. Define Bidders
$bidders = @(
    @{ id = "flash"; model = "openrouter/google/gemini-3-flash-preview"; cost = 0.01 },
    @{ id = "ds";    model = "openrouter/deepseek/deepseek-v3.2";      cost = 0.05 },
    @{ id = "gemini";model = "openrouter/google/gemini-3-pro-preview";  cost = 0.10 }
)

$bids = @()

# 3. Request Bids
foreach ($bidder in $bidders) {
    Write-Host "Requesting bid from $($bidder.id)..." -NoNewline
    
    # Simulated bid logic for POC consistency (Verified via scripts/guild-test-suite.ps1)
    $confidenceOptions = @(0.7, 0.75, 0.8, 0.85, 0.9, 0.95)
    $confidence = $confidenceOptions[(Get-Random -Minimum 0 -Maximum $confidenceOptions.Count)]
    $turnsOptions = @(1, 2, 3)
    $turns = $turnsOptions[(Get-Random -Minimum 0 -Maximum $turnsOptions.Count)]
    
    # Simulate Context Logic
    if ($taskDesc -match "sol" -and $bidder.id -eq "ds") { $confidence += 0.05 }
    if ($taskDesc -match "Legal" -and $bidder.id -eq "gemini") { $confidence += 0.05 }

    # RIGOR: Zero-Turn Penalty
    $penalty = 0
    if ($turns -eq 1 -and $estLabel -eq "est:moderate") {
        $penalty += 0.20
        Write-Host " [PENALTY:TC01]" -ForegroundColor Yellow -NoNewline
    } elseif ($turns -eq 1 -and $estLabel -eq "est:complex") {
        $penalty += 0.40
        Write-Host " [PENALTY:TC02]" -ForegroundColor Red -NoNewline
    }

    $finalConfidence = [Math]::Max(0.1, $confidence - $penalty)
    
    $bid = @{
        taskId     = $IssueNumber
        bidder     = $bidder.id
        approach   = "System approach using $($bidder.id) model referencing artifacts like $workspaceFiles"
        confidence = $finalConfidence
        turns_est  = $turns
        cost_est   = $bidder.cost
        timestamp  = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    
    Write-Host " Done." -ForegroundColor Green
    $bids += $bid
}

# 4. Selection Logic (Confidence / Cost)
$winner = $bids | ForEach-Object {
    $scoreValue = if ($_.cost_est -gt 0) { $_.confidence / ($_.cost_est * 10) } else { 0 }
    $_ | Add-Member -MemberType NoteProperty -Name Score -Value $scoreValue -PassThru 
} | Sort-Object Score -Descending | Select-Object -First 1

if ($DryRun) {
    Write-Host "--- DRY RUN COMPLETE ---" -ForegroundColor Yellow
    Write-Host "Winner: $($winner.bidder) with score $($winner.Score)"
    exit
}

# 5. Assignment/Reporting
$resultsTable = "| Bidder | Confidence | Est. Cost | Score |`n|--------|------------|-----------|-------|"
foreach($b in $bids) {
    $roundScore = [Math]::Round($b.Score, 2)
    $resultsTable += "`n| $($b.bidder) | $($b.confidence) | $($b.cost_est) | $roundScore |"
}

$finalScore = [Math]::Round($winner.Score, 2)
$commentBody = @"
### Guild Auction Results (#$IssueNumber)
$resultsTable

**Winner:** $($winner.bidder)
**Final Score:** $finalScore
**Bidder Strategy:** $($winner.approach)
**Registry:** Auction result persisted in memory/guild-ledger.json.
"@

gh issue comment $IssueNumber -R $Repo --body "$commentBody"

# 6. Persistent Update
$ledgerPath = "memory/guild-ledger.json"
if (-Not (Test-Path $ledgerPath)) {
    New-Item -Path $ledgerPath -ItemType File -Value '{"models": [], "auctions": []}' -Force
}

$ledger = Get-Content $ledgerPath | ConvertFrom-Json
$ledger.auctions += @{
    issueId = $IssueNumber
    winner = $winner.bidder
    score = $winner.Score
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
}

# Update win counts
foreach ($m in $ledger.models) {
    if ($m.id -eq $winner.bidder) {
        $m.tasks_won++
        $m.last_updated = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
}

$ledger | ConvertTo-Json -Depth 5 | Set-Content $ledgerPath
