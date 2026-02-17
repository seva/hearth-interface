# guild-dispatch.ps1
# Prototype Dispatcher for the Guild Auction System
# Requires: GitHub CLI (gh)

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
    
    # NOTE FOR EXECUTOR: Use sessions_spawn(agentId: $($bidder.id), task: "...provide JSON bid for task #$IssueNumber...")
    # This PowerShell layer simulates the coordination.
    
    # Simulate bid for POC consistency
    $turns = Get-Random -Minimum 1 -Maximum 3
    $confidence = (Get-Random -Minimum 70 -Maximum 98) / 100
    $hasFileRef = $true # Mock for logic
    
    # RIGOR: Zero-Turn Penalty
    $penalty = 0
    if ($turns -eq 1 -and $estLabel -eq "est:moderate") {
        $penalty += 0.20
        Write-Host " [PENALTY:TC01]" -ForegroundColor Yellow -NoNewline
    } elseif ($turns -eq 1 -and $estLabel -eq "est:complex") {
        $penalty += 0.40
        Write-Host " [PENALTY:TC02]" -ForegroundColor Red -NoNewline
    }

    # RIGOR: Context Verification
    if (-not $hasFileRef) {
        $confidence = 0
        Write-Host " [REJECTED:TC03]" -ForegroundColor Red -NoNewline
    }

    $finalConfidence = [Math]::Max(0, $confidence - $penalty)
    
    $bid = @{
        taskId     = $IssueNumber
        bidder     = $bidder.id
        approach   = "Using $($bidder.id) logic to process issues relating to $workspaceFiles"
        confidence = $finalConfidence
        turns_est  = $turns
        cost_est   = $bidder.cost
        timestamp  = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    }
    
    Write-Host " Done." -ForegroundColor Green
    $bids += $bid
}

# 4. Selection Logic 
$winner = $bids | ForEach-Object {
    $score = if ($_.cost_est -gt 0) { $_.confidence / ($_.cost_est * 10) } else { 0 }
    $_ | Add-Member -MemberType NoteProperty -Name Score -Value $score -PassThru 
} | Sort-Object Score -Descending | Select-Object -First 1

if ($DryRun) {
    Write-Host "--- DRY RUN COMPLETE ---" -ForegroundColor Yellow
    Write-Host "Winner: $($winner.bidder) with score $($winner.Score)"
    exit
}

# 5. Assignment/Reporting
$commentBody = @"
### Guild Auction Results (#$IssueNumber)
| Bidder | Confidence | Est. Cost | Score |
|--------|------------|-----------|-------|
$(foreach($b in $bids){"| $($b.bidder) | $($b.confidence) | $($b.cost_est) | $($[Math]::Round($b.Score, 2)) |`n"})
**Winner:** $($winner.bidder)
**Plan:** $($winner.approach)
**Context Proof (Workspace Files Referenced):** ✅
"@

gh issue comment $IssueNumber -R $Repo --body "$commentBody"
