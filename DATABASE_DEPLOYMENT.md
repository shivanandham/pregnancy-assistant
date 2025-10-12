# Database Deployment Guide

This guide covers how to deploy your pregnancy assistant database to Supabase production environment.

## 🚀 Quick Start

### Prerequisites

1. **Supabase Account**: Sign up at [supabase.com](https://supabase.com)
2. **Environment Variables**: Set up your `.env` file with Supabase credentials
3. **Node.js**: Ensure you have Node.js installed

### One-Command Deployment

```bash
cd backend
npm run deploy:db
```

That's it! The script will handle everything automatically.

## 📋 Detailed Setup

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Fill in project details:
   - **Name**: `pregnancy-assistant-prod`
   - **Database Password**: Choose a strong password (save this!)
   - **Region**: Choose closest to your users
4. Click "Create new project"
5. Wait 2-3 minutes for project initialization

### Step 2: Get Supabase Credentials

1. In your Supabase dashboard, go to **Settings → API**
2. Copy these values:
   - **Project URL** (e.g., `https://abcdefghijklmnop.supabase.co`)
   - **anon public** key
   - **service_role** key
3. Save your database password from Step 1

### Step 3: Configure Environment Variables

Create/update your `backend/.env` file:

```bash
# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
SUPABASE_DB_PASSWORD=your_database_password_here

# Set to production for Supabase
NODE_ENV=production

# Your Gemini API key
GEMINI_API_KEY=your_gemini_api_key_here
```

### Step 4: Deploy Database

```bash
cd backend
npm run deploy:db
```

## 🔧 Available Commands

| Command | Description |
|---------|-------------|
| `npm run deploy:db` | **Full database deployment** (recommended) |
| `npm run test:db` | Test database connection |
| `npm run db:deploy` | Deploy migrations only |
| `npm run db:generate` | Generate Prisma client |
| `npm run db:studio` | Open Prisma Studio |

## 📊 What the Deployment Script Does

The `deploy:db` script automatically:

1. **✅ Validates Environment**: Checks all required environment variables
2. **✅ Updates DATABASE_URL**: Sets correct Supabase connection string
3. **✅ Generates Prisma Client**: Creates TypeScript types
4. **✅ Deploys Migrations**: Creates all database tables
5. **✅ Tests Connection**: Verifies everything works

## 🗄️ Database Schema

The deployment creates these tables:

- `user_profiles` - User information and medical data
- `pregnancy_data` - Pregnancy details and due dates
- `symptoms` - Symptom tracking
- `appointments` - Appointment management
- `weight_entries` - Weight tracking
- `chat_messages` - Chat history
- `chat_sessions` - Chat session management
- `knowledge_facts` - AI knowledge extraction
- `conversation_chunks` - Conversation storage
- `pregnancy_tips` - Weekly pregnancy tips
- `checklist_completions` - Daily checklist tracking

## 🔍 Troubleshooting

### Common Issues

#### 1. "Can't reach database server"
**Solution**: Use session pooler instead of direct connection
- The script automatically uses the correct connection format
- Ensure your Supabase project is active (not paused)

#### 2. "Missing environment variables"
**Solution**: Check your `.env` file
```bash
# Verify all required variables are set
echo $SUPABASE_URL
echo $SUPABASE_ANON_KEY
echo $SUPABASE_SERVICE_ROLE_KEY
echo $SUPABASE_DB_PASSWORD
```

#### 3. "Tenant or user not found"
**Solution**: Verify your project reference in SUPABASE_URL
- URL should be: `https://your-project-ref.supabase.co`
- Project reference should match your dashboard

#### 4. "Migration failed"
**Solution**: Check if tables already exist
```bash
# Test connection first
npm run test:db

# If connection works, try resetting migrations
npm run db:reset
npm run deploy:db
```

### Manual Verification

If you need to verify the deployment manually:

1. **Check Supabase Dashboard**:
   - Go to "Table Editor"
   - Verify all tables are created

2. **Test Connection**:
   ```bash
   npm run test:db
   ```

3. **Check Logs**:
   - Look for any error messages in the deployment output
   - Check Supabase dashboard for any warnings

## 🔄 Schema Changes

When you modify your Prisma schema:

1. **Create Migration**:
   ```bash
   npm run db:migrate
   ```

2. **Deploy to Production**:
   ```bash
   npm run deploy:db
   ```

## 🚀 Production Deployment

After database deployment:

1. **Deploy Backend to Railway**:
   - Set environment variables in Railway dashboard
   - Deploy from GitHub

2. **Update Flutter App**:
   - Update API URL to production endpoint
   - Test all functionality

## 📈 Monitoring

- **Supabase Dashboard**: Monitor database usage and performance
- **Railway Dashboard**: Monitor backend server health
- **Application Logs**: Check for any database connection issues

## 💰 Cost Estimation

- **Supabase Free Tier**: 500MB database, 2GB bandwidth
- **Railway Free Tier**: $5 credit monthly
- **Total**: Essentially free for small to medium usage

## 🆘 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify your Supabase project is active
3. Ensure all environment variables are correct
4. Check the deployment logs for specific error messages

---

**🎉 Your database is now production-ready!**
