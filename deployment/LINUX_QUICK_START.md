# Linux Deployment Quick Start Guide

## 🚀 **Quick Deployment Commands**

### **1. Server Setup (One-time)**
```bash
# Connect to your Linux server
ssh root@your-server-ip

# Download your project
git clone https://github.com/your-repo/ticketing-system.git
cd ticketing-system

# Make scripts executable
chmod +x deployment/linux-server-setup.sh
chmod +x deployment/linux-deploy.sh

# Run server setup
sudo ./deployment/linux-server-setup.sh
```

### **2. Application Deployment**
```bash
# Deploy with your domain
sudo ./deployment/linux-deploy.sh -d yourticketing.com

# Or with custom port
sudo ./deployment/linux-deploy.sh -d yourticketing.com -p 5000
```

### **3. SSL Certificate Setup**
```bash
# Install SSL certificate
sudo certbot --nginx -d yourticketing.com -d www.yourticketing.com

# Test renewal
sudo certbot renew --dry-run
```

### **4. Verify Deployment**
```bash
# Check services
sudo systemctl status nginx ticketing-backend mysql

# Test application
curl -I https://yourticketing.com
curl -I https://yourticketing.com/api/customers/login

# Test security (should return 403)
curl -I https://yourticketing.com/admin
```

## 📋 **Essential Commands**

### **Service Management**
```bash
# Start/Stop/Restart services
sudo systemctl start|stop|restart nginx
sudo systemctl start|stop|restart ticketing-backend
sudo systemctl start|stop|restart mysql

# Check service status
sudo systemctl status nginx ticketing-backend mysql

# Enable services to start on boot
sudo systemctl enable nginx ticketing-backend mysql
```

### **Logs and Monitoring**
```bash
# View service logs
sudo journalctl -u ticketing-backend -f
sudo journalctl -u nginx -f

# View application logs
sudo tail -f /var/log/nginx/ticketing-access.log
sudo tail -f /var/log/nginx/ticketing-error.log

# Check system resources
htop
df -h
free -h
```

### **Database Management**
```bash
# Connect to database
mysql -u ticketing_user -p ticketing_db

# Backup database
mysqldump -u root -p ticketing_db > backup_$(date +%Y%m%d).sql

# Restore database
mysql -u root -p ticketing_db < backup_file.sql
```

### **Troubleshooting**
```bash
# Test Nginx configuration
sudo nginx -t

# Test backend manually
cd /opt/ticketing-system/backend
source venv/bin/activate
python run.py

# Check firewall status
sudo ufw status  # Ubuntu/Debian
sudo firewall-cmd --list-all  # CentOS/Rocky

# Check SSL certificate
sudo certbot certificates
```

## 🔧 **Common Issues & Solutions**

### **Backend Service Not Starting**
```bash
# Check logs
sudo journalctl -u ticketing-backend -n 50

# Check Python environment
cd /opt/ticketing-system/backend
source venv/bin/activate
python -c "import flask; print('Flask OK')"
```

### **Nginx Not Loading**
```bash
# Check configuration
sudo nginx -t

# Check status
sudo systemctl status nginx

# View error logs
sudo tail -f /var/log/nginx/error.log
```

### **Database Connection Issues**
```bash
# Test connection
mysql -u ticketing_user -p ticketing_db -e "SELECT 1;"

# Check MySQL service
sudo systemctl status mysql

# Check MySQL logs
sudo tail -f /var/log/mysql/error.log
```

## 📊 **Performance Monitoring**

### **System Resources**
```bash
# CPU and Memory
top
htop

# Disk usage
df -h
du -sh /opt/ticketing-system/*

# Network
netstat -tulpn | grep :80
netstat -tulpn | grep :443
netstat -tulpn | grep :5000
```

### **Application Performance**
```bash
# Nginx status
sudo nginx -s status

# Check response times
curl -w "@curl-format.txt" -o /dev/null -s https://yourticketing.com

# Monitor API endpoints
watch -n 1 'curl -s -o /dev/null -w "%{http_code}" https://yourticketing.com/api/customers/login'
```

## 🔒 **Security Checklist**

- [ ] Firewall configured (ports 22, 80, 443 only)
- [ ] SSL certificate installed and valid
- [ ] Admin routes blocked (403 error)
- [ ] Backend port (5000) not accessible externally
- [ ] Strong database passwords
- [ ] Regular system updates
- [ ] Log monitoring active
- [ ] Backup procedures in place

## 📁 **Important File Locations**

```
/opt/ticketing-system/          # Application root
├── frontend/                   # React app
├── backend/                    # Flask app
├── logs/                       # Application logs
└── uploads/                    # File uploads

/etc/nginx/sites-available/ticketing-system  # Nginx config
/etc/systemd/system/ticketing-backend.service  # Backend service
/var/log/nginx/                 # Nginx logs
/var/log/mysql/                 # MySQL logs
```

## 🎯 **Success Indicators**

- ✅ `https://yourticketing.com` loads correctly
- ✅ Customer login works
- ✅ Ticket creation works
- ✅ File uploads work
- ✅ `https://yourticketing.com/admin` returns 403
- ✅ SSL certificate is valid
- ✅ Services start automatically on reboot
- ✅ Logs are being generated
- ✅ Backups are running

## 🆘 **Emergency Commands**

```bash
# Emergency restart all services
sudo systemctl restart nginx ticketing-backend mysql

# Emergency backup
mysqldump -u root -p ticketing_db > emergency_backup_$(date +%Y%m%d_%H%M%S).sql

# Emergency rollback (if needed)
cd /opt/ticketing-system/backend
git checkout HEAD~1
sudo systemctl restart ticketing-backend
```

## 📞 **Getting Help**

1. Check the full deployment guide: `deployment/LINUX_DEPLOYMENT_GUIDE.md`
2. Use the troubleshooting section in the guide
3. Check service logs for error messages
4. Verify configuration files are correct
5. Test individual components manually

**Remember**: Always backup your database before making changes! 