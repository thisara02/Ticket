#!/bin/bash

# Linux Server Deployment Script for Ticketing System
# Run this script as root or with sudo

set -e  # Exit on any error

echo "🚀 Starting Linux Server Deployment for Ticketing System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    print_error "Cannot detect Linux distribution"
    exit 1
fi

print_status "Detected OS: $OS $VER"

# Update system
print_status "Updating system packages..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    apt update && apt upgrade -y
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    yum update -y
else
    print_error "Unsupported Linux distribution"
    exit 1
fi

# Install essential packages
print_status "Installing essential packages..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    yum install -y curl wget git unzip epel-release
fi

# Install Python 3.8+
print_status "Installing Python 3.8+..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    apt install -y python3 python3-pip python3-venv python3-dev
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    yum install -y python3 python3-pip python3-devel
fi

# Install Node.js 18+
print_status "Installing Node.js 18+..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt install -y nodejs
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs
fi

# Install MySQL 8.0
print_status "Installing MySQL 8.0..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    wget https://dev.mysql.com/get/mysql-apt-config_0.8.24-1_all.deb
    dpkg -i mysql-apt-config_0.8.24-1_all.deb
    apt update
    apt install -y mysql-server
    rm mysql-apt-config_0.8.24-1_all.deb
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    yum install -y mysql-server mysql
fi

# Install Nginx
print_status "Installing Nginx..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    apt install -y nginx
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    yum install -y nginx
fi

# Install PM2 for Node.js process management
print_status "Installing PM2..."
npm install -g pm2

# Install Certbot for SSL certificates
print_status "Installing Certbot..."
if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    apt install -y certbot python3-certbot-nginx
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]] || [[ "$OS" == *"Rocky"* ]]; then
    yum install -y certbot python3-certbot-nginx
fi

# Create application directories
print_status "Creating application directories..."
mkdir -p /opt/ticketing-system
mkdir -p /opt/ticketing-system/backend
mkdir -p /opt/ticketing-system/frontend
mkdir -p /opt/ticketing-system/logs
mkdir -p /opt/ticketing-system/uploads

# Set proper permissions
chown -R www-data:www-data /opt/ticketing-system
chmod -R 755 /opt/ticketing-system

# Configure MySQL
print_status "Configuring MySQL..."
systemctl start mysql
systemctl enable mysql

# Secure MySQL installation
mysql_secure_installation

# Create database and user
print_status "Creating database and user..."
mysql -u root -p << EOF
CREATE DATABASE IF NOT EXISTS ticketing_db;
CREATE USER IF NOT EXISTS 'ticketing_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON ticketing_db.* TO 'ticketing_user'@'localhost';
FLUSH PRIVILEGES;
EOF

# Configure Nginx
print_status "Configuring Nginx..."
cat > /etc/nginx/sites-available/ticketing-system << 'EOF'
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    # Frontend
    location / {
        root /opt/ticketing-system/frontend;
        try_files $uri $uri/ /index.html;
        
        # Security headers
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-XSS-Protection "1; mode=block" always;
        add_header X-Content-Type-Options "nosniff" always;
        add_header Referrer-Policy "no-referrer-when-downgrade" always;
        add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    }
    
    # API proxy
    location /api/ {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
    
    # Uploads proxy
    location /uploads/ {
        proxy_pass http://localhost:5000;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Block admin routes
    location ~ ^/(admin|engineer|accountmanager) {
        return 403;
    }
    
    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied expired no-cache no-store private must-revalidate auth;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript;
}
EOF

# Enable the site
ln -sf /etc/nginx/sites-available/ticketing-system /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Test Nginx configuration
nginx -t

# Start and enable services
print_status "Starting and enabling services..."
systemctl start nginx
systemctl enable nginx

# Configure firewall
print_status "Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw --force enable
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-service=ssh
    firewall-cmd --permanent --add-service=http
    firewall-cmd --permanent --add-service=https
    firewall-cmd --reload
fi

# Create systemd service for backend
print_status "Creating systemd service for backend..."
cat > /etc/systemd/system/ticketing-backend.service << 'EOF'
[Unit]
Description=Ticketing System Backend
After=network.target mysql.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/opt/ticketing-system/backend
Environment=FLASK_ENV=production
ExecStart=/opt/ticketing-system/backend/venv/bin/python run.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable ticketing-backend

print_status "Linux Server setup completed successfully!"
echo ""
print_status "Next steps:"
echo "1. Copy your application files to /opt/ticketing-system"
echo "2. Update configuration files with your domain"
echo "3. Run the deployment script"
echo "4. Configure SSL certificate"
echo "5. Start the services" 