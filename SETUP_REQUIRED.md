# ⚠️ BEFORE YOU RUN THE APP - Read This!

## Required Setup Steps

The offline functionality has been implemented, but **you must complete these steps before the app will build**.

### Step 1: Install Dependencies

```bash
cd frontend
flutter pub get
```

This installs:
- `connectivity_plus: ^5.0.0` - Network monitoring
- `uuid: ^4.0.0` - UUID generation

**Wait for this to complete!**

### Step 2: Generate Hive Adapter (CRITICAL!)

```bash
flutter pub run build_runner build
```

This **must** run successfully to generate:
- `lib/models/offline_contravention_model.g.dart`

**You'll see errors until this completes!**

### Step 3: Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Step 4: Run Tests

```bash
flutter run
```

---

## ✅ Success Indicators

After completing the steps above, you should see:

1. **No build errors** - `flutter analyze` shows no errors
2. **Hive adapter generated** - File `offline_contravention_model.g.dart` exists
3. **App builds** - `flutter build apk` completes without errors
4. **App runs** - `flutter run` launches without crashes

---

## ⚠️ Common Issues

### "uri_has_not_been_generated"
→ Run: `flutter pub run build_runner build`

### "Target of URI doesn't exist: connectivity_plus"
→ Run: `flutter pub get`

### "Undefined class Connectivity"
→ Run: `flutter pub get` then `flutter pub run build_runner build`

### "Expected to find '}'"
→ Already fixed - all syntax errors resolved

### "const_with_non_const"
→ Already fixed - SyncState is now const

---

## 📋 Checklist

Before testing offline features:

- [ ] Ran `flutter pub get`
- [ ] Ran `flutter pub run build_runner build`
- [ ] Verified `offline_contravention_model.g.dart` exists
- [ ] Ran `flutter clean`
- [ ] App builds without errors
- [ ] App runs without crashes
- [ ] No red errors in console

---

## 🚀 Once Setup is Complete

Then you can:

1. **Test offline**: Disable WiFi, create contravention, enable WiFi
2. **See status**: Check for orange/green notifications
3. **Monitor sync**: Watch pending count update
4. **Review docs**: Read all the OFFLINE_*.md files

---

## 📞 If You Get Stuck

1. Check the steps above match your current state
2. Try: `flutter clean && flutter pub get && flutter pub run build_runner build`
3. Verify file exists: `lib/models/offline_contravention_model.g.dart`
4. Check no typos in command - exactly as shown above

---

**Next**: Complete the 4 steps above, then refer to OFFLINE_README.md for documentation.
