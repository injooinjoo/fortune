import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../../../../core/design_system/tokens/ds_colors.dart';
import '../../../../../core/design_system/tokens/ds_typography.dart';

/// 프리미엄 사주명리서 리더 페이지
class PremiumSajuReaderPage extends ConsumerStatefulWidget {
  final String resultId;

  const PremiumSajuReaderPage({
    super.key,
    required this.resultId,
  });

  @override
  ConsumerState<PremiumSajuReaderPage> createState() =>
      _PremiumSajuReaderPageState();
}

class _PremiumSajuReaderPageState extends ConsumerState<PremiumSajuReaderPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentChapterIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? _result;
  List<dynamic> _chapters = [];
  final List<dynamic> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadResult();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadResult() async {
    // TODO: API 호출
    // final result = await ref.read(premiumSajuServiceProvider).getResult(widget.resultId);
    setState(() {
      _isLoading = false;
      // Mock data for now
      _chapters = [
        {
          'title': '사주팔자 해석',
          'emoji': '📜',
          'partNumber': 1,
          'sections': [
            {
              'title': '당신의 사주팔자',
              'content': '''
## 당신의 사주팔자

당신의 사주팔자는 **갑자(甲子)년, 을축(乙丑)월, 병인(丙寅)일, 정묘(丁卯)시**로 구성되어 있습니다.

### 년주 (年柱) - 갑자
년주는 조상과 부모님의 영향, 그리고 어린 시절의 환경을 나타냅니다.

**갑(甲)**은 천간 중 첫 번째 글자로, 양의 나무 기운을 가지고 있습니다. 마치 하늘을 향해 쭉쭉 뻗어가는 큰 나무와 같이, 당신에게는 성장하고자 하는 강한 의지와 리더십이 있습니다.

### 월주 (月柱) - 을축
월주는 부모님과의 관계, 청소년기, 그리고 형제자매 관계를 나타냅니다.

**을(乙)**은 음의 나무 기운으로, 부드럽고 유연한 성질을 가지고 있습니다. 덩굴처럼 환경에 적응하면서도 꾸준히 목표를 향해 나아가는 모습입니다.

### 일주 (日柱) - 병인
일주는 자기 자신을 나타내며, 사주 분석에서 가장 중요한 기둥입니다.

**병(丙)**은 양의 화 기운으로, 태양과 같이 밝고 따뜻한 에너지를 가지고 있습니다. 당신은 주변 사람들에게 희망과 활력을 주는 존재입니다.

### 시주 (時柱) - 정묘
시주는 말년운과 자녀운, 그리고 인생의 결실을 나타냅니다.

**정(丁)**은 음의 화 기운으로, 촛불과 같이 은은하면서도 따뜻한 빛을 발합니다. 당신의 내면에는 섬세하고 깊은 열정이 있습니다.
              ''',
            },
          ],
        },
      ];
    });
  }

  void _onScroll() {
    // 읽기 진행도 추적
    // TODO: 디바운스 적용하여 서버에 저장
  }

  void _openTableOfContents() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _goToChapter(int index) {
    setState(() => _currentChapterIndex = index);
    Navigator.pop(context); // 드로어 닫기
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _addBookmark() {
    // TODO: 북마크 추가
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('북마크가 추가되었습니다')),
    );
  }

  void _shareSection() {
    // TODO: 섹션 공유
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: DSColors.background,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentChapter =
        _chapters.isNotEmpty ? _chapters[_currentChapterIndex] : null;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: DSColors.background,
      appBar: _buildAppBar(currentChapter),
      drawer: _buildTableOfContentsDrawer(),
      body: currentChapter != null
          ? _buildReaderContent(currentChapter)
          : const Center(child: Text('콘텐츠를 불러오는 중...')),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar(Map<String, dynamic>? chapter) {
    return AppBar(
      backgroundColor: DSColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        '프리미엄 사주명리서',
        style: DSTypography.fortuneSubtitle,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined),
          onPressed: _shareSection,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark_outline),
          onPressed: _addBookmark,
        ),
      ],
    );
  }

  Widget _buildTableOfContentsDrawer() {
    final parts = [
      (
        'Part 1',
        '사주 기초',
        [
          '사주팔자 해석',
          '천간/지지 분석',
          '오행 분포',
          '격국 분석',
          '용신 결정',
        ]
      ),
      (
        'Part 2',
        '성격과 운명',
        [
          '핵심 성격 특성',
          '숨겨진 성향',
          '인생 목적과 사명',
          '강점과 성장 영역',
        ]
      ),
      (
        'Part 3',
        '재물과 직업',
        [
          '재물 패턴 분석',
          '직업 적성',
          '사업/창업 잠재력',
          '투자 성향',
        ]
      ),
      (
        'Part 4',
        '애정과 가정',
        [
          '연애 스타일',
          '결혼 궁합',
          '가족 관계',
          '자녀운',
        ]
      ),
      (
        'Part 5',
        '건강과 수명',
        [
          '체질 건강 분석',
          '취약점과 예방',
          '장수 지표',
        ]
      ),
      (
        'Part 6',
        '인생 타임라인',
        [
          '대운 6주기 분석',
        ]
      ),
    ];

    return Drawer(
      backgroundColor: DSColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('📚', style: TextStyle(fontSize: 24)), // 예외: 이모지
                  const SizedBox(width: 12),
                  Text(
                    '목차',
                    style: DSTypography.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: parts.length,
                itemBuilder: (context, partIndex) {
                  final part = parts[partIndex];
                  return ExpansionTile(
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: DSColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            part.$1,
                            style: DSTypography.labelSmall.copyWith(
                              color: DSColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          part.$2,
                          style: DSTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    children: part.$3.asMap().entries.map((entry) {
                      final chapterIndex = entry.key;
                      final chapterTitle = entry.value;
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 48),
                        title: Text(
                          chapterTitle,
                          style: DSTypography.bodyMedium,
                        ),
                        onTap: () => _goToChapter(0), // TODO: 실제 인덱스 계산
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            // 북마크 탭
            const Divider(),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('북마크'),
              trailing: Text(
                '${_bookmarks.length}개',
                style: DSTypography.labelSmall.copyWith(
                  color: DSColors.textTertiary,
                ),
              ),
              onTap: () {
                // TODO: 북마크 목록 표시
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReaderContent(Map<String, dynamic> chapter) {
    final sections = chapter['sections'] as List<dynamic>? ?? [];

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // 챕터 헤더
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      chapter['emoji'] ?? '📖',
                      style: const TextStyle(fontSize: 32), // 예외: 이모지
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Part ${chapter['partNumber'] ?? 1}',
                            style: DSTypography.labelSmall.copyWith(
                              color: DSColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            chapter['title'] ?? '',
                            style: DSTypography.headingMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentChapterIndex + 1) / _chapters.length,
                  backgroundColor: DSColors.border,
                  valueColor: AlwaysStoppedAnimation(DSColors.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentChapterIndex + 1} / ${_chapters.length} 챕터',
                  style: DSTypography.labelSmall.copyWith(
                    color: DSColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // 섹션 콘텐츠
        ...sections.map((section) {
          return SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MarkdownBody(
                data: section['content'] ?? '',
                styleSheet: MarkdownStyleSheet(
                  h2: DSTypography.headingMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 2,
                  ),
                  h3: DSTypography.headingSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 2,
                  ),
                  p: DSTypography.bodyLarge.copyWith(
                    height: 1.8,
                    color: DSColors.textPrimary,
                  ),
                  strong: DSTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: DSColors.accent,
                  ),
                  blockquote: DSTypography.bodyLarge.copyWith(
                    fontStyle: FontStyle.italic,
                    color: DSColors.textSecondary,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: DSColors.accent,
                        width: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: DSColors.background,
        border: Border(
          top: BorderSide(color: DSColors.border),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // 이전 버튼
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _currentChapterIndex > 0
                    ? () => setState(() => _currentChapterIndex--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('이전'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 목차 버튼
            IconButton(
              onPressed: _openTableOfContents,
              icon: const Icon(Icons.menu_book),
              style: IconButton.styleFrom(
                backgroundColor: DSColors.surface,
              ),
            ),
            const SizedBox(width: 12),
            // 다음 버튼
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _currentChapterIndex < _chapters.length - 1
                    ? () => setState(() => _currentChapterIndex++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('다음'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DSColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
