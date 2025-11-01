# DigitalOcean Deployment Guide

This guide will help you deploy the Luma Pregnancy Assistant backend to a DigitalOcean droplet with self-hosted PostgreSQL.

## Prerequisites

- DigitalOcean account
- Domain name: `lumacare.in` (already configured)
- SSH key pair for server access

## Step 1: Create DigitalOcean Droplet

1. **Create a new droplet:**
   - Choose Ubuntu 22.04 LTS
   - Select appropriate size (minimum 2GB RAM recommended)
   - Add your SSH key
   - Choose a datacenter region close to your users

2. **Configure firewall:**
   - Allow SSH (port 22)
   - Allow HTTP (port 80)
   - Allow HTTPS (port 443)
   - Allow custom port for your app (e.g., 3000)

## Step 2: Server Setup

### Connect to your droplet:
```bash
ssh root@your-droplet-ip
```

### Update system packages:
```bash
apt update && apt upgrade -y
```

### Install Node.js (using NodeSource repository):
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt-get install -y nodejs
```

### Install PostgreSQL:
```bash
apt install postgresql postgresql-contrib -y
```

### Install PM2 for process management:
```bash
npm install -g pm2
```

### Install Caddy (for reverse proxy and automatic HTTPS):
```bash
apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install caddy -y
```

## Step 3: PostgreSQL Configuration

### Switch to postgres user and create database:
```bash
sudo -u postgres psql
```

### In PostgreSQL shell:
```sql
-- Create database
CREATE DATABASE luma;

-- Create user (replace with your desired username/password)
CREATE USER postgres WITH PASSWORD 'your_secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE luma TO postgres;

-- Exit PostgreSQL
\q
```

### Configure PostgreSQL for remote connections (if needed):
```bash
# Edit postgresql.conf
nano /etc/postgresql/14/main/postgresql.conf

# Uncomment and modify:
listen_addresses = 'localhost'

# Edit pg_hba.conf
nano /etc/postgresql/14/main/pg_hba.conf

# Add line for local connections:
local   luma   postgres                    md5
```

### Restart PostgreSQL:
```bash
systemctl restart postgresql
systemctl enable postgresql
```

## Step 4: Deploy Application

### Create application directories:
```bash
# Backend directory
mkdir -p /var/www/pregnancy-assistant
cd /var/www/pregnancy-assistant
```

### Clone your repository:
```bash
git clone https://github.com/your-username/pregnancy-assistant.git .
```

### Install dependencies:
```bash
cd backend
npm install
```

### Create production environment file:
```bash
nano .env
```

### Add production environment variables:
```env
# Google Gemini API Configuration
GEMINI_API_KEY=your_gemini_api_key_here

# Server Configuration
PORT=3000
NODE_ENV=production

# PostgreSQL Database Configuration
# Prisma automatically reads DATABASE_URL from .env file
DATABASE_URL=postgresql://postgres:your_secure_password@localhost:5432/luma

# Session Token Configuration
JWT_SECRET=your_strong_secret_key_here
JWT_EXPIRES_IN=30d
JWT_REFRESH_EXPIRES_IN=90d

