# Flutter Installation Script for Windows
# Run this script in PowerShell as Administrator

Write-Host "Flutter Installation Script" -ForegroundColor Green
Write-Host "===========================" -ForegroundColor Green
Write-Host ""

# Create installation directory
$flutterPath = "C:\src\flutter"
$flutterBin = "$flutterPath\bin"

Write-Host "Step 1: Creating installation directory..." -ForegroundColor Yellow
if (-not (Test-Path "C:\src")) {
    New-Item -ItemType Directory -Path "C:\src" | Out-Null
    Write-Host "Created C:\src directory" -ForegroundColor Green
}

# Download Flutter SDK
Write-Host ""
Write-Host "Step 2: Downloading Flutter SDK..." -ForegroundColor Yellow
Write-Host "This may take several minutes depending on your internet connection..." -ForegroundColor Cyan
$flutterZip = "C:\src\flutter_windows_stable.zip"
$flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip"

try {
    Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip
    Write-Host "Download completed!" -ForegroundColor Green
} catch {
    Write-Host "Error downloading Flutter. Please download manually from:" -ForegroundColor Red
    Write-Host "https://docs.flutter.dev/get-started/install/windows" -ForegroundColor Yellow
    exit 1
}

# Extract Flutter
Write-Host ""
Write-Host "Step 3: Extracting Flutter SDK..." -ForegroundColor Yellow
if (Test-Path $flutterPath) {
    Write-Host "Flutter directory already exists. Removing old installation..." -ForegroundColor Yellow
    Remove-Item -Path $flutterPath -Recurse -Force
}

Expand-Archive -Path $flutterZip -DestinationPath "C:\src" -Force
Write-Host "Extraction completed!" -ForegroundColor Green

# Add to PATH
Write-Host ""
Write-Host "Step 4: Adding Flutter to PATH..." -ForegroundColor Yellow

$userPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User)

if ($userPath -notlike "*$flutterBin*") {
    [Environment]::SetEnvironmentVariable("Path", $userPath + ";$flutterBin", [EnvironmentVariableTarget]::User)
    Write-Host "Flutter added to PATH!" -ForegroundColor Green
} else {
    Write-Host "Flutter is already in PATH" -ForegroundColor Yellow
}

# Clean up
Write-Host ""
Write-Host "Step 5: Cleaning up..." -ForegroundColor Yellow
Remove-Item -Path $flutterZip -Force
Write-Host "Cleanup completed!" -ForegroundColor Green

# Final instructions
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Flutter Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Close this PowerShell window" -ForegroundColor Cyan
Write-Host "2. Open a NEW PowerShell window" -ForegroundColor Cyan
Write-Host "3. Run: flutter doctor" -ForegroundColor Cyan
Write-Host "4. Navigate to your project: cd C:\Users\Student-11\1" -ForegroundColor Cyan
Write-Host "5. Run: flutter pub get" -ForegroundColor Cyan
Write-Host "6. Run: flutter run -d chrome" -ForegroundColor Cyan
Write-Host ""
