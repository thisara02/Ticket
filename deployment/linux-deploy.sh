#!/bin/bash

# Linux Deployment Script for Ticketing System
# Run this script after setting up the Linux server

set -e  # Exit on any error

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

# Default values
DOMAIN="yourdomain.com"
BACKEND_PORT="5000"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--domain)
            DOMAIN="$2"
            shift 2
            ;;
        -p|--port)
            BACKEND_PORT="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 [-d domain] [-p port]"
            echo "  -d, --domain    Domain name (default: yourdomain.com)"
            echo "  -p, --port      Backend port (default: 5000)"
            exit 0
            ;;
        *)
            print_error "Unknown option $1"
            exit 1
            ;;
    esac
done

print_status "Starting deployment process..."
print_status "Domain: $DOMAIN"
print_status "Backend Port: $BACKEND_PORT"
print_status "Project Root: $PROJECT_ROOT"

# Set paths
BACKEND_PATH="$PROJECT_ROOT/Backend"
FRONTEND_PATH="$PROJECT_ROOT/Ticketing"
DEPLOY_PATH="/opt/ticketing-system"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root or with sudo"
   exit 1
fi

# 1. Build Frontend
print_status "Building frontend..."
cd "$FRONTEND_PATH"

# Update API configuration with domain
print_status "Updating API configuration..."
API_CONFIG_PATH="$FRONTEND_PATH/src/config/api.ts"
if [ -f "$API_CONFIG_PATH" ]; then
    sed -i "s/https:\/\/yourdomain.com/https:\/\/$DOMAIN/g" "$API_CONFIG_PATH"
    sed -i "s/http:\/\/yourdomain.com/http:\/\/$DOMAIN/g" "$API_CONFIG_PATH"
    print_status "API configuration updated"
else
    print_warning "API config file not found, creating it..."
    mkdir -p "$(dirname "$API_CONFIG_PATH")"
    cat > "$API_CONFIG_PATH" << EOF
// API Configuration for different environments
const getApiBaseUrl = () => {
  if (import.meta.env.DEV) {
    return 'http://localhost:5000';
  } else {
    return 'https://$DOMAIN';
  }
};

export const API_BASE_URL = getApiBaseUrl();

