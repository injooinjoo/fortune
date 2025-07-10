import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_fortune_page.dart';
import '../../domain/models/fortune_result.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../presentation/providers/auth_provider.dart';

// A simple fortune page implementation that can be used for pages that don't need custom state management
class SimpleFortunePage extends BaseFortunePage {
  final Widget Function(BuildContext, Function(Map<String, dynamic>)) inputBuilder;
  final Widget Function(BuildContext, FortuneResult, VoidCallback) resultBuilder;
  final LinearGradient? headerGradient;

  const SimpleFortunePage({
    Key? key,
    required String title,
    required String fortuneType,
    required this.inputBuilder,
    required this.resultBuilder,
    this.headerGradient,
    String description = '',
    bool requiresUserInfo = true,
    bool showShareButton = true,
    bool showFontSizeSelector = true,
  }) : super(
          key: key,
          title: title,
          description: description,
          fortuneType: fortuneType,
          requiresUserInfo: requiresUserInfo,
          showShareButton: showShareButton,
          showFontSizeSelector: showFontSizeSelector,
        );

  @override
  ConsumerState<SimpleFortunePage> createState() => _SimpleFortunePageState();
}

class _SimpleFortunePageState extends BaseFortunePageState<SimpleFortunePage> {
  FortuneResult? _fortuneResult;

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    // This method is required by BaseFortunePageState
    // The actual implementation is delegated to the parent's fortune generation logic
    final apiService = ref.read(fortuneApiServiceProvider);
    final user = ref.read(userProvider).value;
    
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }
    
    return await apiService.getFortune(
      fortuneType: widget.fortuneType,
      userId: user.id,
      params: params,
    );
  }

  @override
  Widget buildInputForm() {
    return widget.inputBuilder(context, _generateFortune);
  }

  @override
  Widget buildFortuneResult() {
    if (_fortuneResult == null) {
      // Convert Fortune to FortuneResult on first load
      _fortuneResult = FortuneResult(
        id: fortune!.id,
        type: fortune!.type,
        mainFortune: fortune!.description ?? fortune!.content,
        summary: fortune!.summary ?? '',
        details: fortune!.additionalInfo ?? {},
        sections: {},
        overallScore: fortune!.overallScore,
        scoreBreakdown: fortune!.scoreBreakdown?.map((key, value) => 
          MapEntry(key, value is int ? value : (value as num).toInt())),
        luckyItems: {},
        recommendations: fortune!.recommendations ?? [],
      );
    }
    return widget.resultBuilder(context, _fortuneResult!, _regenerateFortune);
  }

  void _generateFortune(Map<String, dynamic> params) async {
    await generateFortuneAction();
    if (fortune != null) {
      setState(() {
        _fortuneResult = FortuneResult(
          id: fortune!.id,
          type: fortune!.type,
          mainFortune: fortune!.description,
          summary: fortune!.summary ?? '',
          details: fortune!.additionalInfo ?? {},
          sections: {},
          overallScore: null,
          scoreBreakdown: {},
          luckyItems: {},
          recommendations: [],
        );
      });
    }
  }

  void _regenerateFortune() {
    setState(() {
      _fortuneResult = null;
    });
  }
}