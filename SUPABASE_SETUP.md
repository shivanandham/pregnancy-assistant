# Supabase Setup Guide

## Prerequisites
- Supabase account (free tier available)
- Existing Railway deployment

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up/Sign in with GitHub
3. Click "New Project"
4. Choose organization and enter project details:
   - **Name**: `pregnancy-assistant`
   - **Database Password**: Generate a strong password
   - **Region**: Choose closest to your users
5. Click "Create new project"
6. Wait for project to be ready (2-3 minutes)

## Step 2: Get Supabase Credentials

In your Supabase dashboard:

1. Go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (SUPABASE_URL)
   - **anon public** key (SUPABASE_ANON_KEY)
   - **service_role** key (SUPABASE_SERVICE_ROLE_KEY)

3. **Get your database password:**
   - This is the password you set when creating the Supabase project
   - You'll need it for the `SUPABASE_DB_PASSWORD` environment variable

## Step 3: Set Up Database Schema

1. In Supabase dashboard, go to **SQL Editor**
2. Click "New query"
3. Copy and paste the contents of `supabase-schema.sql`
4. Click "Run" to execute the schema

## Step 4: Update Railway Environment Variables

In your Railway dashboard:

1. Go to your project
2. Click on **Variables** tab
3. Add the following environment variables:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
SUPABASE_DB_PASSWORD=your_database_password
GEMINI_API_KEY=your_gemini_api_key_here
PORT=3000
NODE_ENV=development
```

## Step 5: Update Backend Code

The backend needs to be updated to use Supabase instead of SQLite:

1. **Update server.js** to use Supabase database
2. **Update all models** to use PostgreSQL instead of SQLite
3. **Test the connection**

## Step 6: Deploy and Test

1. Push changes to GitHub
2. Railway will automatically redeploy
3. Test the API endpoints
4. Verify data persistence

## Supabase Benefits

- ✅ **Free Tier**: 500MB database, 2GB bandwidth
- ✅ **Persistent Storage**: Data never gets lost
- ✅ **Real-time**: Built-in real-time subscriptions
- ✅ **Authentication**: User management (if needed later)
- ✅ **Dashboard**: Visual database management
- ✅ **Backups**: Automatic daily backups
- ✅ **Scaling**: Easy to upgrade as needed

## Database Schema

The schema includes:
- **user_profiles**: User information and medical data
- **pregnancy_data**: Pregnancy details and due dates
- **symptoms**: Symptom tracking
- **appointments**: Appointment management
- **weight_entries**: Weight tracking
- **chat_messages**: Chat history
- **knowledge_facts**: AI knowledge extraction
- **conversation_chunks**: Conversation storage

## Next Steps

After setup:
1. Test all API endpoints
2. Verify data persistence
3. Update Flutter app if needed
4. Monitor usage in Supabase dashboard
