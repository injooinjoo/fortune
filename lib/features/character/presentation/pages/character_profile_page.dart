import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../shared/widgets/smart_image.dart';
import '../../data/services/character_localizer.dart';
import '../../domain/models/ai_character.dart';
import '../../data/default_characters.dart';
import '../../data/fortune_characters.dart';
import '../providers/character_chat_provider.dart';
import '../providers/character_provider.dart';

/// 모든 캐릭터 목록 (스토리 + 운세)
final _allCharacters = [...defaultCharacters, ...fortuneCharacters];

/// 인스타그램 스타일 캐릭터 프로필 페이지
class CharacterProfilePage extends ConsumerStatefulWidget {
  final String characterId;
  final AiCharacter? character;

  const CharacterProfilePage({
    super.key,
    required this.characterId,
    this.character,
  });

  @override
  ConsumerState<CharacterProfilePage> createState() =>
      _CharacterProfilePageState();
}

class _CharacterProfilePageState extends ConsumerState<CharacterProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AiCharacter _character;
  bool _didHandleOpenChatRoute = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // extra로 전달받은 캐릭터 또는 ID로 찾기 (스토리 + 운세 캐릭터 모두 검색)
    _character = widget.character ??
        _allCharacters.firstWhere(
          (c) => c.id == widget.characterId,
          orElse: () => _allCharacters.first,
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _handleOpenChatRoute();
    });
  }

  void _handleOpenChatRoute() {
    if (_didHandleOpenChatRoute) return;

    final uri = GoRouterState.of(context).uri;
    final shouldOpenChat = uri.queryParameters['openCharacterChat'] == 'true';
    if (!shouldOpenChat) return;

    _didHandleOpenChatRoute = true;
    final encodedCharacterId = Uri.encodeComponent(_character.id);
    context.go('/chat?openCharacterChat=true&characterId=$encodedCharacterId');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? DSColors.backgroundDark : DSColors.backgroundDark;
    final chatState = ref.watch(characterChatProvider(_character.id));
    final affinity = chatState.affinity;
    final messageCount = chatState.messages.length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          CharacterLocalizer.getName(context, _character.id),
          style: context.heading4.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // 인스타그램 스타일 프로필 헤더
                    _buildProfileHeader(context, messageCount, affinity),
                    const SizedBox(height: 16),
                    // 이름
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CharacterLocalizer.getName(context, _character.id),
                        style: context.heading4
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 태그
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children:
                            CharacterLocalizer.getTags(context, _character.id)
                                .take(5)
                                .map((tag) {
                          return Text(
                            '#$tag',
                            style: context.bodySmall.copyWith(
                              color: _character.accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 짧은 설명
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CharacterLocalizer.getShortDescription(
                            context, _character.id),
                        style: context.bodyMedium.copyWith(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 메시지 보내기 버튼
                    _buildMessageButton(context),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // 탭바
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: _character.accentColor,
                  labelColor: _character.accentColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on)),
                    Tab(icon: Icon(Icons.info_outline)),
                  ],
                ),
                bgColor,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // 사진 그리드 탭
            _buildPhotoGrid(context),
            // 정보 탭
            _buildInfoTab(context),
          ],
        ),
      ),
    );
  }

  /// 프로필 헤더 (아바타 + 통계)
  Widget _buildProfileHeader(
      BuildContext context, int messageCount, dynamic affinity) {
    return Row(
      children: [
        // 큰 아바타
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _character.accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: _character.avatarAsset.isNotEmpty
              ? CircleAvatar(
                  radius: 44,
                  backgroundColor: _character.accentColor,
                  child: ClipOval(
                    child: SmartImage(
                      path: _character.avatarAsset,
                      width: 88,
                      height: 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: 44,
                  backgroundColor: _character.accentColor,
                  child: Text(
                    _character.initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 24),
        // 통계
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatColumn(
                context,
                count: '$messageCount',
                label: context.l10n.conversation,
              ),
              _buildStatColumn(
                context,
                count: '${affinity.lovePercent}%',
                label: context.l10n.affinity,
              ),
              _buildStatColumn(
                context,
                count: CharacterLocalizer.getAffinityPhaseName(
                    context, affinity.phase),
                label: context.l10n.relationship,
                isText: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 통계 컬럼
  Widget _buildStatColumn(
    BuildContext context, {
    required String count,
    required String label,
    bool isText = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: (isText ? context.bodySmall : context.heading4).copyWith(
            fontWeight: FontWeight.bold,
            color: _character.accentColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.labelMedium.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 메시지 보내기 버튼
  Widget _buildMessageButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          // 캐릭터 선택 provider 설정 → SwipeHomeShell이 감지하여 채팅 패널 열기
          ref.read(selectedCharacterProvider.notifier).state = _character;
          ref.read(chatModeProvider.notifier).state = ChatMode.character;
          // 프로필 페이지 닫기
          Navigator.of(context).pop();
        },
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: Text(context.l10n.sendMessage),
        style: ElevatedButton.styleFrom(
          backgroundColor: _character.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /// 사진 그리드
  Widget _buildPhotoGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // galleryAssets가 비어있으면 placeholder 표시
    if (_character.galleryAssets.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(2),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: 9, // placeholder 9개
        itemBuilder: (context, index) {
          return Container(
            color: isDark
                ? _character.accentColor.withValues(alpha: 0.2)
                : _character.accentColor.withValues(alpha: 0.1),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.image_outlined,
                    color: _character.accentColor.withValues(alpha: 0.5),
                    size: 32,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${index + 1}',
                    style: context.labelSmall.copyWith(
                      color: _character.accentColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // 실제 이미지 표시
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _character.galleryAssets.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showImageDetail(context, index),
          child: SmartImage(
            path: _character.galleryAssets[index],
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  /// 정보 탭 (세계관, 성격 등)
  Widget _buildInfoTab(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sectionBgColor = isDark ? DSColors.surfaceDark : Colors.grey[100];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 세계관
        _buildSection(
          context: context,
          icon: Icons.auto_stories,
          title: context.l10n.worldview,
          content:
              CharacterLocalizer.getWorldview(context, _character.id).trim(),
          bgColor: sectionBgColor!,
        ),
        const SizedBox(height: 12),
        // 성격
        _buildSection(
          context: context,
          icon: Icons.person,
          title: context.l10n.characterLabel,
          content:
              CharacterLocalizer.getPersonality(context, _character.id).trim(),
          bgColor: sectionBgColor,
        ),
        // NPC 프로필
        if (_character.npcProfiles != null &&
            _character.npcProfiles!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildNpcSection(context, sectionBgColor),
        ],
        const SizedBox(height: 16),
        // 제작자 코멘트
        Center(
          child: Text(
            '"${CharacterLocalizer.getCreatorComment(context, _character.id)}"',
            style: context.bodySmall.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required Color bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: _character.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _character.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: context.bodyMedium.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildNpcSection(BuildContext context, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                size: 20,
                color: _character.accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.characterList,
                style: context.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _character.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_character.npcProfiles?.entries ?? []).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: _character.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${entry.key}: ',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(text: entry.value),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showImageDetail(BuildContext context, int index) {
    HapticFeedback.lightImpact();
    // TODO: 이미지 상세 보기 구현
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: SmartImage(
              path: _character.galleryAssets[index],
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text(context.l10n.resetConversation),
              onTap: () {
                Navigator.pop(ctx);
                _showResetConfirmDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(context.l10n.shareProfile),
              onTap: () {
                Navigator.pop(ctx);
                // TODO: 공유 기능
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.resetConversation),
        content: Text(
          context.l10n.resetConversationConfirm(
              CharacterLocalizer.getName(context, _character.id)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(characterChatProvider(_character.id).notifier)
                  .clearConversation();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.conversationResetSuccess(
                      CharacterLocalizer.getName(context, _character.id))),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.reset),
          ),
        ],
      ),
    );
  }
}

/// 탭바를 고정하기 위한 Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bgColor;

  _SliverTabBarDelegate(this.tabBar, this.bgColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: bgColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || bgColor != oldDelegate.bgColor;
  }
}
