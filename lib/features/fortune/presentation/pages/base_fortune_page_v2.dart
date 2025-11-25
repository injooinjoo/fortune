import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../shared/components/toast.dart';
import '../../domain/models/fortune_conditions.dart';
import '../../domain/models/fortune_result.dart' as feature;
import '../../../../core/models/fortune_result.dart' as core;
import '../../../../core/services/unified_fortune_service.dart';

/// Basic FortuneConditions implementation for generic use
class BasicFortuneConditions extends FortuneConditions {
  final Map<String, dynamic> data;

  BasicFortuneConditions(this.data);

  @override
  String generateHash() {
    final jsonString = jsonEncode(data);
    final bytes = utf8.encode(jsonString);
    final hash = sha256.convert(bytes);
    return hash.toString().substring(0, 16);
  }

  @override
  Map<String, dynamic> toJson() => data;

  @override
  Map<String, dynamic> toIndexableFields() => data;

  @override
  Map<String, dynamic> buildAPIPayload() => data;
}

/// BaseFortunePageV2
/// 
/// SajuPsychologyFortunePage 등에서 사용하는 구 버전 호환용 베이스 페이지.
/// UnifiedFortuneService를 내부적으로 사용하여 데이터를 가져옵니다.
class BaseFortunePageV2 extends ConsumerStatefulWidget {
  final String title;
  final String fortuneType;
  final Gradient? headerGradient;
  final Widget Function(BuildContext context, Function(Map<String, dynamic>) onSubmit) inputBuilder;
  final Widget Function(BuildContext context, feature.FortuneResult result, VoidCallback onShare) resultBuilder;

  const BaseFortunePageV2({
    super.key,
    required this.title,
    required this.fortuneType,
    this.headerGradient,
    required this.inputBuilder,
    required this.resultBuilder,
  });

  @override
  ConsumerState<BaseFortunePageV2> createState() => _BaseFortunePageV2State();
}

class _BaseFortunePageV2State extends ConsumerState<BaseFortunePageV2> {
  bool _isLoading = false;
  feature.FortuneResult? _fortuneResult;
  late final UnifiedFortuneService _fortuneService;

  @override
  void initState() {
    super.initState();
    _fortuneService = UnifiedFortuneService(Supabase.instance.client);
  }

  Future<void> _handleSubmit(Map<String, dynamic> inputData) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Logger.info('[BaseFortunePageV2] 운세 생성 시작: ${widget.fortuneType}');

      // Use BasicFortuneConditions to wrap the input map
      final conditions = BasicFortuneConditions(inputData);

      final core.FortuneResult result = await _fortuneService.getFortune(
        fortuneType: widget.fortuneType,
        conditions: conditions,
        inputConditions: inputData,
        dataSource: FortuneDataSource.api,
      );

      // Convert core.FortuneResult to feature.FortuneResult
      final featureResult = feature.FortuneResult(
        id: result.id,
        type: result.type,
        fortuneType: result.type,
        createdAt: result.createdAt?.toIso8601String(),
        summary: result.summary['message'] ?? result.summary['content'],
        overallScore: result.score,
        mainFortune: result.data['mainFortune'] ?? result.summary['content'],
        details: result.data['details'],
        result: result.data['result'],
        sections: result.data['sections'] != null ? Map<String, String>.from(result.data['sections']) : null,
        scoreBreakdown: result.data['scoreBreakdown'] != null ? Map<String, int>.from(result.data['scoreBreakdown']) : null,
        luckyItems: result.data['luckyItems'],
        recommendations: result.data['recommendations'] != null ? List<String>.from(result.data['recommendations']) : null,
        additionalInfo: result.data['additionalInfo'],
      );

      if (mounted) {
        setState(() {
          _fortuneResult = featureResult;
          _isLoading = false;
        });
        HapticUtils.success();
      }
    } catch (e, stackTrace) {
      Logger.error('[BaseFortunePageV2] 운세 생성 실패', e, stackTrace);
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        HapticUtils.error();
        Toast.show(
          context,
          message: '운세 생성 중 오류가 발생했습니다: $e',
          type: ToastType.error,
        );
      }
    }
  }

  void _handleShare() {
    Logger.info('Share button clicked');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: widget.headerGradient != null
            ? Container(decoration: BoxDecoration(gradient: widget.headerGradient))
            : null,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: widget.headerGradient != null ? Colors.white : (isDark ? Colors.white : Colors.black),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: TypographyUnified.heading4.copyWith(
            color: widget.headerGradient != null ? Colors.white : (isDark ? Colors.white : Colors.black),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_fortuneResult != null
              ? SingleChildScrollView(
                  child: widget.resultBuilder(context, _fortuneResult!, _handleShare),
                )
              : Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: widget.inputBuilder(context, _handleSubmit),
                )),
    );
  }
}