// API endpoints
export const API_ENDPOINTS = {
  // Customer endpoints
  CUSTOMER_LOGIN: \`\${API_BASE_URL}/api/customers/login\`,
  CUSTOMER_PROFILE: \`\${API_BASE_URL}/api/customers/profile\`,
  CUSTOMER_TICKETS: \`\${API_BASE_URL}/api/customers/tickets\`,
  CUSTOMER_TICKET_COUNTS: \`\${API_BASE_URL}/api/customers/ticket-counts\`,
  CUSTOMER_FORGOT_PASSWORD: \`\${API_BASE_URL}/api/customers/forgot-password/send-otp\`,
  CUSTOMER_VERIFY_OTP: \`\${API_BASE_URL}/api/customers/forgot-password/verify-otp\`,
  CUSTOMER_RESET_PASSWORD: \`\${API_BASE_URL}/api/customers/reset-password\`,
  CUSTOMER_CHANGE_PASSWORD: \`\${API_BASE_URL}/api/customers/change-password\`,
  CUSTOMER_TICKET_HISTORY: \`\${API_BASE_URL}/api/customers/ticket-history\`,
  CUSTOMER_ONGOING_TICKETS: \`\${API_BASE_URL}/api/customers/ongoing-tickets\`,
  CUSTOMER_PURCHASE_BUNDLE: \`\${API_BASE_URL}/api/customers/purchase-bundle\`,
  
  // Ticket endpoints
  TICKET_USER_INFO: \`\${API_BASE_URL}/api/ticket/userinfo\`,
  TICKET_FT: \`\${API_BASE_URL}/api/ticket/ft\`,
  TICKET_SR: \`\${API_BASE_URL}/api/ticket/sr\`,
  
  // File uploads
  UPLOADS: \`\${API_BASE_URL}/uploads\`,
};
EOF
fi

# Install dependencies and build
print_status "Installing frontend dependencies..."
npm install

print_status "Building frontend application..."
npm run build

# 2. Deploy Frontend to Nginx
print_status "Deploying frontend to Nginx..."
FRONTEND_DEPLOY_PATH="$DEPLOY_PATH/frontend"
if [ -d "$FRONTEND_DEPLOY_PATH" ]; then
    rm -rf "$FRONTEND_DEPLOY_PATH"/*
fi
cp -r "$FRONTEND_PATH/dist"/* "$FRONTEND_DEPLOY_PATH/"

# 3. Deploy Backend
print_status "Deploying backend..."
BACKEND_DEPLOY_PATH="$DEPLOY_PATH/backend"
if [ -d "$BACKEND_DEPLOY_PATH" ]; then
    rm -rf "$BACKEND_DEPLOY_PATH"/*
fi
cp -r "$BACKEND_PATH"/* "$BACKEND_DEPLOY_PATH/"

# Update backend configuration
print_status "Updating backend configuration..."
CONFIG_PATH="$BACKEND_DEPLOY_PATH/app/config.py"
if [ -f "$CONFIG_PATH" ]; then
    sed -i "s/https:\/\/yourdomain.com/https:\/\/$DOMAIN/g" "$CONFIG_PATH"
    sed -i "s/http:\/\/yourdomain.com/http:\/\/$DOMAIN/g" "$CONFIG_PATH"
    print_status "Backend configuration updated"
fi

# 4. Set up Python environment
print_status "Setting up Python environment..."
cd "$BACKEND_DEPLOY_PATH"

# Create virtual environment
python3 -m venv venv

# Activate virtual environment and install dependencies
print_status "Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# 5. Set up database
print_status "Setting up database..."
# You may need to manually create the database and run migrations
# python -m flask db upgrade

# 6. Update Nginx configuration with domain
print_status "Updating Nginx configuration..."
NGINX_CONFIG="/etc/nginx/sites-available/ticketing-system"
if [ -f "$NGINX_CONFIG" ]; then
    sed -i "s/yourdomain.com/$DOMAIN/g" "$NGINX_CONFIG"
    sed -i "s/www.yourdomain.com/www.$DOMAIN/g" "$NGINX_CONFIG"
    print_status "Nginx configuration updated"
fi

# 7. Set permissions
print_status "Setting file permissions..."
chown -R www-data:www-data "$DEPLOY_PATH"
chmod -R 755 "$DEPLOY_PATH"

# 8. Restart services
print_status "Restarting services..."
systemctl restart nginx
systemctl restart ticketing-backend

# 9. Check service status
print_status "Checking service status..."
if systemctl is-active --quiet nginx; then
    print_status "Nginx is running"
else
    print_error "Nginx is not running"
fi

if systemctl is-active --quiet ticketing-backend; then
    print_status "Backend service is running"
else
    print_error "Backend service is not running"
fi

# 10. Test the application
print_status "Testing application..."
sleep 5  # Wait for services to start

# Test backend API
if curl -s http://localhost:$BACKEND_PORT/api/customers/login > /dev/null; then
    print_status "Backend API is responding"
else
    print_warning "Backend API is not responding"
fi

# Test frontend
if curl -s http://localhost > /dev/null; then
    print_status "Frontend is accessible"
else
    print_warning "Frontend is not accessible"
fi

print_status "Deployment completed successfully!"
echo ""
print_status "Your application should now be accessible at: http://$DOMAIN"
print_status "Backend API is running on: http://localhost:$BACKEND_PORT"
echo ""
print_status "Next steps:"
echo "1. Configure SSL certificate: certbot --nginx -d $DOMAIN"
echo "2. Test all functionality"
echo "3. Set up monitoring and logging"
echo "4. Configure backups" 