# Linux Server Deployment Guide for Ticketing System

## 🐧 **Overview**
This guide will help you deploy your ticketing system on a Linux server and expose only the customer pages to the public.

## 📋 **Prerequisites**

### **Server Requirements**
- **OS**: Ubuntu 20.04+ / CentOS 8+ / Rocky Linux 8+
- **CPU**: 2+ cores (4+ recommended)
- **RAM**: 4GB+ (8GB recommended)
- **Storage**: 50GB+ available space
- **Network**: Static IP address
- **Domain**: Optional but recommended

### **Software Requirements**
- **Python 3.8+**
- **Node.js 18+**
- **MySQL 8.0+**
- **Nginx**
- **Certbot** (for SSL)

## 🚀 **Step-by-Step Deployment**

### **Phase 1: Server Preparation**

#### **1.1 Get Your Linux Server Ready**
```bash
# You need:
# - Ubuntu 20.04+ / CentOS 8+ / Rocky Linux 8+
# - Root access or sudo privileges
# - Static IP address
# - Internet connectivity
```

#### **1.2 Domain Setup (Optional but Recommended)**
- Register a domain name (e.g., `yourticketing.com`)
- Point DNS A records to your server's IP address
- This allows you to use HTTPS and professional URLs

### **Phase 2: Initial Server Setup**

#### **2.1 Run the Linux Server Setup Script**
```bash
# 1. Connect to your Linux server via SSH
ssh root@your-server-ip

# 2. Download your project files
git clone https://github.com/your-repo/ticketing-system.git
cd ticketing-system

# 3. Make scripts executable
chmod +x deployment/linux-server-setup.sh
chmod +x deployment/linux-deploy.sh

# 4. Run the setup script
sudo ./deployment/linux-server-setup.sh
```

**What this script does:**
- Updates system packages
- Installs Python 3.8+, Node.js 18+, MySQL 8.0+
- Installs Nginx web server
- Installs Certbot for SSL certificates
- Creates application directories at `/opt/ticketing-system`
- Configures MySQL database
- Sets up Nginx configuration
- Creates systemd service for backend
- Configures firewall rules

#### **2.2 Verify Installations**
```bash
# Check if everything installed correctly
python3 --version  # Should show Python 3.8+
node --version     # Should show Node.js 18+
mysql --version    # Should show MySQL 8.0+
nginx -v           # Should show Nginx version
```

### **Phase 3: Database Setup**

#### **3.1 Configure MySQL**
```bash
# The setup script should have already created the database
# If not, run these commands:

mysql -u root -p
```

```sql
-- Create database
CREATE DATABASE IF NOT EXISTS ticketing_db;

-- Create user (replace 'your_secure_password' with a strong password)
CREATE USER IF NOT EXISTS 'ticketing_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON ticketing_db.* TO 'ticketing_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### **3.2 Import Your Existing Data (if any)**
```bash
# If you have existing data, import it
mysql -u root -p ticketing_db < your_backup.sql
```

### **Phase 4: Configuration Updates**

#### **4.1 Update Backend Configuration**
Edit `Backend/app/config.py`:
```python
class ProductionConfig(Config):
    DEBUG = False
    # Update with your actual domain
    CORS_ORIGINS = ["https://yourticketing.com", "http://yourticketing.com"]
    # Update database credentials if you created a dedicated user
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://ticketing_user:your_secure_password@localhost/ticketing_db'
```

#### **4.2 Update Frontend Configuration**
Edit `Ticketing/src/config/api.ts`:
```typescript
const getApiBaseUrl = () => {
  if (import.meta.env.DEV) {
    return 'http://localhost:5000';
  } else {
    // Update with your actual domain
    return 'https://yourticketing.com';
  }
};
```

### **Phase 5: Application Deployment**

#### **5.1 Run the Deployment Script**
```bash
# Run as root or with sudo
sudo ./deployment/linux-deploy.sh -d yourticketing.com -p 5000
```

**What this script does:**
- Builds the React frontend application
- Deploys frontend files to Nginx (`/opt/ticketing-system/frontend`)
- Deploys backend files to server (`/opt/ticketing-system/backend`)
- Creates Python virtual environment
- Installs all Python dependencies
- Updates configuration files with your domain
- Sets proper file permissions
- Restarts services
- Tests the application

#### **5.2 Verify Deployment**
```bash
# Check if services are running
sudo systemctl status nginx
sudo systemctl status ticketing-backend
sudo systemctl status mysql

