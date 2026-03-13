# Card Component Taxonomy

## Purpose

This document records the current card families used in the Fortune app and the shared component that should own each pattern.

## Shared Families

| Family | Shared component | Purpose |
| --- | --- | --- |
| Surface | `FortuneCardSurface` | Common shell for bordered, tinted, clickable, and accent-striped cards |
| Badge | `FortuneCardBadge` | Small metadata, state, or highlight chips |
| Metric pill | `FortuneMetricPill` | Compact score/value pills inside record cards |
| Feature / hero | `FortuneFeatureCard` | Summary cards with eyebrow, title, description, and highlight chips |
| Record / list | `FortuneRecordCard` | Timeline/history cards with metadata row, summary, and footer pills |
| Section | `FortuneSectionCard` | Titled content sections that group a body under shared card chrome |
| Result frame | `FortuneResultFrame` | Large result containers with an accent stripe and stacked content |

## Current Card Inventory

| Current card type | Current source | Shared family target |
| --- | --- | --- |
| Insight history card | `lib/features/chat_insight/presentation/widgets/insight_history_card.dart` | `FortuneRecordCard` + `FortuneMetricPill` |
| Today iljin card | `lib/features/fortune/presentation/widgets/saju/today_iljin_card.dart` | `FortuneCardSurface` + `FortuneCardBadge` |
| Chat saju result card | `lib/features/chat/presentation/widgets/chat_saju_result_card.dart` | `FortuneResultFrame` |
| Legacy app card wrapper | `lib/core/components/app_card.dart` | Adapter over `FortuneCardSurface` |
| Legacy custom card wrapper | `lib/presentation/widgets/common/custom_card.dart` | Adapter over `FortuneCardSurface` |
| Loading skeleton card | `lib/shared/components/loading_states.dart` | `DSCard`-backed, no migration required |

## Foundation Rules

1. New cards should start from `FortuneCardSurface` or a higher-level `Fortune*Card` family component.
2. Do not introduce new `Container + BoxDecoration` card shells when an existing family covers the pattern.
3. `AppCard` and `CustomCard` are compatibility adapters, not the preferred authoring API for new UI.
4. Domain-specific cards should keep their data/rendering logic, but card chrome should come from the shared family.
