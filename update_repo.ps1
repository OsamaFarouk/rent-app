# Rent App - End of Day GitHub Update Script

$RepoPath = "D:\rent_app"

Set-Location $RepoPath

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Rent App - GitHub End of Day Update" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verify this is a Git repository
if (-not (Test-Path ".git")) {
    Write-Host "ERROR: Git repository not found." -ForegroundColor Red
    exit 1
}

# Run Flutter analyzer
Write-Host "Running Flutter analyze..." -ForegroundColor Yellow
flutter analyze

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Flutter analyze failed. Nothing was committed." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Flutter analyze passed." -ForegroundColor Green

# Check for project changes
$status = git status --porcelain

if (-not $status) {
    Write-Host ""
    Write-Host "No changes found. Repository is already up to date." -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "Changes detected:" -ForegroundColor Yellow
git status --short

Write-Host ""

# Stage changes
git add .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to stage changes." -ForegroundColor Red
    exit 1
}

# Create automatic commit message
$date = Get-Date -Format "yyyy-MM-dd"
$time = Get-Date -Format "HH:mm"

$CommitMessage = "chore: sync Rent App updates $date $time"

Write-Host "Creating commit:" -ForegroundColor Yellow
Write-Host $CommitMessage

git commit -m "$CommitMessage"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Commit failed." -ForegroundColor Red
    exit 1
}

# Push to GitHub
Write-Host ""
Write-Host "Pushing to GitHub..." -ForegroundColor Yellow

git push origin main

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "Push failed. Check the Git output above." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " GitHub repository updated successfully!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""