# Check if files are deployed
ls -la /opt/ticketing-system/frontend/
ls -la /opt/ticketing-system/backend/
```

### **Phase 6: SSL Certificate Setup**

#### **6.1 Install SSL Certificate (Let's Encrypt - Free)**
```bash
# Install SSL certificate
sudo certbot --nginx -d yourticketing.com -d www.yourticketing.com

# Test automatic renewal
sudo certbot renew --dry-run
```

#### **6.2 Verify HTTPS Configuration**
```bash
# Check SSL certificate
sudo certbot certificates

# Test HTTPS
curl -I https://yourticketing.com
```

### **Phase 7: Security Configuration**

#### **7.1 Configure Firewall (if not already done)**
```bash
# For Ubuntu/Debian (UFW)
sudo ufw status
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable

# For CentOS/Rocky (firewalld)
sudo firewall-cmd --list-all
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
```

#### **7.2 Verify Admin Routes are Blocked**
The deployment automatically configures this in Nginx. Test it:
```bash
# These should return 403 Forbidden
curl -I http://yourticketing.com/admin
curl -I http://yourticketing.com/engineer
curl -I http://yourticketing.com/accountmanager
```

### **Phase 8: Database Setup**

#### **8.1 Run Database Migrations**
```bash
cd /opt/ticketing-system/backend
source venv/bin/activate
python -m flask db upgrade
```

#### **8.2 Import Initial Data (if needed)**
```bash
# If you have seed data
python -m flask seed-data
```

### **Phase 9: Service Management**

#### **9.1 Check Service Status**
```bash
# Check all services
sudo systemctl status nginx
sudo systemctl status ticketing-backend
sudo systemctl status mysql

# Enable services to start on boot
sudo systemctl enable nginx
sudo systemctl enable ticketing-backend
sudo systemctl enable mysql
```

#### **9.2 View Logs**
```bash
# View service logs
sudo journalctl -u ticketing-backend -f
sudo journalctl -u nginx -f

# View application logs
sudo tail -f /var/log/nginx/ticketing-access.log
sudo tail -f /var/log/nginx/ticketing-error.log
```

## 🧪 **Post-Deployment Verification**

### **1. Test Customer Access**
```bash
# Test frontend
curl -I https://yourticketing.com

# Test API endpoints
curl -I https://yourticketing.com/api/customers/login

# Test file uploads
curl -I https://yourticketing.com/uploads/
```

### **2. Test Security**
```bash
# These should return 403 Forbidden
curl -I https://yourticketing.com/admin
curl -I https://yourticketing.com/engineer
curl -I https://yourticketing.com/accountmanager

# Test HTTPS redirect
curl -I http://yourticketing.com  # Should redirect to HTTPS
```

### **3. Test Backend API**
```bash
# Test if backend is responding
curl http://localhost:5000/api/customers/login
```

## 🔧 **Troubleshooting**

### **Common Issues**

#### **1. Backend Service Not Starting**
```bash
# Check service status
sudo systemctl status ticketing-backend

# View logs
sudo journalctl -u ticketing-backend -n 50

# Check Python environment
cd /opt/ticketing-system/backend
source venv/bin/activate
python run.py
```

#### **2. Nginx Not Loading**
```bash
# Check Nginx configuration
sudo nginx -t

# Check Nginx status
sudo systemctl status nginx

# View Nginx logs
sudo tail -f /var/log/nginx/error.log
```

#### **3. Database Connection Issues**
```bash
# Test MySQL connection
mysql -u ticketing_user -p ticketing_db -e "SELECT 1;"

# Check MySQL service
sudo systemctl status mysql

# Check MySQL logs
sudo tail -f /var/log/mysql/error.log
```

#### **4. SSL Certificate Issues**
```bash
# Check certificate status
sudo certbot certificates

