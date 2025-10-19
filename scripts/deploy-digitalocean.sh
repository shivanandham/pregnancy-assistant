#!/bin/bash

# DigitalOcean Deployment Script for Luma Pregnancy Assistant
# This script automates the deployment process to a DigitalOcean droplet

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="pregnancy-assistant"
APP_DIR="/var/www/$APP_NAME"
BACKEND_DIR="$APP_DIR/backend"
SERVICE_USER="www-data"

echo -e "${BLUE}🚀 Starting DigitalOcean deployment for Luma Pregnancy Assistant${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ Please run this script as root or with sudo${NC}"
    exit 1
fi

# Function to print status messages
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if required environment variables are set
check_env_vars() {
    print_info "Checking environment variables..."
    
    if [ -z "$GEMINI_API_KEY" ]; then
        print_error "GEMINI_API_KEY environment variable is required"
        exit 1
    fi
    
    if [ -z "$PROD_DB_PASSWORD" ]; then
        print_error "PROD_DB_PASSWORD environment variable is required"
        exit 1
    fi
    
    print_status "Environment variables validated"
}

# Install system dependencies
install_dependencies() {
    print_info "Installing system dependencies..."
    
    # Update package list
    apt update
    
    # Install Node.js 20.x
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt-get install -y nodejs
    
    # Install PostgreSQL
    apt install -y postgresql postgresql-contrib
    
    # Install PM2
    npm install -g pm2
    
    # Install Nginx
    apt install -y nginx
    
    # Install Git
    apt install -y git
    
    print_status "System dependencies installed"
}

# Setup PostgreSQL
setup_postgresql() {
    print_info "Setting up PostgreSQL..."
    
    # Start and enable PostgreSQL
    systemctl start postgresql
    systemctl enable postgresql
    
    # Create database and user
    sudo -u postgres psql << EOF
CREATE DATABASE pregnancy_assistant;
CREATE USER pregnancy_user WITH PASSWORD '$PROD_DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE pregnancy_assistant TO pregnancy_user;
\q
EOF
    
    print_status "PostgreSQL configured"
}

# Setup application directory
setup_app_directory() {
    print_info "Setting up application directory..."
    
    # Create application directory
    mkdir -p $APP_DIR
    cd $APP_DIR
    
    # Clone repository (you'll need to update this with your actual repo)
    if [ ! -d ".git" ]; then
        print_warning "Please clone your repository to $APP_DIR before running this script"
        print_info "Example: git clone https://github.com/your-username/pregnancy-assistant.git ."
        exit 1
    fi
    
    # Set proper permissions
    chown -R $SERVICE_USER:$SERVICE_USER $APP_DIR
    chmod -R 755 $APP_DIR
    
    print_status "Application directory configured"
}

# Install application dependencies
install_app_dependencies() {
    print_info "Installing application dependencies..."
    
    cd $BACKEND_DIR
    
    # Install npm dependencies
    npm install --production
    
    print_status "Application dependencies installed"
}

# Setup environment file
setup_environment() {
    print_info "Setting up environment configuration..."
    
    cd $BACKEND_DIR
    
    # Create production .env file
    cat > .env << EOF
# Google Gemini API Configuration
GEMINI_API_KEY=$GEMINI_API_KEY

# Server Configuration
PORT=3000
NODE_ENV=production

# Production PostgreSQL Configuration
PROD_DB_HOST=localhost
PROD_DB_PORT=5432
PROD_DB_NAME=pregnancy_assistant
PROD_DB_USER=pregnancy_user
PROD_DB_PASSWORD=$PROD_DB_PASSWORD
EOF
    
    # Set proper permissions
    chown $SERVICE_USER:$SERVICE_USER .env
    chmod 600 .env
    
    print_status "Environment configuration created"
}

# Deploy database schema
deploy_database() {
    print_info "Deploying database schema..."
    
    cd $BACKEND_DIR
    
    # Run database deployment
    npm run deploy:db
    
    print_status "Database schema deployed"
}

# Setup PM2
setup_pm2() {
    print_info "Setting up PM2 process manager..."
    
    cd $BACKEND_DIR
    
    # Create logs directory
    mkdir -p logs
    chown $SERVICE_USER:$SERVICE_USER logs
    
    # Start application with PM2
    pm2 start ecosystem.config.js --env production
    
    # Save PM2 configuration
    pm2 save
    
    # Setup PM2 startup script
    pm2 startup systemd -u $SERVICE_USER --hp /var/www
    
    print_status "PM2 configured and application started"
}

# Setup Nginx
setup_nginx() {
    print_info "Setting up Nginx reverse proxy..."
    
    # Create Nginx configuration
    cat > /etc/nginx/sites-available/$APP_NAME << EOF
server {
    listen 80;
    server_name _;  # Replace with your domain
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
    
    # Enable the site
    ln -sf /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/
    
    # Remove default site
    rm -f /etc/nginx/sites-enabled/default
    
    # Test Nginx configuration
    nginx -t
    
    # Restart Nginx
    systemctl restart nginx
    systemctl enable nginx
    
    print_status "Nginx configured and started"
}

# Setup firewall
setup_firewall() {
    print_info "Setting up UFW firewall..."
    
    # Allow SSH
    ufw allow ssh
    
    # Allow HTTP and HTTPS
    ufw allow 'Nginx Full'
    
    # Enable firewall
    ufw --force enable
    
    print_status "Firewall configured"
}

# Setup monitoring
setup_monitoring() {
    print_info "Setting up monitoring..."
    
    # Install htop for system monitoring
    apt install -y htop
    
    # Setup log rotation for PM2
    pm2 install pm2-logrotate
    
    print_status "Monitoring configured"
}

# Main deployment function
main() {
    echo -e "${BLUE}Starting deployment process...${NC}"
    
    check_env_vars
    install_dependencies
    setup_postgresql
    setup_app_directory
    install_app_dependencies
    setup_environment
    deploy_database
    setup_pm2
    setup_nginx
    setup_firewall
    setup_monitoring
    
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📋 Next steps:${NC}"
    echo "1. Update your domain DNS to point to this server"
    echo "2. Configure SSL certificate with: certbot --nginx -d your-domain.com"
    echo "3. Update your Flutter app with the production API URL"
    echo "4. Test your application end-to-end"
    echo ""
    echo -e "${BLUE}🔧 Useful commands:${NC}"
    echo "• Check app status: pm2 status"
    echo "• View app logs: pm2 logs pregnancy-assistant"
    echo "• Restart app: pm2 restart pregnancy-assistant"
    echo "• Check Nginx status: systemctl status nginx"
    echo "• Monitor system: htop"
}

# Run main function
main "$@"