# Firebase Configuration
FIREBASE_PROJECT_ID=your_firebase_project_id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nyour_private_key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your_firebase_client_email
```

### Deploy database schema:
```bash
NODE_ENV=production npm run deploy:db
```

### Test the application:
```bash
npm start
```

## Step 5: Configure PM2

### Create PM2 ecosystem file:
```bash
nano ecosystem.config.js
```

### Add PM2 configuration:
```javascript
module.exports = {
  apps: [{
    name: 'pregnancy-assistant',
    script: 'server.js',
    cwd: '/var/www/pregnancy-assistant/backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    }
  }]
};
```

### Start application with PM2:
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## Step 6: Configure Caddy Reverse Proxy

Caddy automatically handles HTTPS with Let's Encrypt certificates.

**Note**: This configuration routes `/api/*` requests to the backend and serves a landing page at the root domain.

### Create Caddy configuration:
```bash
nano /etc/caddy/Caddyfile
```

### Add Caddy configuration:
```
lumacare.in {
    # Route API requests to backend (must come first for proper matching)
    handle /api/* {
        reverse_proxy localhost:3000 {
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
        }
    }

    # Serve landing page files directly from repository
    root * /var/www/pregnancy-assistant/landing_page
    file_server
    try_files {path} /index.html
}
```

### Test Caddy configuration:
```bash
caddy validate --config /etc/caddy/Caddyfile
```

### Enable and start Caddy:
```bash
systemctl enable caddy
systemctl restart caddy
```

### Check Caddy status:
```bash
systemctl status caddy
```

Caddy will automatically:
- Obtain SSL certificate from Let's Encrypt
- Renew certificates automatically
- Redirect HTTP to HTTPS

## Step 7: DNS Configuration

Before Caddy can obtain SSL certificates, ensure your DNS is configured:

1. **Add A record** pointing `lumacare.in` to your droplet IP:
   - Type: `A`
   - Name: `lumacare.in` (or `@`)
   - Value: Your droplet IP address
   - TTL: 3600 (or default)

2. **Wait for DNS propagation** (can take a few minutes to 48 hours)

3. **Verify DNS**:
   ```bash
   dig lumacare.in
   # or
   nslookup lumacare.in
   ```

## Step 8: Security Hardening

### Configure UFW firewall:
```bash
ufw allow ssh
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable
```

### Set up automatic security updates:
```bash
apt install unattended-upgrades -y
dpkg-reconfigure -plow unattended-upgrades
```

## Step 9: Monitoring and Maintenance

### Check application status:
```bash
pm2 status
pm2 logs pregnancy-assistant
```

### Monitor system resources:
```bash
htop
df -h
```

### Set up log rotation:
```bash
pm2 install pm2-logrotate
```

## Step 10: Backup Strategy

### Create backup script:
```bash
nano /usr/local/bin/backup-db.sh
```

### Add backup script content:
```bash
#!/bin/bash
BACKUP_DIR="/var/backups/pregnancy-assistant"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Database backup
sudo -u postgres pg_dump luma > $BACKUP_DIR/db_backup_$DATE.sql

# Keep only last 7 days of backups
find $BACKUP_DIR -name "db_backup_*.sql" -mtime +7 -delete
```

### Make script executable:
```bash
chmod +x /usr/local/bin/backup-db.sh
```

### Add to crontab for daily backups:
```bash
crontab -e
# Add line:
0 2 * * * /usr/local/bin/backup-db.sh
```

## Troubleshooting

### Check application logs:
```bash
pm2 logs pregnancy-assistant
```

### Check Caddy logs:
```bash
journalctl -u caddy -f
# or
tail -f /var/log/caddy/access.log
```

### Check PostgreSQL logs:
```bash
tail -f /var/log/postgresql/postgresql-14-main.log
```

### Restart services:
```bash
pm2 restart pregnancy-assistant
systemctl restart caddy
systemctl restart postgresql
```

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://postgres:password@localhost:5432/luma` |
| `GEMINI_API_KEY` | Google Gemini API key | `AIza...` |
| `PORT` | Application port | `3000` |
| `NODE_ENV` | Environment | `production` |
| `JWT_SECRET` | Secret for JWT token generation | `your_strong_secret` |
| `JWT_EXPIRES_IN` | Session token expiration | `30d` |
| `JWT_REFRESH_EXPIRES_IN` | Refresh token expiration | `90d` |
| `FIREBASE_PROJECT_ID` | Firebase project ID | `your-project-id` |
| `FIREBASE_PRIVATE_KEY` | Firebase private key | `-----BEGIN PRIVATE KEY-----...` |
| `FIREBASE_CLIENT_EMAIL` | Firebase client email | `your-email@project.iam.gserviceaccount.com` |

## Cost Optimization

- Use appropriate droplet size for your traffic
- Enable DigitalOcean monitoring
- Set up alerts for resource usage
- Consider using DigitalOcean Spaces for file storage if needed
- Implement proper caching strategies

## Security Checklist

- [ ] SSH key authentication enabled
- [ ] Firewall configured
- [ ] Database user has limited privileges
- [ ] Strong database password set
- [ ] SSL certificate installed
- [ ] Automatic security updates enabled
- [ ] Regular backups configured
- [ ] Application runs as non-root user (recommended)

## Support

For issues specific to this deployment:
1. Check application logs with `pm2 logs pregnancy-assistant`
2. Verify database connectivity with `npm run test:db`
3. Check Caddy status with `systemctl status caddy`
4. Review Caddy logs with `journalctl -u caddy -f`
5. Verify DNS resolution with `dig lumacare.in`
6. Test health endpoint: `curl https://lumacare.in/api/health`
7. Review system resources with `htop` and `df -h`
