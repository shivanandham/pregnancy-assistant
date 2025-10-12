# Luma Pregnancy Assistant API Testing

This directory contains Postman collections and environments for testing the Luma Pregnancy Assistant API.

## Files

- `Luma-Pregnancy-Assistant-API.postman_collection.json` - Complete API test collection
- `Luma-Development.postman_environment.json` - Development environment variables
- `test-scripts.js` - Test scripts for automated validation
- `README.md` - This documentation

## Setup

### 1. Import into Postman

1. Open Postman
2. Click "Import" button
3. Import both files:
   - `Luma-Pregnancy-Assistant-API.postman_collection.json`
   - `Luma-Development.postman_environment.json`
4. Select the "Luma Development" environment

### 2. Start the Backend Server

```bash
cd backend
NODE_ENV=development node server.js
```

### 3. Run Tests

#### Option A: Manual Testing in Postman
1. Select the "Luma Development" environment
2. Run individual requests or the entire collection
3. Check the "Tests" tab for automated validations

#### Option B: Automated Testing with Newman
```bash
cd backend
node scripts/run-api-tests.js
```

## Test Coverage

### Health Check
- ✅ Server status
- ✅ Database connection
- ✅ Environment info

### User Profile
- ✅ Create profile
- ✅ Get profile
- ✅ Update profile
- ✅ BMI calculations
- ✅ Medical context

### Pregnancy Data
- ✅ Create pregnancy
- ✅ Get pregnancy data
- ✅ Week calculations
- ✅ Progress tracking

### Symptoms
- ✅ Create symptom
- ✅ Get all symptoms
- ✅ Date range filtering
- ✅ Display names

### Appointments
- ✅ Create appointment
- ✅ Get all appointments
- ✅ Upcoming appointments
- ✅ Status tracking

### Weight Tracking
- ✅ Create weight entry
- ✅ Get all entries
- ✅ Unit conversion (kg/lbs)

### Chat
- ✅ Send message
- ✅ Get chat history
- ✅ Clear history
- ✅ AI responses

### Knowledge Base
- ✅ Get facts
- ✅ Search knowledge
- ✅ RAG system

## Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `baseUrl` | API base URL | `http://localhost:3000` |
| `userId` | User profile ID | Auto-generated |
| `pregnancyId` | Pregnancy data ID | Auto-generated |
| `symptomId` | Symptom entry ID | Auto-generated |
| `appointmentId` | Appointment ID | Auto-generated |
| `weightId` | Weight entry ID | Auto-generated |
| `chatMessageId` | Chat message ID | Auto-generated |

## Test Scripts

Each request includes automated test scripts that validate:

- ✅ Response status codes
- ✅ Response time (< 2 seconds)
- ✅ JSON structure
- ✅ Required fields
- ✅ Data types
- ✅ Error handling
- ✅ Content-Type headers

## Running Specific Tests

### Health Check Only
```bash
newman run "Luma-Pregnancy-Assistant-API.postman_collection.json" -e "Luma-Development.postman_environment.json" --folder "Health Check"
```

### User Profile Tests Only
```bash
newman run "Luma-Pregnancy-Assistant-API.postman_collection.json" -e "Luma-Development.postman_environment.json" --folder "User Profile"
```

### All Tests
```bash
newman run "Luma-Pregnancy-Assistant-API.postman_collection.json" -e "Luma-Development.postman_environment.json"
```

## Troubleshooting

### Server Not Running
- Ensure the backend server is running on port 3000
- Check the health endpoint: `http://localhost:3000/health`

### Database Connection Issues
- Verify PostgreSQL is running
- Check database name: `luma`
- Ensure Prisma schema is up to date

### Test Failures
- Check server logs for errors
- Verify environment variables
- Ensure all required data is present

## Continuous Integration

To integrate with CI/CD:

```bash
# Install Newman
npm install -g newman

# Run tests
newman run collection.json -e environment.json --reporters cli,json --reporter-json-export results.json

# Check exit code
echo $?
```

## Performance Benchmarks

| Endpoint | Expected Response Time | Max Response Time |
|----------|----------------------|-------------------|
| Health Check | < 100ms | 500ms |
| User Profile | < 200ms | 1000ms |
| Pregnancy Data | < 200ms | 1000ms |
| Symptoms | < 300ms | 1500ms |
| Appointments | < 300ms | 1500ms |
| Weight Entries | < 200ms | 1000ms |
| Chat | < 2000ms | 5000ms |
| Knowledge | < 500ms | 2000ms |
