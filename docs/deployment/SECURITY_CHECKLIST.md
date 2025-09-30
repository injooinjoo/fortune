# Security Checklist - Fortune App Deployment

## 🔴 CRITICAL: Exposed API Keys to Rotate

The following API keys have been exposed in the codebase and MUST be rotated before deployment:

### High Priority (Production Services)
- [ ] **OpenAI API Key** 
  - Current: `sk-proj-cR68...` (EXPOSED)
  - Action: Regenerate at https://platform.openai.com/api-keys
  - Update in: Environment variables only

- [ ] **Supabase Service Role Key**
  - Current: `eyJhbGciOiJIUzI1NiI...` (EXPOSED)
  - Action: Regenerate in Supabase dashboard > Settings > API
  - Update in: Environment variables only

- [ ] **Upstash Redis Token**
  - Current: `AV2WAAIjcDE...` (EXPOSED)
  - Action: Regenerate at https://console.upstash.com
  - Update in: Environment variables only

- [ ] **Figma Access Token**
  - Current: `figd_bR2cafXD...` (EXPOSED)
  - Action: Regenerate in Figma settings
  - Update in: Environment variables only

- [ ] **Kakao REST API Key**
  - Current: `966326ff2bcc...` (EXPOSED)
  - Action: Regenerate in Kakao developers console
  - Update in: Environment variables only

### Medium Priority (Internal Keys)
- [ ] **Internal API Key**
  - Current: `eb68fe1fbb80...` (EXPOSED)
  - Action: Generate new secure random key
  - Update in: Backend configuration

- [ ] **CRON Secret**
  - Current: `092dd8a5b1d1...` (EXPOSED)
  - Action: Generate new secure random key
  - Update in: Backend configuration

## ✅ Android Deployment Security

### Keystore Management
- [ ] Create Android keystore using `android/keystore-setup.sh`
- [ ] Store keystore password in password manager
- [ ] Backup keystore file to secure location
- [ ] Never commit keystore to Git
- [ ] Configure CI/CD with environment variables:
  - `ANDROID_KEYSTORE_PATH`
  - `ANDROID_KEYSTORE_PASSWORD`
  - `ANDROID_KEY_ALIAS`
  - `ANDROID_KEY_PASSWORD`

### Build Security
- [ ] ProGuard/R8 enabled for code obfuscation
- [ ] Sensitive strings removed from code
- [ ] Debug logs disabled in release builds
- [ ] API endpoints using HTTPS only

## ✅ iOS Deployment Security

### Certificate Management
- [ ] Generate iOS distribution certificate
- [ ] Create provisioning profiles (App Store)
- [ ] Configure code signing in Xcode
- [ ] Use Fastlane Match for team certificate management
- [ ] Store certificates in secure repository

### App Transport Security
- [ ] Enforce HTTPS for all network requests
- [ ] Configure Info.plist ATS settings properly
- [ ] No exceptions for HTTP traffic

## ✅ Environment Variables

### Local Development
- [ ] `.env` file created from `.env.example`
- [ ] `.env` added to `.gitignore`
- [ ] All sensitive values in `.env` only

### Production Deployment
- [ ] Use platform environment variables (not files)
- [ ] Different keys for development/staging/production
- [ ] Regular key rotation schedule established

## ✅ Code Security Review

### Authentication
- [ ] OAuth keys not hardcoded
- [ ] JWT secrets properly managed
- [ ] Session management secure

### Data Protection
- [ ] Sensitive data encrypted at rest
- [ ] Secure transmission (HTTPS/TLS)
- [ ] No sensitive data in logs

### Third-party Services
- [ ] API keys in environment variables
- [ ] Service-specific security best practices followed
- [ ] Rate limiting configured

## 🚨 Pre-Deployment Checklist

1. [ ] All exposed API keys rotated
2. [ ] New keys stored securely (not in code)
3. [ ] `.env` file not in Git repository
4. [ ] Android keystore created and secured
5. [ ] iOS certificates configured
6. [ ] Build tested with production configuration
7. [ ] Security scan completed
8. [ ] No debug information in release builds

## 📝 Notes

- **NEVER** commit sensitive information to Git
- Use environment variables for all secrets
- Rotate keys immediately if exposed
- Enable 2FA on all service accounts
- Use separate keys for dev/staging/prod

---

**Last Updated**: 2025-01-08
**Status**: IN PROGRESS - API Key Rotation Required