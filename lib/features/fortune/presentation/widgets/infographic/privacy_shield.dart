import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';

/// 개인정보 숨김 위젯
///
/// 공유 모드에서 개인정보를 마스킹/숨김 처리합니다.
/// 이름, 생년월일, 사진 등 민감한 정보를 보호합니다.
class PrivacyShield extends StatelessWidget {
  const PrivacyShield({
    super.key,
    required this.child,
    required this.isShielded,
    this.style = PrivacyStyle.blur,
    this.placeholder,
    this.blurStrength = 8.0,
  });

  /// 원본 위젯
  final Widget child;

  /// 숨김 활성화 여부
  final bool isShielded;

  /// 숨김 스타일
  final PrivacyStyle style;

  /// 대체 위젯 (PrivacyStyle.replace 사용 시)
  final Widget? placeholder;

  /// 블러 강도 (PrivacyStyle.blur 사용 시)
  final double blurStrength;

  @override
  Widget build(BuildContext context) {
    if (!isShielded) {
      return child;
    }

    return switch (style) {
      PrivacyStyle.blur => _buildBlur(context),
      PrivacyStyle.mask => _buildMask(context),
      PrivacyStyle.replace => _buildReplace(context),
      PrivacyStyle.hide => const SizedBox.shrink(),
      PrivacyStyle.redact => _buildRedact(context),
    };
  }

  Widget _buildBlur(BuildContext context) {
    return ClipRect(
      child: ImageFiltered(
        imageFilter: ColorFilter.mode(
          context.colors.surface.withValues(alpha: 0.8),
          BlendMode.srcOver,
        ),
        child: child,
      ),
    );
  }

  Widget _buildMask(BuildContext context) {
    return Stack(
      children: [
        Opacity(opacity: 0.1, child: child),
        Positioned.fill(
          child: Center(
            child: Icon(
              Icons.visibility_off_rounded,
              color: context.colors.textTertiary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReplace(BuildContext context) {
    return placeholder ??
        Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceSecondary,
            borderRadius: DSRadius.smBorder,
          ),
          child: Center(
            child: Icon(
              Icons.person_off_rounded,
              color: context.colors.textTertiary,
              size: 20,
            ),
          ),
        );
  }

  Widget _buildRedact(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha: 0.8),
        borderRadius: DSRadius.smBorder,
      ),
    );
  }
}

/// 개인정보 숨김 스타일
enum PrivacyStyle {
  /// 블러 처리
  blur,

  /// 마스크 아이콘 오버레이
  mask,

  /// 대체 위젯으로 교체
  replace,

  /// 완전히 숨김
  hide,

  /// 검은 바로 가림
  redact,
}

/// 개인정보 텍스트 숨김 위젯
class PrivacyText extends StatelessWidget {
  const PrivacyText({
    super.key,
    required this.text,
    required this.isShielded,
    this.style,
    this.maskStyle = TextMaskStyle.asterisk,
    this.visibleChars = 0,
  });

  /// 원본 텍스트
  final String text;

  /// 숨김 활성화 여부
  final bool isShielded;

  /// 텍스트 스타일
  final TextStyle? style;

  /// 마스킹 스타일
  final TextMaskStyle maskStyle;

  /// 표시할 글자 수 (앞에서부터)
  final int visibleChars;

  String _getMaskedText() {
    if (text.isEmpty) return '';

    final visible = text.substring(0, visibleChars.clamp(0, text.length));
    final hiddenLength = (text.length - visibleChars).clamp(0, text.length);

    return switch (maskStyle) {
      TextMaskStyle.asterisk => '$visible${'*' * hiddenLength}',
      TextMaskStyle.dot => '$visible${'●' * hiddenLength}',
      TextMaskStyle.dash => '$visible${'-' * hiddenLength}',
      TextMaskStyle.fixed => '$visible***',
      TextMaskStyle.hidden => visible.isEmpty ? '비공개' : '$visible***',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      isShielded ? _getMaskedText() : text,
      style: style,
    );
  }
}

/// 텍스트 마스킹 스타일
enum TextMaskStyle {
  /// 별표 (*)
  asterisk,

  /// 점 (●)
  dot,

  /// 대시 (-)
  dash,

  /// 고정 길이 (***)
  fixed,

  /// "비공개" 또는 부분 표시
  hidden,
}

/// 개인정보 이미지 숨김 위젯
class PrivacyImage extends StatelessWidget {
  const PrivacyImage({
    super.key,
    required this.image,
    required this.isShielded,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.person_rounded,
  });

  /// 원본 이미지
  final ImageProvider image;

  /// 숨김 활성화 여부
  final bool isShielded;

  /// 너비
  final double? width;

  /// 높이
  final double? height;

  /// 이미지 피팅
  final BoxFit fit;

  /// 모서리 반경
  final BorderRadius? borderRadius;

