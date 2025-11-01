# Backend Deployment Guide

This guide explains how to deploy your backend changes to the DigitalOcean production server.

## 🚀 Quick Deployment (Common Case)

If you've made code changes (controllers, routes, services, etc.) **without database schema changes**:

### On DigitalOcean Droplet:
```bash
# 1. Navigate to backend directory
cd /var/www/pregnancy-assistant/backend

# 2. Pull latest code
git pull origin main

# 3. Install any new dependencies (if package.json changed)
npm install --production

# 4. Restart the application with PM2
pm2 restart pregnancy-assistant

# 5. Check status and logs
pm2 status
pm2 logs pregnancy-assistant --lines 50
```

**That's it!** Your changes are now live. ✅

---

## 🗄️ Deployment with Database Schema Changes

If you've modified the Prisma schema and need to run migrations:

> **💡 Tip**: Use `npm run deploy:db` instead of running `npx prisma migrate deploy` directly. The script automatically handles environment setup, Prisma client generation, migration deployment, and connection testing.

### On DigitalOcean Droplet:
```bash
# 1. Navigate to backend directory
cd /var/www/pregnancy-assistant/backend

# 2. Pull latest code (includes migrations)
git pull origin main

# 3. Install any new dependencies
npm install --production

# 4. Create database backup (IMPORTANT!)
sudo -u postgres pg_dump luma > ~/backup_$(date +%Y%m%d_%H%M%S).sql

# 5. Deploy database changes
# Note: npm run deploy:db automatically:
#   - Validates DATABASE_URL is set in .env file
#   - Generates Prisma client (npx prisma generate)
#   - Deploys migrations (npx prisma migrate deploy)
#   - Tests database connection
# Prisma automatically reads DATABASE_URL from .env file
NODE_ENV=production npm run deploy:db

# 6. Restart the application
pm2 restart pregnancy-assistant

# 7. Verify everything works
pm2 logs pregnancy-assistant --lines 50
```

---

## 📋 Step-by-Step Detailed Guide

### Prerequisites

1. **SSH Access**: You need SSH access to your DigitalOcean droplet
   ```bash
   ssh root@your-droplet-ip
   # or
   ssh your-user@your-droplet-ip
   ```

2. **Git Repository**: Code should already be pushed to your Git repository

### Step 1: SSH into Production Server

```bash
ssh root@your-droplet-ip
# Replace with your actual droplet IP or domain
```

### Step 2: Navigate to Backend Directory

```bash
cd /var/www/pregnancy-assistant/backend
```

### Step 3: Pull Latest Code

```bash
git pull origin main
```

### Step 4: Install Dependencies (if needed)

Only needed if `package.json` or `package-lock.json` changed:

```bash
npm install --production
```

### Step 5: Handle Database Changes (if needed)

#### Option A: No Schema Changes
Skip this step if you didn't modify `prisma/schema.prisma`.

#### Option B: Schema Changes
```bash
# 1. Backup database first!
sudo -u postgres pg_dump luma > ~/backup_$(date +%Y%m%d_%H%M%S).sql

# 2. Deploy database changes
# Note: npm run deploy:db automatically generates Prisma client and deploys migrations
NODE_ENV=production npm run deploy:db
```

### Step 6: Restart Application

```bash
# Restart with PM2
pm2 restart pregnancy-assistant

# Or if using ecosystem.config.js
pm2 restart ecosystem.config.js --env production
```

### Step 7: Verify Deployment

```bash
# Check PM2 status
pm2 status

# View recent logs
pm2 logs pregnancy-assistant --lines 50

# Monitor logs in real-time
pm2 logs pregnancy-assistant

# Check if app is responding
curl http://localhost:3000/api/health
```

---

## 🔍 Useful PM2 Commands

```bash
# Check application status
pm2 status

# View logs
pm2 logs pregnancy-assistant

# View last N lines of logs
pm2 logs pregnancy-assistant --lines 100

# Restart application
pm2 restart pregnancy-assistant

# Stop application
pm2 stop pregnancy-assistant

# Start application
pm2 start pregnancy-assistant

# Reload application (zero-downtime)
pm2 reload pregnancy-assistant

# Monitor application
pm2 monit

# View detailed info
pm2 show pregnancy-assistant
```

---

## 🗄️ Database Management Commands

### Deploy Database Changes (Recommended)
```bash
# This is the recommended way to deploy database changes in production
# It automatically:
#   - Validates DATABASE_URL is set in .env file
#   - Generates Prisma client (npx prisma generate)
#   - Deploys migrations (npx prisma migrate deploy)
#   - Tests database connection
# Note: Prisma automatically reads DATABASE_URL from .env file
NODE_ENV=production npm run deploy:db
```

### Check Migration Status
```bash
cd /var/www/pregnancy-assistant/backend
npx prisma migrate status
```

### Generate Prisma Client (Manual)
```bash
# Usually not needed - npm run deploy:db does this automatically
# Only use if you need to regenerate client without deploying migrations
npx prisma generate
```

### Deploy Migrations (Manual)
```bash
# Usually not needed - npm run deploy:db does this automatically
# Only use if you want to deploy migrations without the full deployment script
NODE_ENV=production npx prisma migrate deploy
```

### Test Database Connection
```bash
npm run test:db
```

### Open Prisma Studio (Database GUI)
```bash
# Only use in development, not on production server
npm run db:studio
```

