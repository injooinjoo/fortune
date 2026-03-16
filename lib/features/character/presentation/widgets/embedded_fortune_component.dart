import 'package:flutter/material.dart';

import '../../../../core/constants/tarot/tarot_card_catalog.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/widgets/smart_image.dart';

class EmbeddedFortuneComponent extends StatelessWidget {
  final String embeddedWidgetType;
  final Map<String, dynamic> componentData;

  const EmbeddedFortuneComponent({
    super.key,
    required this.embeddedWidgetType,
    required this.componentData,
  });

  static bool supportsType(String? type) {
    switch (type) {
      case 'fortune_result_card':
      case 'tarot_spread':
      case 'dream_result':
      case 'face_reading_result':
      case 'fortune_cookie':
      case 'worry_bead_session':
      case 'dream_journal_entry':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (embeddedWidgetType) {
      case 'fortune_cookie':
        return _buildFortuneCookie(context);
      case 'tarot_spread':
        return _buildTarotSpread(context);
      case 'dream_result':
        return _buildDreamResult(context);
      case 'face_reading_result':
        return _buildFaceReadingResult(context);
      case 'worry_bead_session':
        return _buildCompactSession(
          context,
          title: _stringValue(componentData['title']) ?? '걱정 구슬',
          description: _stringValue(componentData['summary']) ??
              '마음을 정리하는 대화 세션이 준비됐어요.',
          icon: Icons.spa_outlined,
        );
      case 'dream_journal_entry':
        return _buildCompactSession(
          context,
          title: _stringValue(componentData['title']) ?? '꿈 기록',
          description: _stringValue(componentData['summary']) ??
              '꿈 기록을 채팅 안에서 다시 이어갈 수 있어요.',
          icon: Icons.menu_book_outlined,
        );
      case 'fortune_result_card':
      default:
        return _buildFortuneResultCard(context);
    }
  }

  Widget _buildFortuneResultCard(BuildContext context) {
    final title = _stringValue(componentData['title']) ?? '운세 결과';
    final summary = _stringValue(componentData['summary']) ??
        _stringValue(componentData['content']) ??
        '결과를 정리했어요.';
    final highlights = _stringList(componentData['highlights']);
    final luckyItems = _displayEntries(componentData['luckyItems']);
    final recommendations = _stringList(componentData['recommendations']);
    final warnings = _stringList(componentData['warnings']);

    return _buildCardShell(
      context,
      title: title,
      score: _intValue(componentData['score']),
      icon: Icons.auto_awesome_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(summary, style: context.bodyMedium),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.sm),
            _buildTagWrap(context, highlights),
          ],
          if (luckyItems.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '행운 포인트'),
            const SizedBox(height: DSSpacing.xs),
            _buildInfoWrap(context, luckyItems),
          ],
          if (recommendations.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '추천'),
            const SizedBox(height: DSSpacing.xs),
            _buildTextLines(context, recommendations),
          ],
          if (warnings.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '주의'),
            const SizedBox(height: DSSpacing.xs),
            _buildTextLines(context, warnings),
          ],
        ],
      ),
    );
  }

  Widget _buildFortuneCookie(BuildContext context) {
    final emoji = _stringValue(componentData['emoji']) ?? '🥠';
    final message = _stringValue(componentData['message']) ??
        _stringValue(componentData['summary']) ??
        '오늘의 메시지를 준비했어요.';
    final infoItems = <String>[
      if (_stringValue(componentData['luckyNumber']) != null)
        '행운 숫자 ${_stringValue(componentData['luckyNumber'])}',
      if (_stringValue(componentData['luckyColor']) != null)
        '행운 컬러 ${_stringValue(componentData['luckyColor'])}',
      if (_stringValue(componentData['luckyTime']) != null)
        '행운 시간 ${_stringValue(componentData['luckyTime'])}',
    ];

    return _buildCardShell(
      context,
      title: _stringValue(componentData['title']) ?? '오늘의 메시지',
      score: _intValue(componentData['score']),
      icon: Icons.cookie_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
              child: Text(
                emoji,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          Text(
            message,
            style: context.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (infoItems.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildInfoWrap(context, infoItems),
          ],
          if (_stringValue(componentData['actionMission']) != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '오늘의 실천'),
            const SizedBox(height: DSSpacing.xs),
            Text(
              _stringValue(componentData['actionMission'])!,
              style: context.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTarotSpread(BuildContext context) {
    final cards = _mapList(componentData['cards']);
    final interpretations =
        _displayEntries(componentData['positionInterpretations']);
    final summary = _stringValue(componentData['overallInterpretation']) ??
        _stringValue(componentData['summary']) ??
        '카드가 전하는 흐름을 정리했어요.';
    final deckName = _stringValue(componentData['deckName']);
    final spreadDisplayName =
        _stringValue(componentData['spreadDisplayName']) ??
            _stringValue(componentData['spreadType']);
    final storyTitle = _stringValue(componentData['storyTitle']);
    final guidance = _stringValue(componentData['guidance']);
    final adviceText = _stringValue(componentData['adviceText']);
    final keyThemes = _stringList(componentData['keyThemes']);
    final infoItems = <String>[
      if (_stringValue(componentData['luckyElement']) != null)
        '행운 요소 ${_stringValue(componentData['luckyElement'])!}',
      if (_stringValue(componentData['timeFrame']) != null)
        '유효 기간 ${_stringValue(componentData['timeFrame'])!}',
    ];
    final badges = <String>[
      if (deckName != null) deckName,
      if (spreadDisplayName != null) spreadDisplayName,
      ...keyThemes,
    ];

    return _buildCardShell(
      context,
      title: _stringValue(componentData['title']) ?? '타로 리딩',
      score: _intValue(componentData['score']),
      icon: Icons.style_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badges.isNotEmpty) ...[
            _buildTagWrap(context, badges),
            const SizedBox(height: DSSpacing.sm),
          ],
          if (_stringValue(componentData['question']) != null)
            _buildInsetBlock(
              context,
              child: Text(
                _stringValue(componentData['question'])!,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (storyTitle != null) ...[
            const SizedBox(height: DSSpacing.sm),
            Text(
              storyTitle,
              style: context.headingSmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (cards.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            SizedBox(
              height: 176,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: DSSpacing.sm),
                itemBuilder: (context, index) {
                  final card = cards[index];
                  return _buildTarotCardItem(
                    context,
                    card,
                    deckId: _stringValue(componentData['deckId']) ??
                        _stringValue(componentData['deck']) ??
                        'rider_waite',
                    cardIndex: index,
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: DSSpacing.md),
          Text(summary, style: context.bodyMedium),
          if (guidance != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '핵심 가이드'),
            const SizedBox(height: DSSpacing.xs),
            Text(guidance, style: context.bodyMedium),
          ],
          if (adviceText != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '실천 조언'),
            const SizedBox(height: DSSpacing.xs),
            Text(adviceText, style: context.bodyMedium),
          ],
          if (infoItems.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildInfoWrap(context, infoItems),
          ],
          if (interpretations.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '포지션 해석'),
            const SizedBox(height: DSSpacing.xs),
            _buildTextLines(context, interpretations),
          ],
        ],
      ),
    );
  }

  Widget _buildDreamResult(BuildContext context) {
    final dreamContent = _stringValue(componentData['dreamContent']);
    final chips = <String>[
      if (_stringValue(componentData['emotion']) != null)
        _stringValue(componentData['emotion'])!,
      if (_stringValue(componentData['dreamType']) != null)
        _stringValue(componentData['dreamType'])!,
    ];

    return _buildCardShell(
      context,
      title: _stringValue(componentData['title']) ?? '꿈 해몽',
      score: _intValue(componentData['score']),
      icon: Icons.bedtime_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (chips.isNotEmpty) ...[
            _buildTagWrap(context, chips),
            const SizedBox(height: DSSpacing.sm),
          ],
          if (dreamContent != null && dreamContent.isNotEmpty) ...[
            _buildInsetBlock(
              context,
              child: Text(dreamContent, style: context.bodyMedium),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          Text(
            _stringValue(componentData['summary']) ??
                _stringValue(componentData['content']) ??
                '꿈의 메시지를 정리했어요.',
            style: context.bodyMedium,
          ),
          if (_stringList(componentData['recommendations']).isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '추천'),
            const SizedBox(height: DSSpacing.xs),
            _buildTextLines(
              context,
              _stringList(componentData['recommendations']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFaceReadingResult(BuildContext context) {
    final photoPath = _stringValue(componentData['photoPath']);
    final highlights = _stringList(componentData['highlights']);

    return _buildCardShell(
      context,
      title: _stringValue(componentData['title']) ?? 'Face AI 결과',
      score: _intValue(componentData['score']),
      icon: Icons.face_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoPath != null && photoPath.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(DSRadius.lg),
              child: SmartImage(
                path: photoPath,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorWidget: _buildMediaFallback(context, Icons.face_outlined),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
          ],
          Text(
            _stringValue(componentData['summary']) ??
                _stringValue(componentData['content']) ??
                '분석 결과를 정리했어요.',
            style: context.bodyMedium,
          ),
          if (highlights.isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildTagWrap(context, highlights),
          ],
          if (_stringList(componentData['recommendations']).isNotEmpty) ...[
            const SizedBox(height: DSSpacing.md),
            _buildSectionTitle(context, '추천'),
            const SizedBox(height: DSSpacing.xs),
            _buildTextLines(
              context,
              _stringList(componentData['recommendations']),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompactSession(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return _buildCardShell(
      context,
      title: title,
      icon: icon,
      child: Text(description, style: context.bodyMedium),
    );
  }

  Widget _buildCardShell(
    BuildContext context, {
    required String title,
    required Widget child,
    required IconData icon,
    int? score,
  }) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(top: DSSpacing.xs),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.xl),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DSSpacing.sm),
                decoration: BoxDecoration(
                  color: colors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(DSRadius.lg),
                ),
                child: Icon(icon, color: colors.accent),
              ),
              const SizedBox(width: DSSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: context.headingSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (score != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.sm,
                    vertical: DSSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(DSRadius.full),
                  ),
                  child: Text(
                    '$score점',
                    style: context.labelMedium.copyWith(
                      color: colors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.labelLarge.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTagWrap(BuildContext context, List<String> items) {
    final colors = context.colors;
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.full),
              ),
              child: Text(
                item,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildInfoWrap(BuildContext context, List<String> items) {
    final colors = context.colors;
    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(DSRadius.lg),
              ),
              child: Text(item, style: context.labelMedium),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildTextLines(BuildContext context, List<String> lines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines
          .map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: DSSpacing.xxs),
              child: Text('• $line', style: context.bodyMedium),
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildInsetBlock(BuildContext context, {required Widget child}) {
    final colors = context.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.lg),
      ),
      child: child,
    );
  }

  Widget _buildTarotCardItem(
    BuildContext context,
    Map<String, dynamic> card, {
    required String deckId,
    required int cardIndex,
  }) {
    final colors = context.colors;
    final imagePath =
        _stringValue(card['imagePath']) ?? _stringValue(card['image_path']);
    final title = _stringValue(card['cardNameKr']) ??
        _stringValue(card['card_name_kr']) ??
        _stringValue(card['cardName']) ??
        _stringValue(card['card_name']) ??
        '카드';
    final position = _stringValue(card['positionName']) ??
        _stringValue(card['position_name']) ??
        _stringValue(card['positionKey']) ??
        _stringValue(card['position_key']);
    final isReversed =
        card['isReversed'] == true || card['is_reversed'] == true;

    return GestureDetector(
      key: ValueKey('tarot-result-card-$cardIndex'),
      onTap: () => _showTarotCardDetailSheet(
        context,
        card,
        deckId: deckId,
      ),
      child: SizedBox(
        width: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DSRadius.lg),
                      child: imagePath != null && imagePath.isNotEmpty
                          ? SmartImage(
                              path: imagePath,
                              width: 100,
                              height: 132,
                              fit: BoxFit.cover,
                              errorWidget: _buildMediaFallback(
                                  context, Icons.style_outlined),
                            )
                          : _buildMediaFallback(context, Icons.style_outlined),
                    ),
                  ),
                  if (isReversed)
                    Positioned(
                      left: DSSpacing.xs,
                      top: DSSpacing.xs,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(DSRadius.full),
                        ),
                        child: Text(
                          '역방향',
                          style: context.labelSmall.copyWith(
                            color: colors.surface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              title,
              style: context.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (position != null && position.isNotEmpty)
              Text(
                position,
                style: context.labelSmall.copyWith(
                  color: colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            Text(
              '눌러서 상세 보기',
              style: context.labelSmall.copyWith(
                color: colors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTarotCardDetailSheet(
    BuildContext context,
    Map<String, dynamic> card, {
    required String deckId,
  }) {
    final catalogEntry = TarotCardCatalog.fromCardMap(
      card,
      deckId: deckId,
    );
    final colors = context.colors;
    final title = _stringValue(card['cardNameKr']) ??
        _stringValue(card['card_name_kr']) ??
        catalogEntry.cardNameKr;
    final positionName = _stringValue(card['positionName']) ??
        _stringValue(card['position_name']) ??
        _stringValue(card['positionKey']) ??
        _stringValue(card['position_key']);
    final positionDesc = _stringValue(card['positionDesc']) ??
        _stringValue(card['position_desc']);
    final interpretation = _stringValue(card['interpretation']);
    final isReversed =
        card['isReversed'] == true || card['is_reversed'] == true;
    final keywords = _stringList(card['keywords']).isNotEmpty
        ? _stringList(card['keywords'])
        : catalogEntry.keywords;
    final imagePath = _stringValue(card['imagePath']) ??
        _stringValue(card['image_path']) ??
        catalogEntry.imagePath;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              DSSpacing.lg,
              0,
              DSSpacing.lg,
              DSSpacing.lg,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DSRadius.xl),
                    child: SmartImage(
                      path: imagePath,
                      width: double.infinity,
                      height: 260,
                      fit: BoxFit.cover,
                      errorWidget: _buildMediaFallback(
                        sheetContext,
                        Icons.style_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Wrap(
                    spacing: DSSpacing.xs,
                    runSpacing: DSSpacing.xs,
                    children: [
                      _buildDetailPill(
                        sheetContext,
                        title,
                      ),
                      if (positionName != null)
                        _buildDetailPill(sheetContext, positionName),
                      _buildDetailPill(
                        sheetContext,
                        isReversed ? '역방향' : '정방향',
                      ),
                      _buildDetailPill(
                        sheetContext,
                        catalogEntry.arcana == 'major'
                            ? '메이저 아르카나'
                            : '${catalogEntry.suit} 슈트',
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.md),
                  Text(
                    title,
                    style: context.headingMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    catalogEntry.cardName,
                    style: context.bodyMedium.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  if (positionDesc != null) ...[
                    const SizedBox(height: DSSpacing.md),
                    _buildSectionTitle(sheetContext, '이 위치가 말하는 것'),
                    const SizedBox(height: DSSpacing.xs),
                    Text(positionDesc, style: context.bodyMedium),
                  ],
                  if (interpretation != null) ...[
                    const SizedBox(height: DSSpacing.md),
                    _buildSectionTitle(sheetContext, '이번 리딩 해석'),
                    const SizedBox(height: DSSpacing.xs),
                    Text(interpretation, style: context.bodyMedium),
                  ],
                  const SizedBox(height: DSSpacing.md),
                  _buildSectionTitle(sheetContext, '기본 의미'),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    isReversed
                        ? catalogEntry.reversedMeaning
                        : catalogEntry.uprightMeaning,
                    style: context.bodyMedium,
                  ),
                  if (keywords.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.md),
                    _buildTagWrap(sheetContext, keywords),
                  ],
                  const SizedBox(height: DSSpacing.md),
                  _buildSectionTitle(sheetContext, '카드가 가진 배경'),
                  const SizedBox(height: DSSpacing.xs),
                  Text(
                    catalogEntry.loreSummary,
                    style: context.bodyMedium,
                  ),
                  const SizedBox(height: DSSpacing.md),
                  _buildSectionTitle(sheetContext, '이 카드의 조언'),
                  const SizedBox(height: DSSpacing.xs),
                  Text(catalogEntry.advice, style: context.bodyMedium),
                  if (catalogEntry.reflectionQuestions.isNotEmpty) ...[
                    const SizedBox(height: DSSpacing.md),
                    _buildSectionTitle(sheetContext, '스스로에게 던질 질문'),
                    const SizedBox(height: DSSpacing.xs),
                    _buildTextLines(
                      sheetContext,
                      catalogEntry.reflectionQuestions,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailPill(BuildContext context, String label) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.sm,
        vertical: DSSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(DSRadius.full),
      ),
      child: Text(
        label,
        style: context.labelSmall.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMediaFallback(BuildContext context, IconData icon) {
    final colors = context.colors;
    return Container(
      color: colors.backgroundSecondary,
      child: Center(
        child: Icon(icon, color: colors.textTertiary),
      ),
    );
  }

  List<String> _displayEntries(dynamic value) {
    final map = _asMap(value);
    if (map == null || map.isEmpty) {
      return const [];
    }

    return map.entries
        .where((entry) => _stringValue(entry.value) != null)
        .map(
            (entry) => '${_displayKey(entry.key)} ${_stringValue(entry.value)}')
        .toList(growable: false);
  }

  String _displayKey(String key) {
    final cleaned = key.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    if (cleaned.isEmpty) {
      return '';
    }
    return cleaned;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) => MapEntry(key.toString(), entryValue),
      );
    }
    return null;
  }

  List<Map<String, dynamic>> _mapList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map((item) => _asMap(item))
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value
        .map(_stringValue)
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  String? _stringValue(dynamic value) {
    if (value == null) {
      return null;
    }
    final stringValue = value.toString().trim();
    return stringValue.isEmpty ? null : stringValue;
  }

  int? _intValue(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }
}
