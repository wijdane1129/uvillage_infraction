#!/bin/bash
# Script de test du système multilingue
# Utilisation: bash test_multilingual.sh

echo "================================"
echo "🧪 TEST SYSTÈME MULTILINGUE"
echo "================================"
echo ""

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Vérifier les fichiers ARB Flutter
echo "${YELLOW}[1/5]${NC} Vérification des fichiers ARB Flutter..."
if [ -f "frontend/lib/l10n/app_en.arb" ] && [ -f "frontend/lib/l10n/app_fr.arb" ]; then
    echo -e "${GREEN}✓ Fichiers ARB trouvés${NC}"
    EN_COUNT=$(grep -c '"' frontend/lib/l10n/app_en.arb)
    FR_COUNT=$(grep -c '"' frontend/lib/l10n/app_fr.arb)
    echo "  - EN: ~$EN_COUNT clés"
    echo "  - FR: ~$FR_COUNT clés"
else
    echo -e "${RED}✗ Fichiers ARB manquants${NC}"
fi
echo ""

# Test 2: Vérifier les fichiers properties backend
echo "${YELLOW}[2/5]${NC} Vérification des fichiers properties Backend..."
if [ -f "backend/src/main/resources/messages.properties" ] && [ -f "backend/src/main/resources/messages_fr.properties" ]; then
    echo -e "${GREEN}✓ Fichiers properties trouvés${NC}"
    EN_KEYS=$(grep -c '=' backend/src/main/resources/messages.properties)
    FR_KEYS=$(grep -c '=' backend/src/main/resources/messages_fr.properties)
    echo "  - EN: ~$EN_KEYS clés"
    echo "  - FR: ~$FR_KEYS clés"
else
    echo -e "${RED}✗ Fichiers properties manquants${NC}"
fi
echo ""

# Test 3: Vérifier configuration i18n
echo "${YELLOW}[3/5]${NC} Vérification configuration i18n..."
if grep -q "class I18nConfiguration" backend/src/main/java/com/uvillage/infractions/config/I18nConfiguration.java 2>/dev/null; then
    echo -e "${GREEN}✓ I18nConfiguration trouvée${NC}"
else
    echo -e "${RED}✗ I18nConfiguration manquante${NC}"
fi
echo ""

# Test 4: Vérifier MessageUtil
echo "${YELLOW}[4/5]${NC} Vérification MessageUtil..."
if grep -q "public String getMessage" backend/src/main/java/com/uvillage/infractions/util/MessageUtil.java 2>/dev/null; then
    echo -e "${GREEN}✓ MessageUtil trouvée${NC}"
else
    echo -e "${RED}✗ MessageUtil manquante${NC}"
fi
echo ""

# Test 5: Vérifier main.dart configuration
echo "${YELLOW}[5/5]${NC} Vérification configuration main.dart..."
if grep -q "localizationsDelegates" frontend/lib/main.dart 2>/dev/null; then
    echo -e "${GREEN}✓ localizationsDelegates configurées${NC}"
else
    echo -e "${RED}✗ localizationsDelegates manquantes${NC}"
fi
echo ""

echo "================================"
echo "✅ Tests de configuration terminés!"
echo "================================"
echo ""
echo "🚀 Prochaines étapes:"
echo "   1. cd frontend && flutter pub get"
echo "   2. flutter run -d chrome"
echo "   3. Cliquer sur le bouton de langue (EN/FR)"
echo "   4. Vérifier que l'interface change de langue"