---

## 🔐 Environment Variables

Make sure your production `.env` file has all required variables:

```bash
cd /var/www/pregnancy-assistant/backend
nano .env
```

Required variables:
- `DATABASE_URL` - PostgreSQL connection string (e.g., `postgresql://postgres:password@localhost:5432/luma`)
- `GEMINI_API_KEY` - Google Gemini API key
- `NODE_ENV` - Should be `production`
- `PORT` - Application port (usually `3000`)
- `JWT_SECRET` - Secret for JWT token generation
- `JWT_EXPIRES_IN` - Session token expiration (default: `30d`)
- `JWT_REFRESH_EXPIRES_IN` - Refresh token expiration (default: `90d`)
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `FIREBASE_PRIVATE_KEY` - Firebase private key
- `FIREBASE_CLIENT_EMAIL` - Firebase client email

### DATABASE_URL Format

For local PostgreSQL on your droplet:
```
DATABASE_URL=postgresql://USERNAME:PASSWORD@localhost:5432/DATABASE_NAME
```

Example:
```
DATABASE_URL=postgresql://postgres:your_secure_password@localhost:5432/luma
```

> **Note**: Prisma automatically reads `DATABASE_URL` from your `.env` file. You don't need separate database connection variables like `PROD_DB_HOST`, `PROD_DB_PASSWORD`, etc. Just set `DATABASE_URL` directly.

---

## 🐛 Troubleshooting

### Application Won't Start

```bash
# Check logs for errors
pm2 logs pregnancy-assistant

# Check if port is already in use
lsof -i :3000

# Check environment variables
cd /var/www/pregnancy-assistant/backend
cat .env
```

### Database Connection Issues

```bash
# Test database connection
npm run test:db

# Check PostgreSQL status
sudo systemctl status postgresql

# Check if database exists
sudo -u postgres psql -l
```

### Migration Failed

```bash
# Check migration status
npx prisma migrate status

# View migration history
ls -la prisma/migrations/

# Restore from backup if needed
sudo -u postgres psql luma < ~/backup_YYYYMMDD_HHMMSS.sql
```

### Dependencies Issues

```bash
# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install --production

# Clear npm cache
npm cache clean --force
```

### PM2 Issues

```bash
# Delete and restart PM2 process
pm2 delete pregnancy-assistant
pm2 start ecosystem.config.js --env production
pm2 save
```

---

## 📊 Monitoring

### Check Application Health

```bash
# Test health endpoint
curl http://localhost:3000/api/health

# Test from outside (if domain configured)
curl https://your-domain.com/api/health
```

### Monitor System Resources

```bash
# CPU and memory usage
htop

# Disk usage
df -h

# PM2 monitoring
pm2 monit
```

---

## 🔄 Complete Deployment Workflow

Here's the complete workflow for deploying changes on the production server:

```bash
# 1. SSH into server
ssh root@your-droplet-ip

# 2. Navigate to backend
cd /var/www/pregnancy-assistant/backend

# 3. Pull latest code
git pull origin main

# 4. Install dependencies (if needed)
npm install --production

# 5. Backup database (if schema changed)
sudo -u postgres pg_dump luma > ~/backup_$(date +%Y%m%d_%H%M%S).sql

# 6. Deploy database changes (if schema changed)
# Note: npm run deploy:db automatically generates Prisma client and deploys migrations
NODE_ENV=production npm run deploy:db

# 7. Restart application
pm2 restart pregnancy-assistant

# 8. Verify deployment
pm2 logs pregnancy-assistant --lines 50
curl http://localhost:3000/api/health
```

---

## ⚠️ Important Notes

1. **Always Backup Before Migrations**: Database migrations can be destructive. Always backup before applying:
   ```bash
   sudo -u postgres pg_dump luma > ~/backup_$(date +%Y%m%d_%H%M%S).sql
   ```

2. **Review Migrations**: Always review generated migration SQL files before applying.

3. **Environment Variables**: Never commit `.env` file. Always set environment variables on the server.

4. **PM2 Auto-restart**: PM2 is configured to auto-restart on server reboot. No manual action needed.

5. **Zero-Downtime**: Use `pm2 reload` instead of `pm2 restart` for zero-downtime deployments (for non-breaking changes).

---

## 📚 Related Documentation

- **DigitalOcean Deployment**: See `DIGITALOCEAN_DEPLOYMENT.md`
- **Database Deployment**: See `DATABASE_DEPLOYMENT.md`
- **Migration Rules**: See `backend/prisma/MIGRATION_RULES.md`
- **Backend Guidelines**: See `.cursor/rules/backend_guidelines.mdc`

---

## 🆘 Quick Reference

| Task | Command |
|------|---------|
| Deploy code changes | `git pull && npm install --production && pm2 restart pregnancy-assistant` |
| Deploy with migrations | `git pull && npm install --production && NODE_ENV=production npm run deploy:db && pm2 restart pregnancy-assistant` |
| View logs | `pm2 logs pregnancy-assistant` |
| Check status | `pm2 status` |
| Restart app | `pm2 restart pregnancy-assistant` |
| Backup database | `sudo -u postgres pg_dump luma > ~/backup_$(date +%Y%m%d_%H%M%S).sql` |
| Test connection | `npm run test:db` |
| Check health | `curl http://localhost:3000/api/health` |

---

**🎉 Happy Deploying!**

