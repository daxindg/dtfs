# Windows Package Installer - Simplified and Extensible
# Add packages to the $packages array to extend functionality

Write-Host "=== Windows Package Installer ===" -ForegroundColor Green

# Verify winget availability
try {
    $null = Get-Command winget -ErrorAction Stop
} catch {
    Write-Host "Error: winget not found. Install Windows Package Manager first." -ForegroundColor Red
    exit 1
}

# Define packages to install - Add more packages here as needed
$packages = @(
    @{
        Name = "Obsidian"
        Id = "Obsidian.Obsidian"
        Description = "Knowledge management and note-taking app"
    }
)

# Install a single package
function Install-Package {
    param($Package)

    Write-Host "`nChecking $($Package.Name)..." -ForegroundColor White

    # Check if already installed
    try {
        $installed = winget list --id $Package.Id --accept-source-agreements | Select-String $Package.Id
    } catch {
        $installed = $false
    }

    if ($installed) {
        Write-Host "[OK] Already installed" -ForegroundColor Green
        return "skipped"
    }

    # Install the package
    Write-Host "Installing..." -ForegroundColor Cyan
    try {
        winget install --id $Package.Id --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Installation successful!" -ForegroundColor Green
            return "installed"
        }
        throw "Installation failed with exit code $LASTEXITCODE"
    } catch {
        Write-Host "[ERROR] $_" -ForegroundColor Red
        return "failed"
    }
}

# Process all packages
Write-Host "`nProcessing $($packages.Count) package(s)..." -ForegroundColor Yellow
Write-Host ("-" * 40)

$results = @{
    installed = 0
    skipped = 0
    failed = 0
}

foreach ($pkg in $packages) {
    switch (Install-Package -Package $pkg) {
        "installed" { $results.installed++ }
        "skipped" { $results.skipped++ }
        "failed" { $results.failed++ }
    }
}

# Display summary
Write-Host "`n" + ("=" * 40) -ForegroundColor White
Write-Host "Installation Summary:" -ForegroundColor Green
Write-Host "  Installed: $($results.installed)" -ForegroundColor Green
Write-Host "  Skipped: $($results.skipped)" -ForegroundColor Blue
Write-Host "  Failed: $($results.failed)" -ForegroundColor Red

if ($results.failed -gt 0) {
    Write-Host "`nTip: Run 'winget install <package-id>' manually for failed packages" -ForegroundColor Yellow
}

Write-Host "`nPress Enter to exit..."
Read-Host
