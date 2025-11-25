운세 페이지를 표준 템플릿으로 생성합니다.

## 입력 정보

- **운세 유형**: $ARGUMENTS 또는 사용자에게 질문 (예: daily, tarot, saju)
- **입력 필드**: 사용자 입력이 필요한 필드들
- **토큰 소비량**: Simple(1), Medium(2), Complex(3), Premium(5)

## 생성 위치

```
lib/features/fortune/presentation/pages/{type}_fortune_page.dart
```

## 생성 템플릿

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:fortune/core/widgets/unified_fortune_base_widget.dart';
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';
import 'package:fortune/core/services/debug_premium_service.dart';
import 'package:fortune/presentation/providers/token_provider.dart';

class {Type}FortunePage extends ConsumerStatefulWidget {
  const {Type}FortunePage({super.key});

  @override
  ConsumerState<{Type}FortunePage> createState() => _{Type}FortunePageState();
}

class _{Type}FortunePageState extends ConsumerState<{Type}FortunePage> {
  bool _isBlurred = true;
  bool _isShowingAd = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? TossDesignSystem.backgroundDark
          : TossDesignSystem.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? TossDesignSystem.backgroundDark
            : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '{운세 제목}',
          style: context.heading3.copyWith(
            color: isDark
                ? TossDesignSystem.textPrimaryDark
                : TossDesignSystem.textPrimaryLight,
          ),
        ),
        centerTitle: true,
      ),
      body: UnifiedFortuneBaseWidget(
        fortuneType: '{fortune_type}',
        onResult: (result) {
          // 결과 처리
        },
        builder: (context, state) {
          // 입력 폼 또는 결과 위젯 반환
          return _buildContent(state);
        },
      ),
    );
  }

  Widget _buildContent(FortuneState state) {
    if (state.isLoading) {
      return const TossFortuneLoadingScreen();
    }

    if (state.error != null) {
      return ErrorWidget(message: state.error!);
    }

    if (state.result != null) {
      return _buildResult(state.result!);
    }

    return _buildInputForm();
  }

  Widget _buildInputForm() {
    // 입력 폼 구현
  }

  Widget _buildResult(FortuneResult result) {
    return Column(
      children: [
        // 블러 처리가 필요한 섹션
        UnifiedBlurWrapper(
          isBlurred: _isBlurred,
          sectionKey: 'advice',
          child: _buildAdviceSection(result),
        ),

        // 광고 버튼
        if (_isBlurred)
          UnifiedAdUnlockButton(
            onPressed: _showAdAndUnblur,
          ),
      ],
    );
  }

  Future<void> _showAdAndUnblur() async {
    if (_isShowingAd) return;

    try {
      _isShowingAd = true;
      // 광고 로직 구현

      setState(() {
        _isBlurred = false;
        _isShowingAd = false;
      });
    } catch (e) {
      _isShowingAd = false;
    }
  }
}
```

## 체크리스트

- [ ] UnifiedFortuneBaseWidget 사용
- [ ] 프리미엄 확인 로직 (DebugPremiumService)
- [ ] UnifiedBlurWrapper 블러 처리
- [ ] 토큰 소비 로직
- [ ] isDark 다크모드 대응
- [ ] Icons.arrow_back_ios 뒤로가기

## 관련 Agent

- fortune-domain-expert
- toss-design-guardian

