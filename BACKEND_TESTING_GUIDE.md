# Backend Testing Guide - Multi-User Authentication

This guide explains how to test the multi-user backend API with authentication using Postman and other tools.

## 🚀 Quick Start

### 1. **Prerequisites**

- Node.js and npm installed
- PostgreSQL database running
- Firebase project set up
- Backend server running (`npm run dev`)

### 2. **Environment Setup**

Create a `.env` file in the backend directory:

```bash
# Google Gemini API Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key_here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your_firebase_client_email

# Server Configuration
PORT=3000
NODE_ENV=development

# Local PostgreSQL Configuration (Development)
LOCAL_DB_HOST=localhost
LOCAL_DB_PORT=5432
LOCAL_DB_NAME=pregnancy_assistant
LOCAL_DB_USER=postgres
LOCAL_DB_PASSWORD=postgres
```

### 3. **Start the Backend Server**

```bash
cd backend
npm install
npm run dev
```

The server will start on `http://localhost:3000`

## 🧪 Testing Methods

### Method 1: Using Test Setup Script (Recommended)

#### Step 1: Run the Test Setup Script

```bash
cd backend
node test-auth-setup.js
```

This will:
- Create 3 test users in Firebase Auth
- Generate custom tokens for each user
- Print configuration for Postman

#### Step 2: Import Postman Collection

1. Open Postman
2. Import the collection: `backend/postman/Luma-Pregnancy-Assistant-MultiUser.postman_collection.json`
3. Import the environment: `backend/postman/Luma-MultiUser-Testing.postman_environment.json`

#### Step 3: Configure Environment Variables

In Postman, set these environment variables:
- `base_url`: `http://localhost:3000`
- `test_user_1_token`: [token from setup script]
- `test_user_2_token`: [token from setup script]
- `test_user_3_token`: [token from setup script]

#### Step 4: Test Authentication Flow

1. **Sync User**: POST `/api/auth/sync`
   - This creates the user in your database
   - Use the custom token in Authorization header

2. **Get Profile**: GET `/api/auth/profile`
   - Verify user was created successfully

### Method 2: Manual Firebase Token Generation

#### Step 1: Create Test Users in Firebase Console

1. Go to Firebase Console → Authentication → Users
2. Add users manually with email/password
3. Note down the UIDs

#### Step 2: Generate Custom Tokens

Use Firebase Admin SDK to generate custom tokens:

```javascript
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Generate custom token
const customToken = await admin.auth().createCustomToken('USER_UID_HERE');
console.log('Custom Token:', customToken);
```

#### Step 3: Use in Postman

Set the `auth_token` environment variable to your custom token.

## 📋 Testing Scenarios

### Scenario 1: Single User Flow

1. **Setup User**
   - Sync user with `/api/auth/sync`
   - Create pregnancy data with `/api/pregnancy`
   - Create user profile with `/api/user-profile`

2. **Test Data Isolation**
   - Create symptoms, weight entries, appointments
   - Verify all data belongs to the authenticated user

3. **Test Chat Functionality**
   - Create chat session
   - Send messages
   - Verify AI responses include user context

### Scenario 2: Multi-User Data Isolation

1. **User 1 Setup**
   - Use `test_user_1_token`
   - Create pregnancy data and profile
   - Add some symptoms and appointments

2. **User 2 Setup**
   - Use `test_user_2_token`
   - Create different pregnancy data and profile
   - Add different symptoms and appointments

3. **Verify Isolation**
   - Switch between users
   - Verify each user only sees their own data
   - Test that users cannot access each other's data

### Scenario 3: Authentication Edge Cases

1. **Invalid Token**
   - Use an invalid token
   - Verify 401 Unauthorized response

2. **Expired Token**
   - Use an expired token
   - Verify 401 Unauthorized response

3. **Missing Token**
   - Remove Authorization header
   - Verify 401 Unauthorized response

## 🔧 Postman Testing Tips

