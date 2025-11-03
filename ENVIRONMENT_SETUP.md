# Environment Configuration Guide

This guide explains the current Firebase configuration setup for the Luma Pregnancy Assistant app.

## 🏗️ **Architecture Overview**

### **Current Setup**
- **Flutter App**: Uses a single Firebase project (`luma-pregnancy-assistant`) for all environments
- **Backend**: Uses the same Firebase project for authentication
- **Configuration Files**: Fixed location - no environment-based switching

### **Firebase Project**
- **Project Name**: `luma-pregnancy-assistant`
- **Project ID**: `luma-pregnancy-assistant`
- **Used for**: Both development and production builds

## 🔧 **Firebase Project Setup**

### **Step 1: Firebase Project Configuration**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `luma-pregnancy-assistant`
3. Ensure Google Sign-in authentication is enabled
4. Configure Android app with package name: `com.luma.luma`
5. Configure iOS app with bundle ID: `com.luma.luma`

### **Step 2: Add SHA Fingerprints (Android)**
1. Get your debug keystore SHA-1 and SHA-256 fingerprints:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
2. Go to Firebase Console → Project Settings → Your apps → Android app
3. Click "Add fingerprint"
4. Add both SHA-1 and SHA-256 fingerprints
5. Download the updated `google-services.json`

### **Step 3: Download Configuration Files**
1. **Android**: Download `google-services.json` from Firebase Console
2. **iOS**: Download `GoogleService-Info.plist` from Firebase Console
3. Place files in fixed locations:
   - Android: `luma/android/app/google-services.json`
   - iOS: `luma/ios/Runner/GoogleService-Info.plist`

**⚠️ Important**: These files are gitignored (secrets) and must be manually placed in the correct locations.

## 📱 **Flutter Configuration**

### **Configuration Files**
The app uses a single fixed configuration file for each platform:

#### **Android:**
```
luma/android/app/google-services.json
```

#### **iOS:**
```
luma/ios/Runner/GoogleService-Info.plist
```

### **Firebase Configuration in Code**
The Flutter app uses `FirebaseConfig` class for Firebase project configuration:

```dart
// Located in luma/lib/config/firebase_config.dart
class FirebaseConfig {
  static String get projectId => 'luma-pregnancy-assistant';
  // Single project for all environments
}
```

### **Build Configuration**
All builds (debug and release) use the same Firebase configuration files:

```bash
# Debug build
flutter run

# Release build
flutter build apk --release
flutter build ios --release
```

Both builds use the same `google-services.json` and `GoogleService-Info.plist` files.

## 🖥️ **Backend Configuration**

### **Environment Variables**
The backend uses Firebase Admin SDK with environment-specific credentials if needed:

```bash
# Firebase Configuration (if using service account)
FIREBASE_PROJECT_ID=luma-pregnancy-assistant
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@luma-pregnancy-assistant.iam.gserviceaccount.com
```

### **Backend Authentication**
The backend validates Firebase ID tokens from the app using the same Firebase project.

## 🧪 **Testing**

### **Development Testing**
```bash
# Backend in development mode
npm run dev

# Flutter app in debug mode
flutter run
```

### **Production Testing**
```bash
# Backend in production mode
npm start

# Flutter app in release mode
flutter build apk --release
```

Both environments use the same Firebase project, but authentication is still secure and validated.

## 🔍 **Verification**

### **Check Configuration Files**
Verify that configuration files are in the correct locations:

```bash
# Check Android config
ls -la luma/android/app/google-services.json

# Check iOS config
ls -la luma/ios/Runner/GoogleService-Info.plist
```

### **Check Firebase Connection**
1. Run the app: `flutter run`
2. Try Google Sign-In
3. Verify user appears in Firebase Console → Authentication

### **Check SHA Fingerprints**
If Google Sign-In fails with error code 10:
1. Get your current SHA fingerprints
2. Verify they're added in Firebase Console
3. Download updated `google-services.json`
4. Rebuild the app

See `luma/GOOGLE_SIGNIN_FIX.md` for detailed troubleshooting.

## 🚨 **Important Notes**

### **Security**
- **Never commit** `google-services.json` or `GoogleService-Info.plist` to version control
- These files contain sensitive API keys and are gitignored
- Keep these files secure and don't share them publicly

### **Configuration Updates**
- If you need to update Firebase configuration, download new files from Firebase Console
- Replace the files in their fixed locations
- Clean and rebuild the app after updating:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### **SHA Fingerprint Updates**
- When adding new devices or keystores, add their SHA fingerprints to Firebase Console
- Download updated `google-services.json` after adding fingerprints
- This is especially important for release builds with different keystores

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **"Google Sign-In Error Code 10"**
- SHA fingerprint mismatch
- See `luma/GOOGLE_SIGNIN_FIX.md` for detailed steps
- Get your SHA fingerprints and add them to Firebase Console

#### **"Firebase configuration file not found"**
- Verify `google-services.json` is in `luma/android/app/`
- Verify `GoogleService-Info.plist` is in `luma/ios/Runner/`
- Check that files are not gitignored locally

#### **"Invalid Firebase project"**
- Verify the project ID matches: `luma-pregnancy-assistant`
- Check that configuration files are from the correct Firebase project
- Ensure package name matches: `com.luma.luma`

#### **"Configuration file out of date"**
- Download fresh configuration files from Firebase Console
- Replace existing files
- Clean and rebuild the app

### **Debug Commands**
```bash
# Get SHA fingerprints
cd luma
./scripts/get-sha-fingerprints.sh

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check Firebase connection
flutter run --verbose
```

## 📋 **Checklist**

### **Initial Setup**
- [ ] Firebase project `luma-pregnancy-assistant` exists
- [ ] Google Sign-in enabled in Firebase Console
- [ ] Android app configured with package name `com.luma.luma`
- [ ] iOS app configured with bundle ID `com.luma.luma`
- [ ] SHA fingerprints added to Firebase Console (Android)
- [ ] `google-services.json` downloaded and placed in `luma/android/app/`
- [ ] `GoogleService-Info.plist` downloaded and placed in `luma/ios/Runner/`

### **Verification**
- [ ] Flutter app builds successfully
- [ ] Google Sign-In works in debug mode
- [ ] Google Sign-In works in release mode (if tested)
- [ ] Users appear in Firebase Console → Authentication
- [ ] Backend authentication works correctly

---

**📝 Note**: This setup uses a single Firebase project for simplicity. If you need separate development and production environments in the future, you would need to:
1. Create separate Firebase projects
2. Implement environment-based file switching in build configuration
3. Update the configuration management code
