#!/usr/bin/env pwsh
# Grafana Setup Script for Codebase Index Monitoring

Write-Host "🚀 Setting up Grafana for Codebase Index Monitoring" -ForegroundColor Green

# Check if .env file exists
if (-not (Test-Path "../../../.env")) {
    Write-Host "❌ .env file not found in project root!" -ForegroundColor Red
    Write-Host "Please run this script from the docker/codebase-index/monitoring directory" -ForegroundColor Yellow
    exit 1
}

# Read current .env file
$envContent = Get-Content "../../../.env" -Raw

# Check if GRAFANA_ADMIN_PASSWORD is already set
if ($envContent -match "GRAFANA_ADMIN_PASSWORD=") {
    Write-Host "✅ GRAFANA_ADMIN_PASSWORD is already configured" -ForegroundColor Green
} else {
    # Generate a secure password
    $securePassword = -join ((33..126) | Get-Random -Count 16 | ForEach-Object {[char]$_})
    
    # Add to .env file
    Add-Content -Path "../../../.env" -Value "`n# Grafana Configuration`nGRAFANA_ADMIN_PASSWORD=$securePassword`nGRAFANA_PORT=3100"
    
    Write-Host "✅ Generated secure Grafana admin password: $securePassword" -ForegroundColor Green
    Write-Host "⚠️  Please save this password in a secure location!" -ForegroundColor Yellow
}

# Create monitoring network if it doesn't exist
Write-Host "🔧 Checking Docker network..." -ForegroundColor Cyan
$networkExists = docker network ls --filter name=monitoring --format "{{.Name}}"

if (-not $networkExists) {
    Write-Host "Creating 'monitoring' Docker network..." -ForegroundColor Cyan
    docker network create monitoring
    Write-Host "✅ Created 'monitoring' Docker network" -ForegroundColor Green
} else {
    Write-Host "✅ 'monitoring' Docker network already exists" -ForegroundColor Green
}

# Verify directory structure
Write-Host "📁 Verifying directory structure..." -ForegroundColor Cyan
$requiredDirs = @("grafana/dashboards", "grafana/provisioning/dashboards", "grafana/provisioning/datasources", "alerts", "grafana/provisioning/plugins", "grafana/provisioning/alerting")

foreach ($dir in $requiredDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "✅ Created directory: $dir" -ForegroundColor Green
    }
}

# Create minimal configuration files to prevent Grafana provisioning errors
Write-Host "📄 Creating minimal provisioning configuration files..." -ForegroundColor Cyan

# Create empty plugins provisioning file if it doesn't exist
$pluginsConfigPath = "grafana/provisioning/plugins/plugins.yml"
if (-not (Test-Path $pluginsConfigPath)) {
    Set-Content -Path $pluginsConfigPath -Value "apiVersion: 1`napps: []`nplugins: []"
    Write-Host "✅ Created plugins provisioning file: $pluginsConfigPath" -ForegroundColor Green
}

# Create empty alerting provisioning file if it doesn't exist
$alertingConfigPath = "grafana/provisioning/alerts.yml"
if (-not (Test-Path $alertingConfigPath)) {
    Set-Content -Path $alertingConfigPath -Value "apiVersion: 1`ngroups: []"
    Write-Host "✅ Created alerting provisioning file: $alertingConfigPath" -ForegroundColor Green
}

Write-Host "`n🎉 Grafana setup completed successfully!" -ForegroundColor Green
Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Review the .env file for your Grafana admin password" -ForegroundColor White
Write-Host "2. Start the monitoring stack: docker-compose -f docker-compose.monitoring.yml up -d" -ForegroundColor White
Write-Host "3. Access Grafana at: http://localhost:3100" -ForegroundColor White
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: [see GRAFANA_ADMIN_PASSWORD in .env]" -ForegroundColor White