### 1. **Environment Variables**

Use these variables in your requests:
- `{{base_url}}` - Base URL for API
- `{{auth_token}}` - Current user's auth token
- `{{user_id}}` - Current user's UID
- `{{session_id}}` - Chat session ID

### 2. **Authorization Header**

Always include:
```
Authorization: Bearer {{auth_token}}
```

### 3. **Test Scripts**

Add this to your Postman test scripts to save response data:

```javascript
// Save user ID from auth/sync response
if (pm.response.code === 200) {
    const response = pm.response.json();
    if (response.data && response.data.id) {
        pm.environment.set("user_id", response.data.id);
    }
}

// Save session ID from chat session creation
if (pm.response.code === 200) {
    const response = pm.response.json();
    if (response.data && response.data.id) {
        pm.environment.set("session_id", response.data.id);
    }
}
```

### 4. **Collection Runner**

Use Postman Collection Runner to:
- Run all tests with different users
- Verify data isolation
- Test complete user flows

## 🐛 Common Issues & Solutions

### Issue 1: "Invalid token" Error

**Solution:**
- Verify Firebase configuration in `.env`
- Check that custom token is valid
- Ensure Firebase Admin SDK is properly initialized

### Issue 2: "User not found" Error

**Solution:**
- Run `/api/auth/sync` first to create user in database
- Verify user exists in Firebase Auth
- Check database connection

### Issue 3: "Database connection failed"

**Solution:**
- Verify PostgreSQL is running
- Check database credentials in `.env`
- Run `npm run test:db` to test connection

### Issue 4: "No pregnancy data found"

**Solution:**
- Create pregnancy data first with `/api/pregnancy`
- Verify user has pregnancy data
- Check that pregnancy data belongs to correct user

## 📊 Testing Checklist

### Authentication
- [ ] User sync creates database record
- [ ] Valid tokens work
- [ ] Invalid tokens are rejected
- [ ] Missing tokens are rejected

### Data Isolation
- [ ] User 1 cannot see User 2's data
- [ ] User 2 cannot see User 1's data
- [ ] Each user has separate chat sessions
- [ ] Each user has separate pregnancy data

### API Endpoints
- [ ] Pregnancy data CRUD
- [ ] User profile CRUD
- [ ] Symptoms CRUD
- [ ] Weight entries CRUD
- [ ] Appointments CRUD
- [ ] Chat sessions CRUD
- [ ] Chat messages

### Error Handling
- [ ] 400 Bad Request for invalid data
- [ ] 401 Unauthorized for invalid auth
- [ ] 404 Not Found for missing resources
- [ ] 500 Internal Server Error handling

## 🧹 Cleanup

### Clean Up Test Users

```bash
cd backend
node test-auth-setup.js --cleanup
```

### Clean Up Database

```bash
cd backend
npm run db:reset
```

## 📝 Example Test Sequence

1. **Start with Health Check**
   ```
   GET /health
   ```

2. **Setup User 1**
   ```
   POST /api/auth/sync (with test_user_1_token)
   POST /api/pregnancy (create pregnancy data)
   POST /api/user-profile (create profile)
   ```

3. **Test User 1 Data**
   ```
   POST /api/symptoms (create symptom)
   POST /api/weight (create weight entry)
   POST /api/appointments (create appointment)
   ```

4. **Switch to User 2**
   ```
   Change auth_token to test_user_2_token
   POST /api/auth/sync
   POST /api/pregnancy (create different pregnancy data)
   ```

5. **Verify Data Isolation**
   ```
   GET /api/symptoms (should be empty for User 2)
   GET /api/weight (should be empty for User 2)
   GET /api/appointments (should be empty for User 2)
   ```

6. **Test Chat**
   ```
   POST /api/chat-sessions (create session)
   POST /api/chat (send message)
   ```

This comprehensive testing approach ensures your multi-user backend is working correctly with proper authentication and data isolation.
