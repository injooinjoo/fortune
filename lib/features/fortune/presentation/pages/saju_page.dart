import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../core/components/toss_button.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../services/saju_calculation_service.dart';
import '../../../../presentation/providers/user_profile_notifier.dart';

/// 토스 스타일 사주팔자 페이지
class SajuPage extends ConsumerStatefulWidget {
  const SajuPage({super.key});

  @override
  ConsumerState<SajuPage> createState() => _SajuPageState();
}

class _SajuPageState extends ConsumerState<SajuPage> {
  Map<String, dynamic>? _sajuData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSajuData();
  }

  Future<void> _loadSajuData() async {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile?.birthDate != null) {
      setState(() {
        _sajuData = SajuCalculationService.calculateSaju(
          birthDate: userProfile!.birthDate!,
          birthTime: userProfile.birthTime,
        );
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider).value;

    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      appBar: AppHeader(
        title: '사주팔자',
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: TossTheme.primaryBlue,
              ),
            )
          : userProfile?.birthDate == null
              ? _buildNoBirthDateView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(TossTheme.spacingL),
                  child: Column(
                    children: [
                      // 사용자 정보 카드
                      _buildUserInfoCard(userProfile!),
                      const SizedBox(height: TossTheme.spacingL),
                      
                      // 사주 팔자 카드
                      _buildSajuMainCard(),
                      const SizedBox(height: TossTheme.spacingL),
                      
                      // 십신 분석 카드
                      _buildTenGodsCard(),
                      const SizedBox(height: TossTheme.spacingL),
                      
                      // 오행 분석 카드
                      _buildElementsCard(),
                      const SizedBox(height: TossTheme.spacingL),
                      
                      // 십이운성 카드
                      _buildTwelveStatesCard(),
                      const SizedBox(height: TossTheme.spacingL),
                      
                      // 특수 정보 카드
                      _buildSpecialInfoCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildNoBirthDateView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TossTheme.spacingL),
        child: TossCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cake_outlined,
                size: 64,
                color: TossTheme.textGray400,
              ),
              const SizedBox(height: TossTheme.spacingL),
              Text(
                '생년월일 정보가 필요해요',
                style: TossTheme.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossTheme.spacingS),
              Text(
                '사주팔자를 보려면 프로필에서\n생년월일을 설정해주세요',
                style: TossTheme.caption.copyWith(color: TossTheme.textGray500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: TossTheme.spacingL),
              TossButton(
                text: '프로필 설정하기',
                size: TossButtonSize.medium,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic userProfile) {
    final birthDate = userProfile.birthDate as DateTime;
    final formatter = DateFormat('yyyy년 M월 d일');

    return TossSectionCard(
      title: '기본 정보',
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(TossTheme.radiusM),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: TossTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: TossTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.name ?? '사용자',
                      style: TossTheme.heading4,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatter.format(birthDate),
                      style: TossTheme.caption.copyWith(color: TossTheme.textGray500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSajuMainCard() {
    if (_sajuData == null) return const SizedBox.shrink();

    return TossSectionCard(
      title: '사주팔자',
      subtitle: '네 개의 기둥으로 보는 운명',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildPillar('년주', _sajuData!['year'])),
              const SizedBox(width: TossTheme.spacingS),
              Expanded(child: _buildPillar('월주', _sajuData!['month'])),
              const SizedBox(width: TossTheme.spacingS),
              Expanded(child: _buildPillar('일주', _sajuData!['day'])),
              const SizedBox(width: TossTheme.spacingS),
              Expanded(child: _buildPillar('시주', _sajuData!['hour'])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillar(String title, Map<String, dynamic>? pillar) {
    if (pillar == null) {
      return _buildEmptyPillar(title);
    }

    final elementColor = _getElementColor(pillar['element']);

    return Container(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      decoration: BoxDecoration(
        color: elementColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(
          color: elementColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TossTheme.caption.copyWith(color: TossTheme.textGray500),
          ),
          const SizedBox(height: TossTheme.spacingS),
          Text(
            pillar['stemHanja'] ?? '?',
            style: TossTheme.heading1.copyWith(
              color: elementColor,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            pillar['branchHanja'] ?? '?',
            style: TossTheme.heading1.copyWith(
              color: elementColor,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: TossTheme.spacingXS),
          Text(
            '${pillar['stem'] ?? '?'}${pillar['branch'] ?? '?'}',
            style: TossTheme.caption.copyWith(
              color: TossTheme.textGray400,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPillar(String title) {
    return Container(
      padding: const EdgeInsets.all(TossTheme.spacingM),
      decoration: BoxDecoration(
        color: TossTheme.borderGray200,
        borderRadius: BorderRadius.circular(TossTheme.radiusM),
        border: Border.all(
          color: TossTheme.borderGray300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TossTheme.caption.copyWith(color: TossTheme.textGray500),
          ),
          const SizedBox(height: TossTheme.spacingS),
          Icon(
            Icons.help_outline,
            color: TossTheme.textGray400,
            size: 40,
          ),
          const SizedBox(height: TossTheme.spacingXS),
          Text(
            '시간\n미입력',
            style: TossTheme.caption.copyWith(
              color: TossTheme.textGray400,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTenGodsCard() {
    if (_sajuData == null || _sajuData!['tenGods'] == null) {
      return const SizedBox.shrink();
    }

    final tenGods = _sajuData!['tenGods'] as Map<String, dynamic>;

    return TossSectionCard(
      title: '십신 분석',
      subtitle: '성격과 재능을 나타내는 요소',
      child: Column(
        children: tenGods.entries.map((entry) {
          final position = entry.key;
          final gods = entry.value as List<String>;

          return Padding(
            padding: const EdgeInsets.only(bottom: TossTheme.spacingM),
            child: Row(
              children: [
                Container(
                  width: 60,
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$position간',
                    style: TossTheme.body3.copyWith(color: TossTheme.textGray500),
                  ),
                ),
                const SizedBox(width: TossTheme.spacingM),
                Expanded(
                  child: Wrap(
                    spacing: TossTheme.spacingS,
                    children: gods.map((god) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: TossTheme.spacingS,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTenGodColor(god).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(TossTheme.radiusS),
                        border: Border.all(
                          color: _getTenGodColor(god).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        god,
                        style: TossTheme.caption.copyWith(
                          color: _getTenGodColor(god),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildElementsCard() {
    if (_sajuData == null || _sajuData!['elements'] == null) {
      return const SizedBox.shrink();
    }

    final elements = _sajuData!['elements'] as Map<String, int>;

    return TossSectionCard(
      title: '오행 분석',
      subtitle: '나의 오행 균형 상태',
      child: Column(
        children: elements.entries.map((entry) {
          final element = entry.key;
          final value = entry.value;
          final color = _getElementColor(element);
          final percentage = value / 100.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: TossTheme.spacingM),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: TossTheme.spacingS),
                        Text(
                          element,
                          style: TossTheme.body3,
                        ),
                      ],
                    ),
                    Text(
                      '$value%',
                      style: TossTheme.body3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TossTheme.spacingXS),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: TossTheme.borderGray200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTwelveStatesCard() {
    if (_sajuData == null || _sajuData!['twelveStates'] == null) {
      return const SizedBox.shrink();
    }

    final twelveStates = _sajuData!['twelveStates'] as List<String>;

    return TossSectionCard(
      title: '십이운성',
      subtitle: '인생의 흐름과 운세',
      child: Wrap(
        spacing: TossTheme.spacingS,
        runSpacing: TossTheme.spacingS,
        children: twelveStates.map((state) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TossTheme.spacingM,
            vertical: TossTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: TossTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(TossTheme.radiusM),
            border: Border.all(
              color: TossTheme.primaryBlue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            state,
            style: TossTheme.body3.copyWith(
              color: TossTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSpecialInfoCard() {
    return TossSectionCard(
      title: '특수 정보',
      child: Column(
        children: [
          TossListItemCard(
            leading: Icon(
              Icons.stars,
              color: Colors.amber,
              size: 24,
            ),
            title: '공망',
            subtitle: '허무함을 나타내는 요소',
          ),
          const SizedBox(height: TossTheme.spacingS),
          TossListItemCard(
            leading: Icon(
              Icons.flash_on,
              color: Colors.orange,
              size: 24,
            ),
            title: '역마살',
            subtitle: '이동과 변화를 나타냄',
          ),
          const SizedBox(height: TossTheme.spacingS),
          TossListItemCard(
            leading: Icon(
              Icons.auto_awesome,
              color: Colors.purple,
              size: 24,
            ),
            title: '화개살',
            subtitle: '예술적 재능과 종교성',
          ),
        ],
      ),
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case '목':
      case '목(木)':
        return const Color(0xFF10B981);
      case '화':
      case '화(火)':
        return const Color(0xFFEF4444);
      case '토':
      case '토(土)':
        return const Color(0xFF92400E);
      case '금':
      case '금(金)':
        return const Color(0xFFF59E0B);
      case '수':
      case '수(水)':
        return TossTheme.primaryBlue;
      default:
        return TossTheme.textGray400;
    }
  }

  Color _getTenGodColor(String god) {
    switch (god) {
      case '비견':
      case '겁재':
        return const Color(0xFF3B82F6);
      case '식신':
      case '상관':
        return const Color(0xFF10B981);
      case '정재':
      case '편재':
        return const Color(0xFFF59E0B);
      case '정관':
      case '편관':
        return const Color(0xFFEF4444);
      case '정인':
      case '편인':
        return const Color(0xFF8B5CF6);
      default:
        return TossTheme.textGray400;
    }
  }
}