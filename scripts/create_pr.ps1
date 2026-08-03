# Creates a new branch from your current changes, commits them with an
# auto-generated title, pushes the branch, and opens a pull request.
# Never commits to or pushes main/master directly.

$ErrorActionPreference = "Stop"

function Fail($msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

try {
    $repoRoot = git rev-parse --show-toplevel 2>$null
} catch {
    $repoRoot = $null
}
if (-not $repoRoot) { Fail "Not inside a git repository." }
Set-Location $repoRoot

$currentBranch = git rev-parse --abbrev-ref HEAD
Write-Host "Current branch: $currentBranch"

$statusLines = git status --porcelain=1
if (-not $statusLines) {
    Write-Host "No changes to commit. Nothing to do."
    Read-Host "Press Enter to exit"
    exit 0
}

Write-Host ""
Write-Host "Changed files:"
git status --short
Write-Host ""
$confirm = Read-Host "Stage and commit ALL of the above changes? (y/N)"
if ($confirm -notin @("y", "Y")) {
    Write-Host "Cancelled."
    Read-Host "Press Enter to exit"
    exit 0
}

# Build a title from whichever files changed, so it's different every run
$files = $statusLines | ForEach-Object { $_.Substring(3).Trim().Trim('"') }
$names = $files | ForEach-Object { Split-Path $_ -Leaf } | Select-Object -Unique
$count = $files.Count
$shown = $names | Select-Object -First 3
$list = $shown -join ", "
if ($names.Count -gt 3) { $list += " +$($names.Count - 3) more" }
$plural = if ($count -ne 1) { "s" } else { "" }
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$title = "Update $list ($count file$plural changed) - $timestamp"

$base = "main"

if ($currentBranch -eq "main" -or $currentBranch -eq "master") {
    $branchName = "update-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    git checkout -b $branchName
    if ($LASTEXITCODE -ne 0) { Fail "Could not create branch $branchName." }
} else {
    Write-Host "[INFO] Already on branch '$currentBranch'; committing here instead of creating a new one."
    $branchName = $currentBranch
}

Write-Host ""
Write-Host "Title:  $title"
Write-Host "Branch: $branchName"
Write-Host ""

git add -A
git commit -m "$title"
if ($LASTEXITCODE -ne 0) { Fail "Commit failed." }

git push -u origin $branchName
if ($LASTEXITCODE -ne 0) { Fail "Push failed." }

$body = "Auto-generated from local changes on $timestamp."
$ghAvailable = Get-Command gh -ErrorAction SilentlyContinue
$prCreated = $false

if ($ghAvailable) {
    gh pr create --title "$title" --base $base --head $branchName --body "$body"
    if ($LASTEXITCODE -eq 0) { $prCreated = $true }
    else { Write-Host "[WARN] gh pr create failed; falling back to opening the PR page in your browser." }
}

if (-not $prCreated) {
    $originUrl = git remote get-url origin
    $repoPath = $originUrl -replace "^https://github.com/", "" -replace "\.git$", "" -replace "^git@github\.com:", ""
    $encTitle = [uri]::EscapeDataString($title)
    $encBody = [uri]::EscapeDataString($body)
    $url = "https://github.com/$repoPath/compare/$base...${branchName}?expand=1&title=$encTitle&body=$encBody"
    Write-Host ""
    Write-Host "Opening pull request page in your browser:"
    Write-Host $url
    Start-Process $url
}

Write-Host ""
Write-Host "Done."
Read-Host "Press Enter to exit"
