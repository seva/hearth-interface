# guild-audit.ps1
# Truth Audit Helper for the Guild Auction System
# Verifies mechanism accuracy by comparing auction winners against historical executors.

param (
    [string]$Repo = "seva/hearth-interface"
)

Write-Host "--- Starting Guild Mechanism Truth Audit ---" -ForegroundColor Cyan

# Historical Ground Truth (Manual Mapping for Audit)
$groundTruth = @{
    46 = "coder" # Unit Tests: DeepSeek
    49 = "coder" # Security Audit: DeepSeek
    47 = "coder" # Frontend Update: Gemini
    55 = "main"  # Timezone Fix: Gemini (Main)
}

$results = @()
$matchesCount = 0
$totalCount = 0

foreach ($id in $groundTruth.Keys) {
    Write-Host "Auditing legacy task #$id... " -NoNewline
    
    # Run a dry-run auction to see who the mechanism picks
    $auctionOutput = powershell -File scripts/guild-dispatch.ps1 -IssueNumber $id -DryRun | Out-String
    
    # Parse winner from output line "Winner: <id> with score <score>"
    if ($auctionOutput -match "Winner: ([a-z]+)") {
        $mechanismPick = $Matches[1]
        $historicalAgent = $groundTruth[$id]
        
        # Mapping model IDs to Agent roles
        $mechanismRole = "unknown"
        if ($mechanismPick -eq "ds") { $mechanismRole = "coder" }
        elseif ($mechanismPick -eq "gemini") { $mechanismRole = "coder" } # coder primary is gemini-pro
        elseif ($mechanismPick -eq "flash") { $mechanismRole = "main" }  # main primary is flash
        
        $match = ($mechanismRole -eq $historicalAgent)
        $totalCount++
        
        if ($match) {
            Write-Host "MATCH" -ForegroundColor Green
            $matchesCount++
        } else {
            Write-Host "MISMATCH (Picked: $mechanismRole ($mechanismPick), Actual: $historicalAgent)" -ForegroundColor Yellow
        }
    } else {
        Write-Host "FAILED TO PARSE" -ForegroundColor Red
    }
}

$accuracy = if ($totalCount -gt 0) { [Math]::Round(($matchesCount / $totalCount) * 100, 2) } else { 0 }
Write-Host "--- Audit Complete. Mechanism Accuracy: $accuracy% ($matchesCount/$totalCount) ---" -ForegroundColor Cyan
