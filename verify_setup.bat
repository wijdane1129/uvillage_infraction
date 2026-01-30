@echo off
REM Offline Functionality - Setup Verification Script
REM Run this from: c:\Users\Lenovo\Desktop\uvillage_infraction\frontend

echo.
echo ========================================
echo Offline Setup Verification Script
echo ========================================
echo.

REM Check if flutter is available
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter not found in PATH
    echo Please install Flutter or add it to PATH
    exit /b 1
)
echo [OK] Flutter is installed

REM Check if pubspec.yaml exists
if not exist "pubspec.yaml" (
    echo ERROR: pubspec.yaml not found
    echo Make sure you're in the frontend directory
    exit /b 1
)
echo [OK] In correct directory (frontend)

REM Check if offline packages are in pubspec.yaml
findstr "connectivity_plus" pubspec.yaml >nul
if errorlevel 1 (
    echo [WARNING] connectivity_plus not found in pubspec.yaml
    echo Run: flutter pub get
) else (
    echo [OK] connectivity_plus found in pubspec.yaml
)

findstr "uuid" pubspec.yaml >nul
if errorlevel 1 (
    echo [WARNING] uuid not found in pubspec.yaml
    echo Run: flutter pub get
) else (
    echo [OK] uuid found in pubspec.yaml
)

REM Check if lib/models/offline_contravention_model.dart exists
if not exist "lib\models\offline_contravention_model.dart" (
    echo [ERROR] offline_contravention_model.dart not found
    exit /b 1
)
echo [OK] offline_contravention_model.dart exists

REM Check if offline_contravention_model.g.dart was generated
if not exist "lib\models\offline_contravention_model.g.dart" (
    echo [WARNING] offline_contravention_model.g.dart NOT generated
    echo You need to run: flutter pub run build_runner build
) else (
    echo [OK] offline_contravention_model.g.dart generated
)

REM Check if other offline services exist
if not exist "lib\services\offline_storage_service.dart" (
    echo [ERROR] offline_storage_service.dart not found
    exit /b 1
)
echo [OK] offline_storage_service.dart exists

if not exist "lib\services\connectivity_service.dart" (
    echo [ERROR] connectivity_service.dart not found
    exit /b 1
)
echo [OK] connectivity_service.dart exists

if not exist "lib\services\sync_manager.dart" (
    echo [ERROR] sync_manager.dart not found
    exit /b 1
)
echo [OK] sync_manager.dart exists

if not exist "lib\providers\offline_provider.dart" (
    echo [ERROR] offline_provider.dart not found
    exit /b 1
)
echo [OK] offline_provider.dart exists

if not exist "lib\widgets\sync_status_indicator.dart" (
    echo [ERROR] sync_status_indicator.dart not found
    exit /b 1
)
echo [OK] sync_status_indicator.dart exists

echo.
echo ========================================
echo Setup Verification Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Run: flutter pub run build_runner build
echo 3. Run: flutter clean
echo 4. Run: flutter build apk --release
echo.
echo Then test the offline features!
echo.