  /// 대체 아이콘
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (isShielded) {
      content = Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: context.colors.surfaceSecondary,
          borderRadius: borderRadius ?? DSRadius.mdBorder,
          border: Border.all(
            color: context.colors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(
            placeholderIcon,
            size: (width ?? 48) * 0.5,
            color: context.colors.textTertiary,
          ),
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: borderRadius ?? DSRadius.mdBorder,
        child: Image(
          image: image,
          width: width,
          height: height,
          fit: fit,
        ),
      );
    }

    return content;
  }
}

/// 개인정보 날짜 숨김 위젯
class PrivacyDate extends StatelessWidget {
  const PrivacyDate({
    super.key,
    required this.date,
    required this.isShielded,
    this.style,
    this.format = DatePrivacyFormat.yearOnly,
  });

  /// 원본 날짜
  final DateTime date;

  /// 숨김 활성화 여부
  final bool isShielded;

  /// 텍스트 스타일
  final TextStyle? style;

  /// 숨김 시 표시 형식
  final DatePrivacyFormat format;

  String _formatDate() {
    if (!isShielded) {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }

    return switch (format) {
      DatePrivacyFormat.yearOnly => '${date.year}년생',
      DatePrivacyFormat.yearMonth => '${date.year}년 ${date.month}월생',
      DatePrivacyFormat.hidden => '비공개',
      DatePrivacyFormat.masked => '${date.year}년 **월 **일',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDate(),
      style: style,
    );
  }
}

/// 날짜 숨김 형식
enum DatePrivacyFormat {
  /// 년도만 표시 (1990년생)
  yearOnly,

  /// 년월까지 표시 (1990년 3월생)
  yearMonth,

  /// "비공개"로 표시
  hidden,

  /// 마스킹 (1990년 **월 **일)
  masked,
}

/// 공유 모드 상태 관리를 위한 InheritedWidget
class PrivacyModeProvider extends InheritedWidget {
  const PrivacyModeProvider({
    super.key,
    required this.isShareMode,
    required super.child,
  });

  /// 공유 모드 여부
  final bool isShareMode;

  static PrivacyModeProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrivacyModeProvider>();
  }

  /// 현재 공유 모드인지 확인 (기본값: false)
  static bool isSharing(BuildContext context) {
    return of(context)?.isShareMode ?? false;
  }

  @override
  bool updateShouldNotify(PrivacyModeProvider oldWidget) {
    return isShareMode != oldWidget.isShareMode;
  }
}

/// 개인정보 보호 설정
class PrivacyConfig {
  const PrivacyConfig({
    this.hideName = true,
    this.hideBirthDate = true,
    this.hidePhoto = true,
    this.hideLocation = true,
    this.partialName = false,
    this.partialDate = true,
  });

  /// 이름 숨김
  final bool hideName;

  /// 생년월일 숨김
  final bool hideBirthDate;

  /// 사진 숨김
  final bool hidePhoto;

  /// 위치 정보 숨김
  final bool hideLocation;

  /// 이름 부분 표시 (김**)
  final bool partialName;

  /// 날짜 부분 표시 (1990년생)
  final bool partialDate;

  /// 기본 설정
  static const PrivacyConfig defaults = PrivacyConfig();

  /// 모두 숨김
  static const PrivacyConfig hideAll = PrivacyConfig(
    hideName: true,
    hideBirthDate: true,
    hidePhoto: true,
    hideLocation: true,
    partialName: false,
    partialDate: false,
  );

  /// 최소 숨김 (이름, 사진만)
  static const PrivacyConfig minimal = PrivacyConfig(
    hideName: true,
    hideBirthDate: false,
    hidePhoto: true,
    hideLocation: false,
    partialName: true,
    partialDate: true,
  );
}

/// 개인정보 설정 제공자
class PrivacyConfigProvider extends InheritedWidget {
  const PrivacyConfigProvider({
    super.key,
    required this.config,
    required this.isShareMode,
    required super.child,
  });

  /// 개인정보 설정
  final PrivacyConfig config;

  /// 공유 모드 여부
  final bool isShareMode;

  static PrivacyConfigProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrivacyConfigProvider>();
  }

  /// 이름을 숨겨야 하는지 확인
  static bool shouldHideName(BuildContext context) {
    final provider = of(context);
    if (provider == null || !provider.isShareMode) return false;
    return provider.config.hideName;
  }

  /// 생년월일을 숨겨야 하는지 확인
  static bool shouldHideBirthDate(BuildContext context) {
    final provider = of(context);
    if (provider == null || !provider.isShareMode) return false;
    return provider.config.hideBirthDate;
  }

  /// 사진을 숨겨야 하는지 확인
  static bool shouldHidePhoto(BuildContext context) {
    final provider = of(context);
    if (provider == null || !provider.isShareMode) return false;
    return provider.config.hidePhoto;
  }

  @override
  bool updateShouldNotify(PrivacyConfigProvider oldWidget) {
    return config != oldWidget.config || isShareMode != oldWidget.isShareMode;
  }
}
