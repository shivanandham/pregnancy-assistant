# Android Release Signing Setup Guide

## Problem Fixed
The previous release APKs were signed with debug keys, which caused signature mismatches and installation failures. This has been fixed by implementing proper release signing.

## What Was Changed

1. **Created Release Keystore**: A new release keystore (`app/release.keystore`) has been created
2. **Updated Build Configuration**: `build.gradle.kts` now uses the release keystore for signing
3. **Updated CI/CD**: GitHub Actions workflow now sets up the keystore from secrets

## GitHub Secrets Setup

To enable signing in GitHub Actions builds, you need to add the following secrets:

### Step 1: Encode the Keystore to Base64

```bash
cd luma/android
base64 -i app/release.keystore | pbcopy  # macOS
# or
base64 -i app/release.keystore | xclip -selection clipboard  # Linux
```

### Step 2: Add GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

Add these secrets:

1. **ANDROID_KEYSTORE_BASE64**
   - Value: Paste the base64 encoded keystore (from Step 1)

2. **ANDROID_KEYSTORE_PASSWORD**
   - Value: `luma-release-2024`

3. **ANDROID_KEY_PASSWORD**
   - Value: `luma-release-2024`

4. **ANDROID_KEY_ALIAS**
   - Value: `luma-release`

## Local Development

For local builds, the keystore and `key.properties` are already configured. Just run:

```bash
cd luma
flutter build apk --release
```

## Fixing Device Installation Issues

If you're unable to install the APK on your device after uninstalling the previous version:

### Option 1: Clear App Data (Recommended)
1. Go to **Settings → Apps** (or **Apps & notifications**)
2. Find the app if it's still listed (might show as "Not installed")
3. Tap on it and select **Clear data** and **Clear cache**
4. Try installing the new APK again

### Option 2: Reset App Preferences
1. Go to **Settings → System → Reset options**
2. Tap **Reset app preferences** (this won't delete your data)
3. Try installing the APK again

### Option 3: Use ADB to Clean Install
```bash
adb uninstall com.luma.luma
adb install path/to/luma.apk
```

### Option 4: Factory Reset (Last Resort)
Only if other methods fail. This will delete all data on your device.

## Security Notes

⚠️ **IMPORTANT**: 
- The keystore password shown here (`luma-release-2024`) is for demonstration
- For production, use a strong, unique password
- Keep the keystore file secure and backed up
- If you lose the keystore, you won't be able to update the app with the same package name
- Never commit the keystore or key.properties to version control

## Changing the Keystore Password

If you want to use a different password:

1. Generate a new keystore with your preferred password:
```bash
cd luma/android
keytool -genkey -v -keystore app/release.keystore -alias luma-release \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass YOUR_NEW_PASSWORD -keypass YOUR_NEW_PASSWORD \
  -dname "CN=Luma, OU=Development, O=Luma, L=Unknown, ST=Unknown, C=US"
```

2. Update `key.properties` with the new password
3. Update GitHub secrets with the new password and base64-encoded keystore

