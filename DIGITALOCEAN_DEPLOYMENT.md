# DigitalOcean Deployment Guide

This guide will help you deploy the Luma Pregnancy Assistant backend to a DigitalOcean droplet with self-hosted PostgreSQL.

## Prerequisites

- DigitalOcean account
- Domain name (optional, for custom domain)
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

### Install Nginx (for reverse proxy):
```bash
apt install nginx -y
```

## Step 3: PostgreSQL Configuration

### Switch to postgres user and create database:
```bash
sudo -u postgres psql
```

### In PostgreSQL shell:
```sql
-- Create database
CREATE DATABASE pregnancy_assistant;

-- Create user (replace with your desired username/password)
CREATE USER pregnancy_user WITH PASSWORD 'your_secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE pregnancy_assistant TO pregnancy_user;

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
local   pregnancy_assistant   pregnancy_user                    md5
```

### Restart PostgreSQL:
```bash
systemctl restart postgresql
systemctl enable postgresql
```

## Step 4: Deploy Application

### Create application directory:
```bash
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

# Production PostgreSQL Configuration
PROD_DB_HOST=localhost
PROD_DB_PORT=5432
PROD_DB_NAME=pregnancy_assistant
PROD_DB_USER=pregnancy_user
PROD_DB_PASSWORD=your_secure_password
```

### Deploy database schema:
```bash
npm run deploy:db
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

## Step 6: Configure Nginx Reverse Proxy

### Create Nginx configuration:
```bash
nano /etc/nginx/sites-available/pregnancy-assistant
```

### Add Nginx configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;  # Replace with your domain or IP

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

### Enable the site:
```bash
ln -s /etc/nginx/sites-available/pregnancy-assistant /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

## Step 7: SSL Certificate (Optional but Recommended)

### Install Certbot:
```bash
apt install certbot python3-certbot-nginx -y
```

### Obtain SSL certificate:
```bash
certbot --nginx -d your-domain.com
```

## Step 8: Security Hardening

### Configure UFW firewall:
```bash
ufw allow ssh
ufw allow 'Nginx Full'
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
pg_dump -h localhost -U pregnancy_user pregnancy_assistant > $BACKUP_DIR/db_backup_$DATE.sql

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

### Check Nginx logs:
```bash
tail -f /var/log/nginx/error.log
```

### Check PostgreSQL logs:
```bash
tail -f /var/log/postgresql/postgresql-14-main.log
```

### Restart services:
```bash
pm2 restart pregnancy-assistant
systemctl restart nginx
systemctl restart postgresql
```

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `GEMINI_API_KEY` | Google Gemini API key | `AIza...` |
| `PORT` | Application port | `3000` |
| `NODE_ENV` | Environment | `production` |
| `PROD_DB_HOST` | Database host | `localhost` |
| `PROD_DB_PORT` | Database port | `5432` |
| `PROD_DB_NAME` | Database name | `pregnancy_assistant` |
| `PROD_DB_USER` | Database user | `pregnancy_user` |
| `PROD_DB_PASSWORD` | Database password | `secure_password` |

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
1. Check application logs with `pm2 logs`
2. Verify database connectivity
3. Check Nginx configuration with `nginx -t`
4. Review system resources with `htop` and `df -h`
