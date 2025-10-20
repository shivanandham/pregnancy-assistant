# Environment Configuration Guide

This guide explains how to set up separate Firebase projects for development and production environments.

## 🏗️ **Architecture Overview**

### **Development Environment**
- **Flutter App**: Uses `luma-pregnancy-assistant-dev` Firebase project
- **Backend**: Uses development Firebase project credentials
- **Database**: Local PostgreSQL
- **Backend URL**: `http://localhost:3000`

### **Production Environment**
- **Flutter App**: Uses `luma-pregnancy-assistant-prod` Firebase project
- **Backend**: Uses production Firebase project credentials
- **Database**: Self-hosted PostgreSQL on DigitalOcean
- **Backend URL**: `https://your-production-backend.com`

## 🔧 **Firebase Project Setup**

### **Step 1: Create Development Firebase Project**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Project name: `luma-pregnancy-assistant-dev`
4. Enable Google Analytics (optional)
5. Enable Google Sign-in authentication
6. Download configuration files:
   - Android: `google-services-dev.json`
   - iOS: `GoogleService-Info-dev.plist`

### **Step 2: Create Production Firebase Project**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Project name: `luma-pregnancy-assistant-prod`
4. Enable Google Analytics (optional)
5. Enable Google Sign-in authentication
6. Download configuration files:
   - Android: `google-services-prod.json`
   - iOS: `GoogleService-Info-prod.plist`

### **Step 3: Generate Service Account Keys**
For each Firebase project:

1. Go to Project Settings → Service Accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Extract the following values:
   - `project_id`
   - `private_key`
   - `client_email`

## 📱 **Flutter Configuration**

### **Environment Detection**
The Flutter app automatically detects the environment:
- **Debug Mode** (`kDebugMode = true`): Development environment
- **Release Mode** (`kReleaseMode = true`): Production environment

### **Configuration Files**
Place the Firebase configuration files in the correct locations:

#### **Development Files:**
```
luma/android/app/google-services-dev.json
luma/ios/Runner/GoogleService-Info-dev.plist
```

#### **Production Files:**
```
luma/android/app/google-services-prod.json
luma/ios/Runner/GoogleService-Info-prod.plist
```

### **Build Configuration**
The app will automatically use the correct configuration based on the build mode:

```bash
# Development build (uses dev Firebase project)
flutter run

# Production build (uses prod Firebase project)
flutter build apk --release
flutter build ios --release
```

## 🖥️ **Backend Configuration**

### **Environment Variables**
Update your `.env` file with both development and production Firebase credentials:

```bash
# Development Firebase Configuration
FIREBASE_PROJECT_ID_DEV=luma-pregnancy-assistant-dev
FIREBASE_PRIVATE_KEY_DEV="-----BEGIN PRIVATE KEY-----\nyour_dev_private_key_here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL_DEV=firebase-adminsdk-xxxxx@luma-pregnancy-assistant-dev.iam.gserviceaccount.com

# Production Firebase Configuration
FIREBASE_PROJECT_ID_PROD=luma-pregnancy-assistant-prod
FIREBASE_PRIVATE_KEY_PROD="-----BEGIN PRIVATE KEY-----\nyour_prod_private_key_here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL_PROD=firebase-adminsdk-xxxxx@luma-pregnancy-assistant-prod.iam.gserviceaccount.com

# Environment
NODE_ENV=development  # or 'production'
```

### **Automatic Project Selection**
The backend automatically selects the correct Firebase project based on `NODE_ENV`:

```javascript
// In middleware/auth.js
const isDevelopment = process.env.NODE_ENV === 'development';

const serviceAccount = {
  projectId: isDevelopment 
    ? process.env.FIREBASE_PROJECT_ID_DEV 
    : process.env.FIREBASE_PROJECT_ID_PROD,
  // ... other config
};
```

## 🧪 **Testing**

### **Development Testing**
```bash
# Backend in development mode
NODE_ENV=development npm run dev

# Flutter app in debug mode
flutter run

# Result: Uses dev Firebase project + local database
```

### **Production Testing**
```bash
# Backend in production mode
NODE_ENV=production npm start

# Flutter app in release mode
flutter build apk --release

# Result: Uses prod Firebase project + production database
```

## 🔍 **Verification**

### **Check Environment in Flutter**
The app logs the current environment on startup:
```
🔧 Firebase Environment: DEVELOPMENT
🔧 Firebase Project ID: luma-pregnancy-assistant-dev
🔧 Backend URL: http://localhost:3000
```

### **Check Environment in Backend**
The backend logs the Firebase project on startup:
```
🔧 Firebase Admin SDK initialized for DEVELOPMENT project: luma-pregnancy-assistant-dev
```

### **Test User Isolation**
1. Create a user in development environment
2. Check Firebase Console → Authentication
3. User should appear in `luma-pregnancy-assistant-dev` project
4. User should NOT appear in `luma-pregnancy-assistant-prod` project

## 🚨 **Important Notes**

### **Security**
- **Never commit** Firebase service account keys to version control
- **Use environment variables** for all sensitive configuration
- **Separate projects** ensure test users don't affect production

### **Data Isolation**
- **Development users** are completely isolated from production users
- **Development database** is separate from production database
- **No cross-contamination** between environments

### **Deployment**
- **Development**: Deploy to local machine or development server
- **Production**: Deploy to DigitalOcean with production environment variables
- **Environment variables** must be set correctly for each deployment

## 🛠️ **Troubleshooting**

### **Common Issues**

#### **"Firebase project not found"**
- Check that the correct Firebase project ID is set in environment variables
- Verify the service account has access to the project

#### **"Invalid private key"**
- Ensure the private key is properly formatted with `\n` characters
- Check that the private key is not truncated

#### **"Authentication failed"**
- Verify that Google Sign-in is enabled in Firebase Console
- Check that the correct OAuth client is configured

#### **"Wrong environment detected"**
- For Flutter: Check if you're running in debug vs release mode
- For Backend: Check the `NODE_ENV` environment variable

### **Debug Commands**
```bash
# Check Flutter environment
flutter run --verbose

# Check Backend environment
NODE_ENV=development npm run dev

# Test Firebase connection
npm run test:auth
```

## 📋 **Checklist**

### **Development Setup**
- [ ] Create `luma-pregnancy-assistant-dev` Firebase project
- [ ] Enable Google Sign-in in development project
- [ ] Download development configuration files
- [ ] Generate development service account key
- [ ] Update backend `.env` with development credentials
- [ ] Test development authentication

### **Production Setup**
- [ ] Create `luma-pregnancy-assistant-prod` Firebase project
- [ ] Enable Google Sign-in in production project
- [ ] Download production configuration files
- [ ] Generate production service account key
- [ ] Update backend `.env` with production credentials
- [ ] Test production authentication

### **Verification**
- [ ] Development users appear only in dev Firebase project
- [ ] Production users appear only in prod Firebase project
- [ ] Backend logs show correct Firebase project
- [ ] Flutter app logs show correct environment
- [ ] Authentication works in both environments

---

**🎉 You now have complete environment separation for your Firebase authentication!**
