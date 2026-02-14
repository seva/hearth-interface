param([string]$repo = "seva/hearth-interface")
$gh = "C:\Program Files\GitHub CLI\gh.exe"

function Get-Next($label) {
    $json = & $gh issue list -R $repo -l $label -s open -S "sort:created-asc" --limit 1 --json number,title,body
    if ($json) { return ($json | ConvertFrom-Json) }
    return $null
}

$task = Get-Next "P0"
if (!$task) { $task = Get-Next "P1" }
if (!$task) { $task = Get-Next "P2" }

if ($task) {
    Write-Host "NEXT_TASK: Issue #$($task.number) - $($task.title)"
    Write-Host "BODY: $($task.body)"
    Write-Host "ACTION: Execute this task. If blocked, create a new issue and move on. When done, 'gh issue close $($task.number)'."
} else {
    Write-Host "NO_OPEN_TASKS"
}
