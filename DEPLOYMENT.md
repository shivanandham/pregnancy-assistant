# Deployment Guide for Luma Pregnancy Assistant

## Backend Deployment Options

### Option 1: Railway (Recommended)

1. **Sign up for Railway**:
   - Go to [railway.app](https://railway.app)
   - Sign up with GitHub

2. **Deploy from GitHub**:
   - Connect your GitHub repository
   - Select the `backend` folder as the root directory
   - Railway will automatically detect it's a Node.js project

3. **Set Environment Variables**:
   - Go to your project settings
   - Add environment variable: `PERPLEXITY_API_KEY=your_actual_key`

4. **Get Deployment URL**:
   - Railway will provide a URL like `https://your-app-name.railway.app`
   - Update this URL in `luma/lib/services/api_service.dart`

### Option 2: Render

1. **Sign up for Render**:
   - Go to [render.com](https://render.com)
   - Sign up with GitHub

2. **Create Web Service**:
   - Connect your GitHub repository
   - Select the `backend` folder
   - Choose Node.js as the environment

3. **Configure**:
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Add environment variable: `PERPLEXITY_API_KEY`

### Option 3: Vercel

1. **Install Vercel CLI**:
```bash
npm i -g vercel
```

2. **Deploy**:
```bash
cd backend
vercel
```

3. **Set Environment Variables**:
   - Go to Vercel dashboard
   - Add environment variable in project settings

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: "luma-pregnancy-assistant"
4. Enable Google Analytics (optional)
5. Create project

### 2. Enable Firestore

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in production mode"
4. Select a location close to you
5. Create database

### 3. Add Android App

1. In Project Settings, click "Add app" > Android
2. Package name: `com.luma`
3. App nickname: "Luma Pregnancy Assistant"
4. Download `google-services.json`
5. Place it in `luma/android/app/google-services.json`

### 4. Configure FlutterFire

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Configure Firebase:
```bash
cd luma
flutterfire configure
```

3. Select your Firebase project and platforms (Android)

## Testing the App

### 1. Run in Development Mode

```bash
cd luma
flutter run
```

### 2. Test on Android Device

1. Enable Developer Options on your Android device
2. Enable USB Debugging
3. Connect device via USB
4. Run: `flutter run`

### 3. Build Release APK

```bash
cd luma
flutter build apk --release
```

The APK will be at: `luma/build/app/outputs/flutter-apk/app-release.apk`

## Configuration Checklist

### Backend
- [ ] Deploy backend to cloud service
- [ ] Set PERPLEXITY_API_KEY environment variable
- [ ] Test backend health endpoint
- [ ] Update API service URL in Flutter app

### Firebase
- [ ] Create Firebase project
- [ ] Enable Firestore Database
- [ ] Add Android app with package name `com.luma`
- [ ] Download and place `google-services.json`
- [ ] Configure FlutterFire or update `firebase_options.dart`

### Flutter App
- [ ] Update `lib/services/api_service.dart` with backend URL
- [ ] Update `lib/firebase_options.dart` with Firebase config
- [ ] Test app functionality
- [ ] Build release APK

## Security Considerations

1. **API Key Protection**: Never commit API keys to version control
2. **Firebase Rules**: Use appropriate security rules for your use case
3. **HTTPS**: Ensure all API calls use HTTPS
4. **Data Privacy**: Review what data is stored and ensure compliance

## Troubleshooting

### Backend Issues
- Check environment variables are set correctly
- Verify Perplexity API key is valid
- Check deployment logs for errors
- Test health endpoint manually

### Firebase Issues
- Ensure `google-services.json` is in correct location
- Check Firebase project configuration
- Verify Firestore rules allow read/write
- Check Firebase console for errors

### Flutter Issues
- Run `flutter clean` and `flutter pub get`
- Check Flutter and Dart SDK versions
- Verify all dependencies are compatible
- Check device logs for runtime errors

## Production Checklist

- [ ] Backend deployed and accessible
- [ ] Firebase configured and working
- [ ] API service URL updated in app
- [ ] App tested on Android device
- [ ] Release APK built successfully
- [ ] All features working as expected
- [ ] Medical disclaimers in place
- [ ] Privacy policy reviewed (if applicable)

## Next Steps

1. **Test thoroughly** on your wife's Android device
2. **Customize** the app with any specific features she needs
3. **Add more tracking features** as needed
4. **Consider** adding more educational content
5. **Monitor** usage and gather feedback for improvements

The app is now ready for use! Install the APK on your wife's Android device and she can start tracking her pregnancy journey with Luma.
