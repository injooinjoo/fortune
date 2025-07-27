# 📚 Fortune Project Master Documentation Index

> **Last Updated**: 2025-07-26  
> **Version**: 2.0.0  
> **Purpose**: Central hub for all Fortune project documentation

## 🎯 Quick Navigation

### For Users
- [🇰🇷 한국어 사용자 가이드](fortune_flutter/docs/user-guide/korean-user-guide.md)
- [🎴 Fortune Types Catalog](docs/01-fortunes/README.md) - All 74 fortune types
- [📱 Mobile App Features](fortune_flutter/docs/features/README.md)
- [🆘 Troubleshooting Guide](fortune_flutter/docs/troubleshooting/common-issues.md)

### For Developers
- [🚀 Getting Started](docs/00-getting-started/README.md)
- [💻 Development Guide](docs/02-development/README.md)
- [🏗️ Architecture Overview](docs/03-architecture/README.md)
- [🧪 Testing Guide](fortune_flutter/docs/testing/README.md)
- [📦 Deployment Guide](docs/04-deployment/README.md)

### For Designers
- [🎨 Design Philosophy](docs/06-design/00-design-philosophy.md) - 모노크롬 디자인 철학
- [🎨 Figma Design System](fortune_flutter/docs/design/figma-integration.md)
- [🖼️ Fortune Card Designs](fortune_flutter/lib/core/constants/fortune_card_images.dart)
- [🎯 UI/UX Guidelines](fortune_flutter/docs/design/ui-guidelines.md)

## 📂 Documentation Structure

### 1. **Main Documentation** (`/docs/`)
```
docs/
├── 00-getting-started/      # Project setup and prerequisites
├── 01-fortunes/             # Fortune types documentation
├── 02-development/          # Development guides
├── 03-architecture/         # System architecture
├── 04-deployment/           # Deployment procedures
├── 05-monitoring/           # Monitoring and analytics
├── 06-security/             # Security guidelines
├── 07-integrations/         # Third-party integrations
├── 08-testing/              # Testing strategies
└── README.md               # Documentation overview
```

### 2. **Flutter App Documentation** (`/fortune_flutter/docs/`)
```
fortune_flutter/docs/
├── architecture/            # Flutter app architecture
├── design/                 # Design system and UI
├── features/               # Feature documentation
├── performance/            # Performance optimization
├── security/               # App security
├── testing/                # Flutter testing
├── troubleshooting/        # Common issues
├── user-guide/             # End-user documentation
└── README.md              # Flutter docs overview
```

### 3. **API Documentation** (`/supabase/`)
```
supabase/
├── functions/              # Edge functions documentation
├── migrations/             # Database schema docs
└── README.md              # Supabase overview
```

### 4. **Specialized Documentation**
- **Investment Fortune**: [Investment Feature Documentation](docs/investment_fortune_feature.md)
- **Ex-Lover Fortune**: [Ex-Lover Improvements](fortune_flutter/docs/ex_lover_fortune_improvements.md)
- **Physiognomy Flow**: [Face Reading Documentation](fortune_flutter/docs/physiognomy_flow.md)
- **Navigation System**: [Navigation Architecture](NAVIGATION_FIX_SUMMARY.md)
- **Tarot System**: [Tarot Navigation](TAROT_NAVIGATION_FIX.md)

## 📊 Documentation Status

### ✅ Up-to-Date (Updated within 30 days)
- Flutter app documentation
- Deployment guides
- Security documentation
- Korean user guide
- Fortune types catalog

### ⚠️ Needs Review (Updated 30-90 days ago)
- Architecture documentation
- Testing strategies
- Integration guides

### 🔴 Outdated (Updated >90 days ago)
- Archive folder content (marked for removal)
- Some native platform guides

## 🔄 Recent Updates

### 2025-07 Updates
- Added investment fortune feature documentation
- Updated navigation system documentation
- Enhanced Korean language support
- Added physiognomy (face reading) flow documentation
- Consolidated ex-lover fortune improvements
- Updated design documentation to reflect monochrome theme
- Updated Edge Functions list (100+ functions)
- Added design philosophy document

### 2025-06 Updates
- Introduced comprehensive testing documentation
- Added performance optimization guides
- Enhanced security documentation

## 📝 Documentation Standards

### File Naming Convention
- Use kebab-case for file names: `user-guide.md`
- Use descriptive names that indicate content
- Include version numbers for versioned docs: `api-v2.md`

### Document Structure
1. **Title**: Clear, descriptive title
2. **Metadata**: Last updated date, version, author
3. **Table of Contents**: For documents >500 words
4. **Content**: Well-organized with headers
5. **Examples**: Include code examples where relevant
6. **References**: Link to related documentation

### Quality Checklist
- [ ] Clear and concise language
- [ ] Code examples are tested and working
- [ ] Screenshots are up-to-date
- [ ] Links are valid and not broken
- [ ] Korean translations are accurate
- [ ] Version information is current

## 🛠️ Maintenance Tasks

### Weekly
- [ ] Review and update quick navigation links
- [ ] Check for broken links
- [ ] Update "Recent Updates" section

### Monthly
- [ ] Review documentation status
- [ ] Archive outdated content
- [ ] Update version numbers
- [ ] Sync with development changes

### Quarterly
- [ ] Comprehensive documentation audit
- [ ] User feedback integration
- [ ] Translation updates
- [ ] Performance metrics review

## 🤝 Contributing to Documentation

### How to Contribute
1. Follow the documentation standards above
2. Update this index when adding new docs
3. Include metadata in all documents
4. Test all code examples
5. Request review for significant changes

### Documentation Templates
- [Feature Documentation Template](docs/templates/feature-template.md)
- [API Documentation Template](docs/templates/api-template.md)
- [User Guide Template](docs/templates/user-guide-template.md)

## 📞 Contact & Support

- **Documentation Issues**: Create an issue in the repository
- **Questions**: Contact the development team
- **Suggestions**: Submit a pull request with improvements

---

*This master index is the single source of truth for all Fortune project documentation. Keep it updated and synchronized with actual documentation changes.*