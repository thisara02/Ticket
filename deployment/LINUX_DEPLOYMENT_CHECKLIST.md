# Linux Deployment Checklist for Ticketing System

## 🐧 **Pre-Deployment**
- [ ] Linux server is ready (Ubuntu 20.04+ / CentOS 8+ / Rocky Linux 8+)
- [ ] Static IP address assigned
- [ ] Domain name registered (optional but recommended)
- [ ] Root access or sudo privileges
- [ ] Internet connectivity confirmed
- [ ] Project files copied to server

## 🚀 **Server Setup**
- [ ] Run `linux-server-setup.sh` as root/sudo
- [ ] Verify Python 3.8+ installed (`python3 --version`)
- [ ] Verify Node.js 18+ installed (`node --version`)
- [ ] Verify MySQL 8.0+ installed (`mysql --version`)
- [ ] Verify Nginx installed (`nginx -v`)
- [ ] Verify application directories created at `/opt/ticketing-system`
- [ ] Verify systemd service created for backend
- [ ] Verify firewall configured (UFW or firewalld)

## 🗄️ **Database Setup**
- [ ] MySQL service started and enabled
- [ ] Database `ticketing_db` created
- [ ] Database user `ticketing_user` created
- [ ] Database permissions configured
- [ ] Database connection tested
- [ ] Existing data imported (if any)

## ⚙️ **Configuration Updates**
- [ ] Update `Backend/app/config.py` with production domain
- [ ] Update `Ticketing/src/config/api.ts` with production domain
- [ ] Verify CORS origins configured correctly
- [ ] Update database connection string if needed
- [ ] Verify email configuration

## 📦 **Application Deployment**
- [ ] Run `linux-deploy.sh` with correct domain parameter
- [ ] Frontend built successfully (`npm run build`)
- [ ] Frontend deployed to Nginx (`/opt/ticketing-system/frontend`)
- [ ] Backend deployed to server (`/opt/ticketing-system/backend`)
- [ ] Python virtual environment created
- [ ] Python dependencies installed
- [ ] Systemd service configured
- [ ] File permissions set correctly (`www-data` user)

## 🔒 **SSL and Security**
- [ ] DNS records configured (A records)
- [ ] Domain resolves to server IP
- [ ] SSL certificate obtained (Let's Encrypt)
- [ ] SSL certificate installed and configured
- [ ] HTTPS redirect configured
- [ ] Admin/Engineer routes blocked in Nginx (403 error)
- [ ] Backend port (5000) restricted to localhost
- [ ] Security headers configured
- [ ] Rate limiting configured

## 🛠️ **Service Management**
- [ ] Nginx service started and enabled
- [ ] Backend service started and enabled
- [ ] MySQL service started and enabled
- [ ] Services configured for auto-start
- [ ] Service dependencies verified
- [ ] Log directories created and configured

## 🧪 **Testing**
- [ ] Customer pages accessible via HTTPS
- [ ] Customer login working
- [ ] Ticket creation working
- [ ] File uploads working
- [ ] API endpoints responding correctly
- [ ] Admin routes blocked (403 error)
- [ ] Engineer routes blocked (403 error)
- [ ] Account Manager routes blocked (403 error)
- [ ] HTTPS redirect working
- [ ] SSL certificate valid

## 📊 **Monitoring Setup**
- [ ] Log directories created (`/opt/ticketing-system/logs`)
- [ ] Nginx logging configured
- [ ] Backend logging configured
- [ ] Service monitoring set up
- [ ] Error tracking configured
- [ ] Health check endpoint working

## ⚡ **Performance Optimization**
- [ ] Static file compression enabled (gzip)
- [ ] Browser caching configured
- [ ] Database indexes optimized
- [ ] Application performance tested
- [ ] Nginx worker processes optimized
- [ ] MySQL performance tuned

## 💾 **Backup and Recovery**
- [ ] Database backup script created
- [ ] Application backup configured
- [ ] Recovery procedures documented
- [ ] Backup testing completed
- [ ] Automated backup schedule set
- [ ] Backup retention policy configured

## 📚 **Documentation**
- [ ] Deployment guide updated
- [ ] Configuration files documented
- [ ] Troubleshooting procedures documented
- [ ] Maintenance procedures documented
- [ ] Emergency contact information recorded
- [ ] Access credentials securely stored

## ✅ **Final Verification**
- [ ] All customer functionality working
- [ ] Security measures in place
- [ ] Performance acceptable
- [ ] Monitoring active
- [ ] Backup procedures tested
- [ ] Team access configured
- [ ] Support procedures in place
- [ ] SSL certificate auto-renewal working

## 🔄 **Post-Deployment**
- [ ] Monitor application for 24-48 hours
- [ ] Check error logs regularly
- [ ] Verify backup procedures
- [ ] Update documentation as needed
- [ ] Plan regular maintenance schedule
- [ ] Set up monitoring alerts
- [ ] Configure log rotation
- [ ] Test disaster recovery procedures

## 📋 **Maintenance Tasks**
- [ ] Regular system updates scheduled
- [ ] SSL certificate renewal automated
- [ ] Database backup automation
- [ ] Log rotation configured
- [ ] Performance monitoring set up
- [ ] Security updates scheduled
- [ ] Resource usage monitoring
- [ ] Error alerting configured

## 🔧 **Troubleshooting Prepared**
- [ ] Common issue solutions documented
- [ ] Emergency restart procedures
- [ ] Database recovery procedures
- [ ] SSL certificate renewal procedures
- [ ] Service restart procedures
- [ ] Log analysis procedures
- [ ] Performance troubleshooting guide
- [ ] Security incident response plan

## 📝 **Notes**
- Keep this checklist updated during deployment
- Document any deviations from standard procedures
- Note any custom configurations made
- Record any issues encountered and their solutions
- Update contact information and access details
- Document server specifications and configurations
- Record domain and SSL certificate details
- Note any third-party service integrations

## 🎯 **Success Criteria**
- [ ] Application accessible at `https://yourticketing.com`
- [ ] All customer features working correctly
- [ ] Admin/Engineer interfaces blocked from public access
- [ ] SSL certificate valid and auto-renewing
- [ ] Services starting automatically on reboot
- [ ] Logs being generated and rotated
- [ ] Backups running successfully
- [ ] Performance meeting requirements
- [ ] Security measures properly implemented
- [ ] Monitoring and alerting active 