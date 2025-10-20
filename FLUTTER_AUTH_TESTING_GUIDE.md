# Flutter Google Sign-in Testing Guide

This guide explains how to test Google Sign-in functionality in your Flutter app during development.

## 🚀 **Quick Start**

### **1. Prerequisites**
- ✅ Backend running on `http://localhost:3000`
- ✅ Firebase project configured
- ✅ Flutter app with Firebase dependencies
- ✅ Android/iOS emulator or physical device

### **2. Run the Test**

```bash
# Navigate to Flutter app directory
cd luma

# Install dependencies
flutter pub get

# Run the app
flutter run

# Navigate to test screen
# In the app, go to: /test-auth
```

## 🔧 **Testing Steps**

### **Step 1: Access Test Screen**
1. Run the Flutter app
2. Navigate to `/test-auth` route
3. You'll see the "Authentication Test" screen

### **Step 2: Test Google Sign-in**
1. Tap "Test Google Sign-in" button
2. Google Sign-in dialog will appear
3. Select your Google account
4. Grant permissions
5. Watch the test results

### **Step 3: Verify Results**
The test will show:
- ✅ **Google Sign-in**: Success/failure
- ✅ **Firebase Authentication**: User creation
- ✅ **Backend Sync**: User sync with your backend
- ✅ **Protected Endpoint**: API access test

### **Step 4: Test Data Creation**
1. After successful sign-in, tap "Test Create Pregnancy Data"
2. This tests creating pregnancy data via your backend API
3. Verify the data appears in your database

## 📱 **Expected Test Results**

### **Successful Test Output:**
```
Test Result: ✅ PASS
Message: Google Sign-in test completed successfully

User Information:
  uid: firebase_user_uid_here
  email: your.email@gmail.com
  displayName: Your Name
  photoURL: https://lh3.googleusercontent.com/...

Backend Test Results:
  Success: true
  Message: Backend authentication successful
  Sync Data: {"success":true,"data":{"id":"...","email":"..."}}
  Protected Endpoint: {"success":true,"data":null}
```

### **Common Issues & Solutions:**

#### **Issue: "Google Sign-in cancelled by user"**
- **Solution**: Make sure you complete the Google Sign-in flow
- **Check**: Google account permissions are granted

#### **Issue: "Firebase authentication failed"**
- **Solution**: Check Firebase configuration files
- **Check**: `google-services.json` (Android) or `GoogleService-Info.plist` (iOS)

#### **Issue: "Backend sync failed"**
- **Solution**: Ensure backend is running on `http://localhost:3000`
- **Check**: Backend logs for authentication errors

#### **Issue: "Failed to get ID token"**
- **Solution**: Check Firebase project configuration
- **Check**: Authentication providers are enabled in Firebase Console

## 🔍 **Debugging Tips**

### **1. Check Backend Logs**
```bash
# In backend directory
npm run dev

# Watch for authentication logs:
# 🔧 Development mode: Using custom token decoding
# ✅ Database connected successfully
```

### **2. Check Flutter Logs**
```bash
# Run Flutter with verbose logging
flutter run --verbose

# Look for Firebase initialization logs
```

### **3. Verify Firebase Configuration**
- **Android**: Check `android/app/google-services.json`
- **iOS**: Check `ios/Runner/GoogleService-Info.plist`
- **Backend**: Check Firebase Admin SDK configuration

## 🧪 **Manual Testing Commands**

### **Test Backend Directly:**
```bash
# Test with curl (replace with actual ID token)
curl -X GET http://localhost:3000/api/pregnancy \
  -H "Authorization: Bearer YOUR_ID_TOKEN_HERE"
```

### **Check Database:**
```bash
# Check if user was created
npm run db:studio

# Look for new user in 'users' table
```

## 📊 **Test Scenarios**

### **Scenario 1: First-time User**
1. Sign in with new Google account
2. Verify user created in database
3. Test creating pregnancy data
4. Verify data is user-specific

### **Scenario 2: Returning User**
1. Sign in with existing Google account
2. Verify user found in database
3. Test accessing existing data
4. Verify data isolation

### **Scenario 3: Multiple Users**
1. Sign in with User A
2. Create pregnancy data
3. Sign out
4. Sign in with User B
5. Verify User B cannot see User A's data

## 🚨 **Troubleshooting**

### **Firebase Configuration Issues:**
```bash
# Check if Firebase is properly initialized
flutter clean
flutter pub get
flutter run
```

### **Backend Connection Issues:**
```bash
# Test backend health
curl http://localhost:3000/health

# Check backend logs
npm run dev
```

### **Authentication Token Issues:**
- Ensure backend is in development mode (`NODE_ENV=development`)
- Check that custom token decoding is working
- Verify Firebase Admin SDK configuration

## 🎯 **Success Criteria**

Your Google Sign-in is working correctly when:

1. ✅ **Google Sign-in completes** without errors
2. ✅ **Firebase authentication** creates/authenticates user
3. ✅ **Backend sync** creates user in database
4. ✅ **Protected endpoints** are accessible with ID token
5. ✅ **Data creation** works (pregnancy data, etc.)
6. ✅ **User isolation** prevents cross-user data access

## 🔄 **Next Steps**

After successful testing:

1. **Integrate with main app**: Update `AuthProvider` to use real authentication
2. **Update API calls**: Modify all API calls to include authentication headers
3. **Test production**: Deploy and test with real Firebase project
4. **User experience**: Implement proper loading states and error handling

## 📝 **Notes**

- **Development vs Production**: The test uses development mode authentication
- **Token Types**: ID tokens are used for production, custom tokens for testing
- **Data Isolation**: Each user's data is completely isolated
- **Security**: Production mode enforces strict Firebase ID token verification

---

**Happy Testing! 🚀**

If you encounter any issues, check the logs and refer to the troubleshooting section above.
