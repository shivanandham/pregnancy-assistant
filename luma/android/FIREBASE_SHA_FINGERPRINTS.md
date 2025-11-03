# Firebase SHA Fingerprints Configuration

## Release Keystore Fingerprints

Your release keystore has the following SHA fingerprints that need to be added to Firebase Console:

### SHA-1 Fingerprint
```
A7:4B:78:CD:12:18:B2:41:B5:60:BB:FA:68:0E:D7:FC:81:0E:72:13
```

### SHA-256 Fingerprint
```
96:8B:11:8F:8B:D1:A1:76:4E:BD:D2:0F:FA:D0:53:40:34:B7:06:F4:16:B8:D9:7E:CC:16:60:47:0A:F0:C7:E7
```

## Steps to Add Fingerprints to Firebase Console

### 1. Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: **luma-pregnancy-assistant**
3. Click on the gear icon ⚙️ next to "Project Overview"
4. Select **Project settings**

### 2. Navigate to Your Android App
1. Scroll down to **Your apps** section
2. Find your Android app with package name: `com.luma.luma`
3. Click on it or find the **SHA certificate fingerprints** section

### 3. Add SHA Fingerprints
1. Click **Add fingerprint** button
2. Add the **SHA-1** fingerprint:
   ```
   A7:4B:78:CD:12:18:B2:41:B5:60:BB:FA:68:0E:D7:FC:81:0E:72:13
   ```
3. Click **Add fingerprint** again
4. Add the **SHA-256** fingerprint:
   ```
   96:8B:11:8F:8B:D1:A1:76:4E:BD:D2:0F:FA:D0:53:40:34:B7:06:F4:16:B8:D9:7E:CC:16:60:47:0A:F0:C7:E7
   ```
5. Click **Save**

### 4. Download Updated google-services.json
1. After adding the fingerprints, you'll see a notification to download the updated configuration
2. Click **Download google-services.json**
3. Replace the existing file at:
   ```
   luma/android/app/google-services.json
   ```

### 5. Rebuild the App
```bash
cd luma
flutter clean
flutter pub get
flutter run --release
```

## Verification

After adding the fingerprints and rebuilding:

1. **Test Google Sign-In**: Try signing in with Google in the app
2. **Check Firebase Console**: Verify the user appears in Firebase Console → Authentication → Users

## Troubleshooting

### Error Code 10
If you still get error code 10:
- Verify the fingerprints were added correctly in Firebase Console
- Make sure you downloaded the updated `google-services.json`
- Clean and rebuild the app: `flutter clean && flutter pub get && flutter run --release`
- Wait a few minutes for Firebase to propagate the changes

### Multiple Keystores
If you have multiple keystores (debug + release):
- **Debug keystore SHA fingerprints**: For development builds
- **Release keystore SHA fingerprints**: For release/production builds
- **Both should be added** to Firebase Console if you use both build types

### Getting Fingerprints from Keystore
To get SHA fingerprints from any keystore:
```bash
keytool -list -v -keystore path/to/keystore -alias alias-name \
  -storepass keystore-password -keypass key-password
```

Look for:
- **SHA1**: Certificate fingerprints → SHA1
- **SHA256**: Certificate fingerprints → SHA256

