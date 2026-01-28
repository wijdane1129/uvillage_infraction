# Script de test du système multilingue (Windows PowerShell)
# Utilisation: .\test_multilingual.ps1

Write-Host "================================" -ForegroundColor Cyan
Write-Host "🧪 TEST SYSTÈME MULTILINGUE" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Vérifier les fichiers ARB Flutter
Write-Host "[1/5]" -ForegroundColor Yellow -NoNewline
Write-Host " Vérification des fichiers ARB Flutter..."
$enArb = Test-Path "frontend/lib/l10n/app_en.arb"
$frArb = Test-Path "frontend/lib/l10n/app_fr.arb"

if ($enArb -and $frArb) {
    Write-Host "✓ Fichiers ARB trouvés" -ForegroundColor Green
    $enCount = (Get-Content "frontend/lib/l10n/app_en.arb" -Raw | Select-String '"' -All).Matches.Count
    $frCount = (Get-Content "frontend/lib/l10n/app_fr.arb" -Raw | Select-String '"' -All).Matches.Count
    Write-Host "  - EN: ~$($enCount/2) clés"
    Write-Host "  - FR: ~$($frCount/2) clés"
} else {
    Write-Host "✗ Fichiers ARB manquants" -ForegroundColor Red
}
Write-Host ""

# Test 2: Vérifier les fichiers properties backend
Write-Host "[2/5]" -ForegroundColor Yellow -NoNewline
Write-Host " Vérification des fichiers properties Backend..."
$enProps = Test-Path "backend/src/main/resources/messages.properties"
$frProps = Test-Path "backend/src/main/resources/messages_fr.properties"

if ($enProps -and $frProps) {
    Write-Host "✓ Fichiers properties trouvés" -ForegroundColor Green
    $enKeys = (Select-String "=" "backend/src/main/resources/messages.properties").Count
    $frKeys = (Select-String "=" "backend/src/main/resources/messages_fr.properties").Count
    Write-Host "  - EN: ~$enKeys clés"
    Write-Host "  - FR: ~$frKeys clés"
} else {
    Write-Host "✗ Fichiers properties manquants" -ForegroundColor Red
}
Write-Host ""

# Test 3: Vérifier configuration i18n
Write-Host "[3/5]" -ForegroundColor Yellow -NoNewline
Write-Host " Vérification configuration i18n..."
$i18nExists = Test-Path "backend/src/main/java/com/uvillage/infractions/config/I18nConfiguration.java"
if ($i18nExists) {
    Write-Host "✓ I18nConfiguration trouvée" -ForegroundColor Green
} else {
    Write-Host "✗ I18nConfiguration manquante" -ForegroundColor Red
}
Write-Host ""

# Test 4: Vérifier MessageUtil
Write-Host "[4/5]" -ForegroundColor Yellow -NoNewline
Write-Host " Vérification MessageUtil..."
$messageUtilExists = Test-Path "backend/src/main/java/com/uvillage/infractions/util/MessageUtil.java"
if ($messageUtilExists) {
    Write-Host "✓ MessageUtil trouvée" -ForegroundColor Green
} else {
    Write-Host "✗ MessageUtil manquante" -ForegroundColor Red
}
Write-Host ""

# Test 5: Vérifier main.dart configuration
Write-Host "[5/5]" -ForegroundColor Yellow -NoNewline
Write-Host " Vérification configuration main.dart..."
$mainDartContent = Get-Content "frontend/lib/main.dart" -Raw
if ($mainDartContent -match "localizationsDelegates") {
    Write-Host "✓ localizationsDelegates configurées" -ForegroundColor Green
} else {
    Write-Host "✗ localizationsDelegates manquantes" -ForegroundColor Red
}
Write-Host ""

Write-Host "================================" -ForegroundColor Green
Write-Host "✅ Tests de configuration terminés!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host ""
Write-Host "🚀 Prochaines étapes:" -ForegroundColor Cyan
Write-Host "   1. cd frontend && flutter pub get"
Write-Host "   2. flutter run -d chrome"
Write-Host "   3. Cliquer sur le bouton de langue (EN/FR)"
Write-Host "   4. Vérifier que l'interface change de langue"
Write-Host ""
