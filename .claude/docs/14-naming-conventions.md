# File Naming Conventions

## Core Principle

**ONE canonical name per concept. No version suffixes in production code.**

Git provides version history - file names should describe purpose, not version.

---

## Prohibited Suffixes (CRITICAL)

### NEVER use these suffixes in file names:

| Suffix | Example (WRONG) | Correct Approach |
|--------|-----------------|------------------|
| `_v2`, `_v3` | `payment_service_v2.dart` | Replace original file |
| `_new` | `auth_service_new.dart` | Delete old, use original name |
| `_old` | `cache_service_old.dart` | Delete or use git branches |
| `_enhanced` | `login_page_enhanced.dart` | Improve original in place |
| `_renewed` | `tarot_renewed_page.dart` | Use descriptive name for purpose |
| `_updated` | `profile_updated.dart` | Update original file |
| `.backup` | `service.dart.backup` | Never commit backup files |

### Acceptable `_unified` Usage

`typography_unified.dart` is ALLOWED because "unified" describes the **purpose** (unifying multiple typography systems into one), not a version indicator.

**Rule**: Use `_unified` only when the word "unified" would appear in the class name (e.g., `TypographyUnified`).

---

## Correct Migration Patterns

### Pattern A: Replacing a Service

**WRONG approach:**
```
lib/services/
├── celebrity_service.dart      # old, maybe broken
└── celebrity_service_new.dart  # new version - CONFUSING!
```

**CORRECT approach:**
```bash
# 1. Verify old file has 0 imports
grep -r "celebrity_service.dart" lib/

# 2. Delete old file
git rm lib/services/celebrity_service.dart

# 3. Rename new file to original name
git mv lib/services/celebrity_service_new.dart lib/services/celebrity_service.dart

# 4. Commit with clear message
git commit -m "refactor: Replace celebrity service implementation"
```

### Pattern B: Major Page Redesign

**WRONG:**
```
lib/features/fortune/presentation/pages/
├── tarot_page.dart           # version 1
├── tarot_page_v2.dart        # version 2
└── tarot_renewed_page.dart   # version 3?? Which is current?!
```

**CORRECT - Clean Replacement:**
1. Delete old page entirely
2. Create new page with same name
3. Update routes if class name changed
4. Commit as atomic change

---

## Standard Naming Patterns

### Pages
```
{feature}_{subtype}_page.dart
```

| Example | Description |
|---------|-------------|
| `fortune_daily_page.dart` | Daily fortune page |
| `profile_edit_page.dart` | Profile editing page |
| `tarot_page.dart` | Tarot fortune page |
| `celebrity_fortune_page.dart` | Celebrity comparison page |

### Services
```
{domain}_service.dart
```

| Example | Description |
|---------|-------------|
| `celebrity_service.dart` | Celebrity data operations |
| `social_auth_service.dart` | Social login handling |
| `in_app_purchase_service.dart` | Payment processing |

### Widgets
```
{descriptive_name}_widget.dart
```

| Example | Description |
|---------|-------------|
| `fortune_card_widget.dart` | Fortune result card |
| `profile_avatar_widget.dart` | User avatar display |
| `date_picker_widget.dart` | Date selection component |

### Providers
```
{domain}_provider.dart
```

| Example | Description |
|---------|-------------|
| `auth_provider.dart` | Authentication state |
| `fortune_provider.dart` | Fortune data state |
| `celebrity_provider.dart` | Celebrity list state |

---

## Service Location Rules

### Decision Tree
```
Is service used by multiple features?
├── YES → lib/services/{name}_service.dart
└── NO → Is it feature-specific?
    ├── YES → lib/features/{feature}/data/services/
    └── NO → lib/core/services/
```

### Prohibited Patterns

```bash
# WRONG: Subdirectories in lib/services/ for single files
lib/services/payment/in_app_purchase_service.dart

# CORRECT: Either root or feature location
lib/services/in_app_purchase_service.dart
```

---

## Code Review Checklist

Before approving any PR, verify:

- [ ] No version suffixes (`_v2`, `_new`, `_old`, `_enhanced`, `_renewed`)
- [ ] No `.backup` files committed
- [ ] Services in correct location
- [ ] All imports use consistent paths
- [ ] Old versions deleted, not just renamed
- [ ] Class names match file names (PascalCase ↔ snake_case)

---

## Related Documents

- [02-architecture.md](02-architecture.md) - Project structure
- [13-file-cleanup-log.md](13-file-cleanup-log.md) - Cleanup history