# Renew certificate manually
sudo certbot renew

# Check Nginx SSL configuration
sudo nginx -t
```

### **Useful Commands**
```bash
# Restart services
sudo systemctl restart nginx
sudo systemctl restart ticketing-backend
sudo systemctl restart mysql

# View real-time logs
sudo journalctl -u ticketing-backend -f
sudo tail -f /var/log/nginx/ticketing-access.log

# Check disk space
df -h

# Check memory usage
free -h

# Check CPU usage
top
```

## 📊 **Monitoring and Maintenance**

### **Regular Tasks**
1. **Monitor Logs**
   ```bash
   sudo tail -f /var/log/nginx/ticketing-access.log
   sudo journalctl -u ticketing-backend -f
   ```

2. **Backup Database**
   ```bash
   mysqldump -u root -p ticketing_db > backup_$(date +%Y%m%d).sql
   ```

3. **Update System**
   ```bash
   sudo apt update && sudo apt upgrade -y  # Ubuntu/Debian
   sudo yum update -y  # CentOS/Rocky
   ```

4. **Renew SSL Certificate**
   ```bash
   sudo certbot renew
   ```

### **Performance Monitoring**
```bash
# Monitor system resources
htop
iotop
nethogs

# Monitor Nginx performance
sudo nginx -s status
```

## 🔒 **Security Best Practices**

### **1. Keep System Updated**
```bash
# Regular updates
sudo apt update && sudo apt upgrade -y
```

### **2. Monitor Logs**
```bash
# Check for suspicious activity
sudo grep "403\|404\|500" /var/log/nginx/ticketing-access.log
```

### **3. Regular Backups**
```bash
# Database backup script
#!/bin/bash
mysqldump -u root -p ticketing_db > /backups/ticketing_$(date +%Y%m%d_%H%M%S).sql
find /backups -name "ticketing_*.sql" -mtime +7 -delete
```

## 📁 **File Structure After Deployment**

```
/opt/ticketing-system/
├── frontend/           # React app served by Nginx
│   ├── index.html
│   ├── assets/
│   └── static/
├── backend/           # Flask app running as service
│   ├── app/
│   ├── venv/
│   ├── requirements.txt
│   └── run.py
├── logs/             # Application logs
└── uploads/          # File uploads

/etc/nginx/sites-available/ticketing-system  # Nginx config
/etc/systemd/system/ticketing-backend.service  # Backend service
```

## 🎯 **Architecture Overview**

### **How It Works:**
1. **Frontend**: React app served by Nginx on port 80/443 (public)
2. **Backend**: Flask API running as systemd service on port 5000 (internal)
3. **Database**: MySQL running locally
4. **Reverse Proxy**: Nginx forwards API calls to backend
5. **Security**: Only customer pages accessible publicly

### **URL Flow:**
- `https://yourticketing.com` → Nginx → React app
- `https://yourticketing.com/api/*` → Nginx → Backend (port 5000)
- `https://yourticketing.com/uploads/*` → Nginx → Backend (port 5000)
- `https://yourticketing.com/admin` → Blocked (403 error)

## 🚀 **Quick Start Commands**

```bash
# 1. Initial setup
sudo ./deployment/linux-server-setup.sh

# 2. Deploy application
sudo ./deployment/linux-deploy.sh -d yourticketing.com

# 3. Configure SSL
sudo certbot --nginx -d yourticketing.com

# 4. Check services
sudo systemctl status nginx ticketing-backend mysql

# 5. View logs
sudo journalctl -u ticketing-backend -f
```

## ✅ **Benefits of Linux Deployment**

- ✅ **Cost-effective**: Linux servers are typically cheaper
- ✅ **Performance**: Better resource utilization
- ✅ **Security**: Robust security features
- ✅ **Scalability**: Easy to scale horizontally
- ✅ **Community**: Large community support
- ✅ **Flexibility**: Highly customizable

This deployment ensures that only your customer pages are exposed to the public while keeping all administrative functions secure and internal. The system is production-ready with proper security, SSL, and service management. 