# File Cleanup Log

## Cleanup Date: 2024-11-27

## Summary
- Files deleted: 20 (6 orphaned + 13 backup + 1 duplicate service)
- Files renamed: 8 (1 service + 7 pages)
- Services consolidated: 2 → 1 (in_app_purchase_service)
- Documents reorganized: 3 renumbered + 2 new

---

## Phase 1: Deleted Files (Orphaned - 0 imports)

| File | Reason |
|------|--------|
| `lib/services/social_auth_service_old.dart` | Explicit old version, unused |
| `lib/services/celebrity_service.dart` | Replaced by celebrity_service_new.dart |
| `lib/services/mbti_fortune_enhanced_service.dart` | Orphaned, never imported |
| `lib/features/fortune/presentation/widgets/enhanced_date_picker.dart` | Orphaned widget |
| `lib/features/fortune/presentation/widgets/enhanced_tarot_card_selection.dart` | Orphaned widget |
| `lib/features/interactive/presentation/widgets/enhanced_tarot_fan_widget.dart` | Orphaned widget |

---

## Phase 2: Deleted Files (.backup)

Git provides version history - backup files unnecessary.

| File |
|------|
| `lib/core/services/personality_dna_service.dart.backup` |
| `lib/core/theme/toss_design_system.dart.backup` |
| `lib/features/profile/presentation/pages/profile_verification_page.dart.backup` |
| `lib/core/constants/tarot_metadata.dart.backup` |
| `lib/core/constants/tarot_minor_arcana.dart.backup` |
| `lib/features/fortune/domain/models/sipseong_talent.dart.backup` |
| `lib/features/interactive/presentation/pages/dream_page.dart.backup` |
| `lib/features/interactive/presentation/pages/dream_interpretation_page.dart.backup` |
| `lib/features/interactive/presentation/pages/psychology_test_page.dart.backup` |
| `lib/features/fortune/presentation/widgets/tarot_card_reveal_widget.dart.backup` |
| `lib/presentation/providers/fortune_provider.dart.backup` |
| `lib/features/fortune/presentation/pages/love/love_fortune_result_page.dart.backup` |
| `lib/features/fortune/presentation/pages/love/love_fortune_main_page.dart.backup` |

---

## Phase 3: Renamed Service

| Old Name | New Name | Affected Files |
|----------|----------|----------------|
| `lib/services/celebrity_service_new.dart` | `lib/services/celebrity_service.dart` | `lib/presentation/providers/celebrity_provider.dart` |

---

## Phase 4: Renamed Pages

| Old Name | New Name | Route File |
|----------|----------|------------|
| `celebrity_fortune_enhanced_page.dart` | `celebrity_fortune_page.dart` | route_config.dart |
| `investment_fortune_enhanced_page.dart` | `investment_fortune_page.dart` | route_config.dart |
| `family_fortune_unified_page.dart` | `family_fortune_page.dart` | route_config.dart |
| `traditional_fortune_unified_page.dart` | `traditional_fortune_page.dart` | traditional_fortune_routes.dart |
| `tarot_renewed_page.dart` | `tarot_page.dart` | traditional_fortune_routes.dart |
| `lucky_items_page_unified.dart` | `lucky_items_page.dart` | lucky_item_routes.dart |

**Note**: `token_purchase_page_v2.dart` → `token_purchase_page.dart` was already done previously.

---

## Phase 5: Service Consolidation

### in_app_purchase_service

Two duplicate services merged:
- `lib/services/in_app_purchase_service.dart` (Supabase-based, simpler)
- `lib/services/payment/in_app_purchase_service.dart` (ApiClient-based, complete)

**Result**: Payment version moved to root, compatibility getters added.

| Affected File | Change |
|---------------|--------|
| `lib/screens/subscription/subscription_page.dart` | Import path updated |
| `lib/presentation/providers/subscription_provider.dart` | Import path updated |
| `lib/services/payment/` folder | Deleted (empty) |

---

## Phase 6: Documentation Reorganization

### Renumbered (Conflict Resolution)

| Old | New |
|-----|-----|
| `09-social-login-status.md` | `10-social-login-status.md` |
| `10-haptic-policy.md` | `11-haptic-policy.md` |
| `10-widget-system.md` | `12-widget-system.md` |

### New Documents

| Number | Name | Purpose |
|--------|------|---------|
| 13 | `13-file-cleanup-log.md` | This file |
| 14 | `14-naming-conventions.md` | Naming rules to prevent recurrence |

---

## Verification

- [x] `flutter analyze` passes (6 pre-existing test issues)
- [x] All routes functional
- [x] Import paths updated
- [x] No broken references

---

## Files NOT Deleted (Still in Use)

| File | Used By |
|------|---------|
| `lib/services/widget_data_manager.dart` | native_features_initializer.dart |
| `lib/services/ab_test_manager.dart` | analytics_tracker.dart |