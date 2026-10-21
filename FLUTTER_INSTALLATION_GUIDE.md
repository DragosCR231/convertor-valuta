# Flutter Installation Guide for Windows

## Step 1: Download Flutter SDK

1. Open your browser and go to: https://docs.flutter.dev/get-started/install/windows
2. Click on "Download Flutter SDK" button
3. Or use this direct link: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.3-stable.zip
4. Save the file to your Downloads folder

## Step 2: Extract Flutter

1. Create a folder: `C:\src` (you can use a different location if you prefer)
2. Extract the downloaded zip file to `C:\src`
3. You should now have: `C:\src\flutter`

**IMPORTANT**: Do NOT install Flutter in a directory that:
- Requires elevated privileges (like `C:\Program Files`)
- Contains special characters or spaces

## Step 3: Add Flutter to PATH

### Method 1: Using PowerShell (Recommended)
1. Open PowerShell as Administrator
2. Run this command to add Flutter to your PATH permanently:

```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", [EnvironmentVariableTarget]::User)
```

3. Close and reopen PowerShell

### Method 2: Using GUI
1. Press `Windows + X` and select "System"
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", find "Path" and click "Edit"
5. Click "New" and add: `C:\src\flutter\bin`
6. Click "OK" on all dialogs
7. Close and reopen your terminal

## Step 4: Verify Installation

Open a NEW PowerShell window and run:

```powershell
flutter doctor
```

This will check your environment and display a report. You might see some issues - that's normal!

## Step 5: Install Required Dependencies (if needed)

Flutter doctor might ask you to install:

1. **Visual Studio** (for Windows desktop development)
2. **Android Studio** (for Android app development)
3. **Chrome** (for web development)

For your currency converter app, you can start with Chrome (web) or use an Android emulator.

## Step 6: Run Your App

Once Flutter is installed, navigate to your project and run:

```powershell
cd C:\Users\Student-11\1
flutter pub get
flutter run -d chrome
```

## Quick Commands Reference

```powershell
# Check Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome

# Run on Windows desktop
flutter run -d windows

# See available devices
flutter devices

# Create a new Flutter project
flutter create my_app
```

## Troubleshooting

**Issue**: "flutter is not recognized"
**Solution**: Make sure you closed and reopened PowerShell after adding to PATH

**Issue**: Flutter doctor shows errors
**Solution**: Install the missing dependencies it suggests

**Issue**: No devices available
**Solution**: Install Chrome or run `flutter doctor` to see what's needed

## Next Steps

After installation:
1. Run `flutter doctor` to verify
2. Navigate to your project: `cd C:\Users\Student-11\1`
3. Run `flutter pub get`
4. Run `flutter run -d chrome` to test the currency converter app
