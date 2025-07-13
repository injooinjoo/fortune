# 🚨 EMERGENCY ROLLBACK GUIDE

> **FOR USE ONLY IN CASE OF CRITICAL ISSUES AFTER WEB CODE REMOVAL**

## 🔥 Immediate Actions (First 5 Minutes)

### 1. Assess the Situation
```bash
# Check API status
curl https://api.fortune-app.com/health

# Check error rates
# (Check your monitoring dashboard)

# Check user reports
# (Check support channels)
```

### 2. Communicate
- [ ] Post on status page: "Investigating issues"
- [ ] Notify on-call team via Slack/Teams
- [ ] Alert customer support team
- [ ] Prepare user communication

### 3. Quick Fix Attempt
```bash
# If API is down, restart services
ssh api-server
sudo systemctl restart fortune-api

# If specific endpoint failing
# Check logs
tail -f /var/log/fortune-api/error.log
```

## 🔄 Rollback Procedure (If Quick Fix Fails)

### Step 1: Restore Web Code (10 minutes)
```bash
# On local machine
cd /path/to/fortune
git fetch origin
git checkout backup/pre-web-removal
git push origin backup/pre-web-removal:main --force

# Verify files restored
ls -la src/app/
ls -la src/components/
```

### Step 2: Restore Dependencies (5 minutes)
```bash
# Restore package.json from backup
git checkout backup/pre-web-removal -- package.json package-lock.json

# Install dependencies
npm install

# Verify build works
npm run build
```

### Step 3: Redeploy Web App (15 minutes)

#### Option A: Vercel (Recommended)
```bash
# Install Vercel CLI if needed
npm i -g vercel

# Deploy
vercel --prod

# Or trigger from dashboard
# https://vercel.com/dashboard
```

#### Option B: Manual Deploy
```bash
# Build production
npm run build

# Deploy to your server
rsync -avz .next/ user@server:/var/www/fortune/
rsync -avz public/ user@server:/var/www/fortune/public/
```

### Step 4: Update DNS/Routing (10 minutes)
```bash
# If you changed domain structure
# Revert DNS settings in your provider

# Example: Cloudflare
# fortune-app.com → Web App (not API)
# api.fortune-app.com → Keep as API

# Or update nginx/Apache config
sudo nano /etc/nginx/sites-available/fortune
sudo nginx -t
sudo systemctl reload nginx
```

### Step 5: Update Flutter App (30 minutes)
```dart
// Revert API URL in Flutter app
// lib/config/api_config.dart
const String API_BASE_URL = 'https://fortune-app.com/api';
// NOT: https://api.fortune-app.com

// Build and deploy hotfix
flutter build appbundle --release
flutter build ios --release

// Submit to stores (emergency update)
```

## 📱 Flutter App Hotfix

### Android (Google Play)
1. Build APK with reverted API URL
2. Upload to Play Console
3. Select "Expedited Review"
4. Mention "Critical API fix" in notes

### iOS (App Store)
1. Build IPA with reverted API URL
2. Upload via App Store Connect
3. Request Expedited Review
4. Call Apple if critical

### Web (Immediate)
```bash
cd fortune_flutter
flutter build web --release
# Deploy to CDN immediately
```

## 🔍 Verification Steps

### 1. Check Services
```bash
# Web app
curl https://fortune-app.com
# Should return HTML

# API endpoints
curl https://fortune-app.com/api/fortune/daily
# Should return JSON

# Flutter app
# Test manually or via device
```

### 2. Monitor Metrics
- [ ] Error rate dropping
- [ ] Response times normal
- [ ] User complaints stopping
- [ ] Revenue flow restored

### 3. User Communication
```
Subject: Service Restored - Fortune App

Dear Users,

We experienced a brief service disruption that has now been resolved. 
All features should be working normally.

If you continue to experience issues:
1. Update your app to the latest version
2. Clear app cache
3. Contact support if problems persist

We apologize for any inconvenience.

The Fortune Team
```

## 📋 Post-Incident Actions

### Immediate (Within 2 hours)
- [ ] Confirm all services stable
- [ ] Document what went wrong
- [ ] Update status page: "Resolved"
- [ ] Send user communication
- [ ] Schedule emergency meeting

### Short-term (Within 24 hours)
- [ ] Write incident report
- [ ] Identify root cause
- [ ] Create action items
- [ ] Update rollback procedures
- [ ] Test backup systems

### Long-term (Within 1 week)
- [ ] Implement fixes for root cause
- [ ] Update monitoring
- [ ] Revise removal plan
- [ ] Retrain team
- [ ] Plan next attempt (if applicable)

## 📞 Emergency Contacts

| Role | Name | Phone | Email |
|------|------|-------|--------|
| CTO | [Name] | [Phone] | [Email] |
| Lead Dev | [Name] | [Phone] | [Email] |
| DevOps | [Name] | [Phone] | [Email] |
| Support | [Name] | [Phone] | [Email] |

## 🛠️ Useful Commands

```bash
# Check process status
ps aux | grep node
systemctl status fortune-api

# Check port usage
netstat -tulpn | grep :3000

# Check disk space
df -h

# Check memory
free -m

# View recent logs
journalctl -u fortune-api -n 100

# Database connection test
psql $DATABASE_URL -c "SELECT 1"

# Redis connection test
redis-cli ping
```

## ⚡ Quick Wins

If full rollback isn't needed:

1. **API Gateway**: Route through old domain
   ```nginx
   location /api {
     proxy_pass http://api-server:3000;
   }
   ```

2. **Feature Flag**: Disable problematic features
   ```javascript
   if (process.env.ENABLE_NEW_FEATURE === 'false') {
     return oldImplementation();
   }
   ```

3. **Cache Clear**: Sometimes helps
   ```bash
   redis-cli FLUSHALL
   ```

## 🎯 Success Criteria

Rollback is successful when:
- ✅ All API endpoints responding
- ✅ Error rate <0.1%
- ✅ Response time <500ms average
- ✅ No user complaints for 30 minutes
- ✅ Revenue processing normal

---

**Remember**: 
- Stay calm
- Communicate often
- Fix first, blame later
- Document everything
- Learn from the experience

**This guide last tested**: Never (hopefully never needed)  
**Keep this printed and accessible**