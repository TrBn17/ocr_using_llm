# PowerShell script to run CI/CD checks locally before pushing

Write-Host "🔍 Running local CI/CD checks..." -ForegroundColor Cyan

function Print-Status {
    param(
        [int]$ExitCode,
        [string]$TestName
    )
    
    if ($ExitCode -eq 0) {
        Write-Host "✅ $TestName passed" -ForegroundColor Green
    } else {
        Write-Host "❌ $TestName failed" -ForegroundColor Red
        exit 1
    }
}

# Check if we're in the right directory
if (-not (Test-Path "src\requirements.txt")) {
    Write-Host "❌ Please run this script from the project root directory" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
Set-Location src
pip install -r requirements.txt
pip install flake8 black isort pytest pytest-cov bandit safety
Set-Location ..

Write-Host "`n1. Running linting checks..." -ForegroundColor Yellow

Write-Host "🔍 Flake8 syntax check..." -ForegroundColor Cyan
flake8 src\ --count --select=E9,F63,F7,F82 --show-source --statistics
Print-Status $LASTEXITCODE "Flake8 syntax check"

Write-Host "🔍 Flake8 full check..." -ForegroundColor Cyan
flake8 src\ --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
Print-Status $LASTEXITCODE "Flake8 full check"

Write-Host "🎨 Black formatting check..." -ForegroundColor Cyan
black --check src\
Print-Status $LASTEXITCODE "Black formatting"

Write-Host "📚 Import sorting check..." -ForegroundColor Cyan
isort --check-only src\
Print-Status $LASTEXITCODE "Import sorting"

Write-Host "`n2. Running tests..." -ForegroundColor Yellow

Write-Host "🧪 Running pytest..." -ForegroundColor Cyan
python -m pytest tests\ -v --tb=short
Print-Status $LASTEXITCODE "Tests"

Write-Host "🔧 Basic functionality test..." -ForegroundColor Cyan
Set-Location src
python -c "from app.simple_extract import sanitize_filename; print('✅ Basic import test passed')"
Print-Status $LASTEXITCODE "Basic functionality"
Set-Location ..

Write-Host "`n3. Running security checks..." -ForegroundColor Yellow

Write-Host "🛡️ Bandit security scan..." -ForegroundColor Cyan
bandit -r src\ -f json -o bandit-report.json
Print-Status $LASTEXITCODE "Bandit security scan"

Write-Host "🔐 Safety vulnerability check..." -ForegroundColor Cyan
Set-Location src
safety check -r requirements.txt
Print-Status $LASTEXITCODE "Safety check"
Set-Location ..

Write-Host "`n🎉 All checks passed! Ready to push." -ForegroundColor Green
