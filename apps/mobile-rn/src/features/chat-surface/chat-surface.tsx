import { useState, useEffect, useRef, useCallback, type PropsWithChildren, type ReactNode } from 'react';

import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { ActivityIndicator, Animated, Easing, Image, PanResponder, Pressable, TextInput, View } from 'react-native';

import type { VoiceInputState } from '../../lib/use-voice-input';

import type { FortuneTypeId } from '@fortune/product-contracts';

import { AppleAuthButton } from '../../components/apple-auth-button';
import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { Chip } from '../../components/chip';
import { InlineCalendar } from '../../components/inline-calendar';
import { PrimaryButton } from '../../components/primary-button';
import { SurveyComposer } from '../../components/survey-composer';
import { SocialAuthPillButton } from '../../components/social-auth-pill-button';
import {
  isFortuneChatCharacter,
  type ChatCharacterSpec,
  type ChatCharacterTab,
} from '../../lib/chat-characters';
import type {
  ChatShellAction,
  ChatShellMessage,
  ChatShellTextMessage,
} from '../../lib/chat-shell';
import { buildSuggestedActions, formatFortuneTypeLabel } from '../../lib/chat-shell';
import { resolveChatCharacterAvatarSource } from '../../lib/chat-character-avatar';
import { confirmAction } from '../../lib/haptics';
import { fortuneTheme, romanceTintBackground } from '../../lib/theme';

import { MessageReportSheet } from './message-report-sheet';
import { EmbeddedResultCard } from '../chat-results/embedded-result-card';
import { FadeUpWords, StoryRevealMessage } from '../story-chat-animations';
import { FortuneCookieCard } from '../fortune-cookie/fortune-cookie-card';
import { SajuPreviewCard } from '../fortune-cookie/saju-preview-card';
import { MySajuContextCard } from './my-saju-context-card';
import type { ChatSurveyStep } from '../chat-survey/types';
import { TarotDrawWidget } from '../chat-survey/tarot-draw-widget';

function formatChatHeaderTimestamp(date: Date): string {
  const hour = date.getHours();
  const minute = date.getMinutes();
  const isAfternoon = hour >= 12;
  const displayHour = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour;
  const paddedMinute = minute.toString().padStart(2, '0');
  return `${isAfternoon ? '오후' : '오전'} ${displayHour}:${paddedMinute}`;
}

function CharacterAvatar({
  characterId,
  name,
  size = 48,
}: {
  characterId: string;
  name: string;
  size?: number;
}) {
  const avatarSource = resolveChatCharacterAvatarSource(characterId);

  return (
    <View
      style={{
        alignItems: 'center',
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: fortuneTheme.colors.border,
        borderRadius: size / 2,
        borderWidth: 1,
        height: size,
        justifyContent: 'center',
        overflow: 'hidden',
        width: size,
      }}
    >
      {avatarSource ? (
        <Image
          source={avatarSource}
          style={{
            height: size,
            width: size,
          }}
        />
      ) : (
        <AppText variant={size >= 56 ? 'heading3' : 'labelLarge'}>
          {name.slice(0, 1)}
        </AppText>
      )}
    </View>
  );
}

function HeaderActionButton({
  kind,
  label,
  onPress,
}: {
  kind: 'plus' | 'profile';
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      onPress={onPress}
      // Apple HIG 최소 44pt 터치 타겟. 시각 크기는 36×36 유지하고 hitSlop 4
      // 으로 실 터치 영역을 44×44 로 확장. (W11 audit finding)
      hitSlop={{ top: 4, bottom: 4, left: 4, right: 4 }}
      style={({ pressed }) => ({
        alignItems: 'center',
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: fortuneTheme.colors.border,
        borderRadius: 999,
        borderWidth: 1,
        height: 36,
        justifyContent: 'center',
        opacity: pressed ? 0.84 : 1,
        width: 36,
      })}
    >
      {kind === 'plus' ? (
        <View
          style={{
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <View
            style={{
              backgroundColor: fortuneTheme.colors.textPrimary,
              borderRadius: 999,
              height: 2,
              position: 'absolute',
              width: 12,
            }}
          />
          <View
            style={{
              backgroundColor: fortuneTheme.colors.textPrimary,
              borderRadius: 999,
              height: 12,
              width: 2,
            }}
          />
        </View>
      ) : (
        <View
          style={{
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <View
            style={{
              borderColor: fortuneTheme.colors.textPrimary,
              borderRadius: 999,
              borderWidth: 1.5,
              height: 10,
              marginBottom: 1,
              width: 10,
            }}
          />
          <View
            style={{
              borderColor: fortuneTheme.colors.textPrimary,
              borderRadius: 999,
              borderWidth: 1.5,
              borderTopWidth: 1.5,
              height: 6,
              marginTop: 1,
              width: 16,
            }}
          />
        </View>
      )}
    </Pressable>
  );
}

export function FloatingCreateButton({
  label,
  onPress,
}: {
  label: string;
  onPress: () => void;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={label}
      onPress={onPress}
      style={({ pressed }) => ({
        opacity: pressed ? 0.84 : 1,
      })}
    >
      <View
        style={{
          alignItems: 'center',
          alignSelf: 'flex-end',
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          borderColor: 'transparent',
          borderRadius: 999,
          borderWidth: 1,
          height: 56,
          justifyContent: 'center',
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 10 },
          shadowOpacity: 0.22,
          shadowRadius: 18,
          width: 56,
        }}
      >
        <View
          style={{
            backgroundColor: fortuneTheme.colors.textPrimary,
            borderRadius: 999,
            height: 2.5,
            position: 'absolute',
            width: 16,
          }}
        />
        <View
          style={{
            backgroundColor: fortuneTheme.colors.textPrimary,
            borderRadius: 999,
            height: 16,
            width: 2.5,
          }}
        />
      </View>
    </Pressable>
  );
}

function SegmentedPills({
  activeTab,
  onChangeTab,
}: {
  activeTab: ChatCharacterTab;
  onChangeTab: (tab: ChatCharacterTab) => void;
}) {
  return (
    <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
      <Pressable
        accessibilityRole="button"
        onPress={() => onChangeTab('story')}
        style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
      >
        <Chip label="스토리" tone={activeTab === 'story' ? 'accent' : 'neutral'} />
      </Pressable>
      {/* TODO: 호기심 탭 임시 비활성화
      <Pressable
        accessibilityRole="button"
        onPress={() => onChangeTab('fortune')}
        style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
      >
        <Chip
          label="호기심"
          tone={activeTab === 'fortune' ? 'accent' : 'neutral'}
        />
      </Pressable>
      */}
    </View>
  );
}

function EntryActionRow({
  title,
  subtitle,
  badge,
  onPress,
  tone = 'neutral',
  selected = false,
}: {
  title: string;
  subtitle: string;
  badge?: string;
  onPress: () => void;
  tone?: 'neutral' | 'accent' | 'success';
  selected?: boolean;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
    >
      <View
        style={{
          alignItems: 'center',
          backgroundColor: selected
            ? fortuneTheme.colors.backgroundTertiary
            : fortuneTheme.colors.surfaceSecondary,
          borderColor: selected
            ? fortuneTheme.colors.accentTertiary
            : fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.lg,
          borderWidth: 1,
          flexDirection: 'row',
          gap: fortuneTheme.spacing.sm,
          justifyContent: 'space-between',
          paddingHorizontal: 14,
          paddingVertical: 13,
        }}
      >
        <View style={{ flex: 1, gap: 2 }}>
          <AppText variant="labelLarge">{title}</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {subtitle}
          </AppText>
        </View>
        {badge ? <Chip label={badge} tone={tone} /> : null}
      </View>
    </Pressable>
  );
}

export interface CharacterListRowMeta {
  lastMessagePreview: string | null;
  /** 안 읽은 assistant/system 메시지 개수. 0 이면 닷/배지 모두 표시 안함. */
  unreadCount: number;
  /** 편의 플래그 — `unreadCount > 0`. 기존 소비자 호환용. */
  unread: boolean;
}

function extractMessagePreview(message: ChatShellMessage): string {
  switch (message.kind) {
    case 'text':
      return message.text.replace(/\s+/g, ' ').trim();
    case 'image':
      return message.caption?.trim() ? `📷 ${message.caption}` : '📷 사진';
    case 'embedded-result':
      return `📌 ${message.title ?? '결과 카드'}`;
    case 'fortune-cookie':
      return '🥠 포춘쿠키';
    case 'saju-preview':
      return '📜 사주 요약';
    case 'story-reveal':
      return '✨ 새 장면';
    default:
      return '';
  }
}

export function buildCharacterListMeta(
  messages: readonly ChatShellMessage[] | undefined,
  lastSeenMessageId: string | undefined,
): CharacterListRowMeta {
  if (!messages || messages.length === 0) {
    return { lastMessagePreview: null, unreadCount: 0, unread: false };
  }
  const last = messages[messages.length - 1];
  const preview = extractMessagePreview(last);

  // Unread 판정 (일반 메신저 표준):
  //   "lastSeen 이후로 도착한 assistant/system 메시지 개수" 를 센다. 0 이면
  //   읽음 상태. 배지에 카운트를 띄우려고 boolean 대신 count 를 보관.
  // 과거 구현은 "마지막 메시지가 assistant 인지"만 봐서, AI 가 여러 번 연속
  // 보내고 유저가 짧게 답하면 마지막이 user → 안 읽힌 AI 메시지가 있어도
  // 닷이 사라지는 버그가 있었다.
  const lastSeenIndex = lastSeenMessageId
    ? messages.findIndex((m) => m.id === lastSeenMessageId)
    : -1;
  let unreadCount = 0;
  for (let i = lastSeenIndex + 1; i < messages.length; i += 1) {
    const m = messages[i];
    if (m.sender === 'assistant' || m.sender === 'system') {
      unreadCount += 1;
    }
  }
  return {
    lastMessagePreview: preview.length > 0 ? preview : null,
    unreadCount,
    unread: unreadCount > 0,
  };
}

function CharacterListRow({
  character,
  badge,
  onPress,
  onDelete,
  onPickAction,
  optionActions = [],
  selected = false,
  romanceScore = 0,
  meta,
}: {
  character: ChatCharacterSpec;
  badge?: string;
  onPress: () => void;
  onDelete?: () => void;
  onPickAction?: (fortuneType: FortuneTypeId) => void;
  optionActions?: readonly ChatShellAction[];
  selected?: boolean;
  romanceScore?: number;
  meta?: CharacterListRowMeta;
}) {
  const swipeX = useRef(new Animated.Value(0)).current;
  const DELETE_WIDTH = 80;
  const DELETE_THRESHOLD = -50;

  const panResponder = useRef(
    onDelete
      ? PanResponder.create({
          onMoveShouldSetPanResponder: (_, gesture) =>
            Math.abs(gesture.dx) > 10 && Math.abs(gesture.dy) < 20,
          onPanResponderMove: (_, gesture) => {
            if (gesture.dx < 0) {
              swipeX.setValue(Math.max(gesture.dx, -DELETE_WIDTH));
            }
          },
          onPanResponderRelease: (_, gesture) => {
            if (gesture.dx < DELETE_THRESHOLD) {
              Animated.spring(swipeX, { toValue: -DELETE_WIDTH, useNativeDriver: true }).start();
            } else {
              Animated.spring(swipeX, { toValue: 0, useNativeDriver: true }).start();
            }
          },
        })
      : null,
  ).current;

  const tintBg = romanceScore > 5 ? romanceTintBackground(romanceScore) : fortuneTheme.colors.background;

  const cardContent = (
    <Pressable
      accessibilityRole="button"
      onPress={() => { confirmAction(); onPress(); }}
      style={({ pressed }) => ({
        backgroundColor: tintBg,
        borderBottomColor: fortuneTheme.colors.border,
        borderBottomWidth: 1,
        flexDirection: 'row',
        alignItems: 'center',
        gap: fortuneTheme.spacing.md,
        opacity: pressed ? 0.6 : 1,
        paddingHorizontal: 20,
        paddingVertical: 16,
      })}
    >
      <View>
        <CharacterAvatar characterId={character.id} name={character.name} size={60} />
        {meta && meta.unreadCount > 0 ? (
          <View
            style={{
              position: 'absolute',
              top: -2,
              right: -4,
              minWidth: 18,
              height: 18,
              paddingHorizontal: 5,
              borderRadius: 9,
              backgroundColor: '#FF3B30',
              borderWidth: 2,
              borderColor: fortuneTheme.colors.background,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <AppText
              variant="caption"
              color="#FFFFFF"
              style={{ fontSize: 10, lineHeight: 12, fontWeight: '700' }}
            >
              {meta.unreadCount > 99 ? '99+' : String(meta.unreadCount)}
            </AppText>
          </View>
        ) : null}
      </View>
      <View style={{ flex: 1, gap: 4 }}>
        <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
          <AppText variant="labelLarge" style={{ flex: 1 }}>{character.name}</AppText>
          {badge ? (
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              {badge}
            </AppText>
          ) : null}
        </View>
        <AppText
          numberOfLines={1}
          variant="bodySmall"
          color={
            meta?.unread
              ? fortuneTheme.colors.textPrimary
              : fortuneTheme.colors.textSecondary
          }
          style={meta?.unread ? { fontWeight: '600' } : undefined}
        >
          {meta?.lastMessagePreview ?? character.shortDescription}
        </AppText>
      </View>
    </Pressable>
  );

  if (!onDelete) {
    return cardContent;
  }

  return (
    <View style={{ overflow: 'hidden' }}>
      {/* Delete button behind */}
      <Pressable
        onPress={() => {
          Animated.spring(swipeX, { toValue: 0, useNativeDriver: true }).start();
          onDelete();
        }}
        style={{
          position: 'absolute',
          right: 0,
          top: 0,
          bottom: 0,
          width: DELETE_WIDTH,
          backgroundColor: '#FF3B30',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 6,
        }}
      >
        <Ionicons name="trash" size={24} color="#FFFFFF" />
        <AppText variant="labelSmall" color="#FFFFFF">
          삭제
        </AppText>
      </Pressable>
      {/* Swipeable row */}
      <Animated.View
        style={{
          backgroundColor: tintBg,
          transform: [{ translateX: swipeX }],
        }}
        {...(panResponder?.panHandlers ?? {})}
      >
        {cardContent}
      </Animated.View>
    </View>
  );
}

function MessageBubble({
  message,
  useOracleVoice,
}: {
  message: ChatShellTextMessage;
  /**
   * When true, assistant messages render in ZEN Serif to match the Ondo
   * oracle-voice rule. Reserved for fortune-teller characters (saju,
   * tarot, etc.) — story characters keep sans for everyday chat.
   */
  useOracleVoice?: boolean;
}) {
  // ondo design system (Ondo Design System/project/story_chat/story-chat-player.jsx):
  //   - AIBlock: 말풍선 없음. 본문 그대로. maxWidth 86%, fontSize 15, lineHeight 1.7, color ST.fg
  //   - UserBubble: background ST.borderOpaque(#2C2C2E), borderRadius 20,
  //                 borderBottomRightRadius 6, padding 11/15, fontSize 15, lineHeight 1.5
  //   - SysNote: 중앙 정렬 small 텍스트, color ST.fg3, ✦ 마커 (color prop)
  const isAssistant = message.sender === 'assistant';
  const isSystem = message.sender === 'system';
  const isUser = message.sender === 'user';
  const applyOracle = Boolean(useOracleVoice) && isAssistant;
  const showUnreadBadge = isUser && !message.readAt;

  // 새로 도착한 어시스턴트 메시지만 단어 단위 fadeUp 애니메이션.
  const shouldAnimate = isAssistant && message.animate === true;

  if (isSystem) {
    return (
      <View
        style={{
          flexDirection: 'row',
          alignItems: 'center',
          justifyContent: 'center',
          gap: 6,
          marginVertical: 4,
        }}
      >
        <AppText
          variant="labelSmall"
          color={fortuneTheme.colors.accentTertiary}
        >
          ✦
        </AppText>
        <AppText variant="labelSmall" color={fortuneTheme.colors.textTertiary}>
          {message.text}
        </AppText>
      </View>
    );
  }

  if (isAssistant) {
    // ondo AIBlock — 말풍선 없음
    const textColor = fortuneTheme.colors.textPrimary;
    return (
      <View style={{ maxWidth: '86%', alignSelf: 'flex-start' }}>
        {shouldAnimate ? (
          <FadeUpWords
            text={message.text}
            variant={applyOracle ? 'oracleBody' : 'bodyMedium'}
            color={textColor}
          />
        ) : (
          <AppText
            variant={applyOracle ? 'oracleBody' : 'bodyMedium'}
            color={textColor}
            style={{ lineHeight: 25.5 }}
          >
            {message.text}
          </AppText>
        )}
      </View>
    );
  }

  // UserBubble — AIBlock 과 동일 패턴: 자기 자신이 alignSelf + maxWidth 로
  // 위치/너비 관리. 부모에 위임하지 않음 (부모 위임 시 Yoga 가 중첩 flex
  // 경로에서 text intrinsic width 를 과소 계산해 짧은 한글이 중간에서 잘림).
  return (
    <View
      style={{
        alignSelf: 'flex-end',
        maxWidth: '94%',
        flexDirection: 'row',
        alignItems: 'flex-end',
        gap: 4,
      }}
    >
      {showUnreadBadge ? (
        <AppText
          variant="caption"
          color={fortuneTheme.colors.warning}
          style={{ marginBottom: 2 }}
        >
          1
        </AppText>
      ) : null}
      <View
        style={{
          backgroundColor: '#2C2C2E',
          borderRadius: 20,
          borderBottomRightRadius: 6,
          paddingHorizontal: 15,
          paddingVertical: 11,
          flexShrink: 1,
        }}
      >
        <AppText
          variant="bodyMedium"
          color={fortuneTheme.colors.textPrimary}
          style={{ lineHeight: 22.5 }}
        >
          {message.text}
        </AppText>
      </View>
    </View>
  );
}

function TypingIndicatorBubble({
  queuedCount = 0,
}: {
  character: ChatCharacterSpec;
  queuedCount?: number;
}) {
  // ondo story-chat-player `Typing` 원본: 말풍선 없음. 3점만.
  //   padding: '6px 0', gap 4, dots 7×7, background ST.fg2
  return (
    <View
      style={{
        flexDirection: 'row',
        alignItems: 'center',
        gap: 8,
        paddingVertical: 6,
        alignSelf: 'flex-start',
      }}
    >
      <View style={{ flexDirection: 'row', alignItems: 'center', gap: 4 }}>
        <WaveDot delay={0} />
        <WaveDot delay={150} />
        <WaveDot delay={300} />
      </View>
      {queuedCount > 0 ? (
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
          대기 +{queuedCount}
        </AppText>
      ) : null}
    </View>
  );
}

/**
 * ondo-design-system story-chat-player `Typing` 포트.
 *   @keyframes typing {
 *     0%, 60%, 100% { opacity: 0.3; transform: translateY(0); }
 *     30%           { opacity: 1;   transform: translateY(-3px); }
 *   }
 *   animation: `typing 1.2s infinite ${i * 0.15}s`
 */
function WaveDot({ delay }: { delay: number }) {
  const translate = useRef(new Animated.Value(0)).current;
  const opacity = useRef(new Animated.Value(0.3)).current;

  useEffect(() => {
    // 1200ms 사이클: 0%→30% 상승(360ms), 30%→60% 하강(360ms), 60%→100% 정지(480ms)
    const animation = Animated.loop(
      Animated.sequence([
        Animated.delay(delay),
        Animated.parallel([
          Animated.timing(translate, {
            toValue: -3,
            duration: 360,
            useNativeDriver: true,
          }),
          Animated.timing(opacity, {
            toValue: 1,
            duration: 360,
            useNativeDriver: true,
          }),
        ]),
        Animated.parallel([
          Animated.timing(translate, {
            toValue: 0,
            duration: 360,
            useNativeDriver: true,
          }),
          Animated.timing(opacity, {
            toValue: 0.3,
            duration: 360,
            useNativeDriver: true,
          }),
        ]),
        Animated.delay(480),
      ]),
    );
    animation.start();
    return () => animation.stop();
  }, [delay, opacity, translate]);

  return (
    <Animated.View
      style={{
        width: 7,
        height: 7,
        borderRadius: 999,
        backgroundColor: fortuneTheme.colors.textSecondary,
        transform: [{ translateY: translate }],
        opacity,
      }}
    />
  );
}

function EmbeddedResultMessage({
  message,
}: {
  message: Extract<ChatShellMessage, { kind: 'embedded-result' }>;
}) {
  return (
    <View style={{ width: '100%' }}>
      <EmbeddedResultCard message={message} />
    </View>
  );
}

function ChatThreadMessage({
  character,
  message,
}: {
  character: ChatCharacterSpec;
  message: ChatShellMessage;
}) {
  const isUser = message.sender === 'user';
  const isFullWidth =
    message.kind === 'embedded-result' ||
    message.kind === 'fortune-cookie' ||
    message.kind === 'saju-preview' ||
    message.kind === 'story-reveal' ||
    message.kind === 'my-saju-context';
  const isImage = message.kind === 'image';

  // Apple 5.2.3 — assistant 텍스트 메시지 long-press로 신고 시트 오픈.
  // text 이외 타입(결과 카드/서베이/사주 프리뷰 등)은 시스템-생성 혹은 위젯이라
  // 신고 대상이 아님. 사용자 본인의 발화도 신고 불필요.
  const reportable =
    message.kind === 'text' &&
    message.sender === 'assistant' &&
    message.text?.trim().length > 0;
  const [reportOpen, setReportOpen] = useState(false);

  const bubble = (() => {
    if (message.kind === 'embedded-result')
      return <EmbeddedResultMessage message={message} />;
    if (message.kind === 'story-reveal')
      return <StoryRevealMessage message={message} characterId={character.id} />;
    if (message.kind === 'fortune-cookie')
      return (
        <View style={{ width: '100%' }}>
          <FortuneCookieCard />
        </View>
      );
    if (message.kind === 'saju-preview')
      return (
        <View style={{ width: '100%' }}>
          <SajuPreviewCard
            data={message.sajuData as import('../../lib/saju-remote').SajuData}
            userName={message.userName}
          />
        </View>
      );
    if (message.kind === 'my-saju-context')
      return (
        <View style={{ width: '100%' }}>
          <MySajuContextCard message={message} />
        </View>
      );
    if (isImage)
      return (
        <View style={{ gap: 4 }}>
          <Image
            source={{ uri: message.imageUrl }}
            style={{
              width: 200,
              height: 200,
              borderRadius: fortuneTheme.radius.card,
            }}
            resizeMode="cover"
          />
          {message.caption ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {message.caption}
            </AppText>
          ) : null}
        </View>
      );
    return (
      <MessageBubble
        message={message}
        useOracleVoice={isFortuneChatCharacter(character)}
      />
    );
  })();

  return (
    <View style={{ width: '100%' }}>
      <View style={{ width: isFullWidth ? '100%' : undefined }}>
        {reportable ? (
          <Pressable
            onLongPress={() => setReportOpen(true)}
            // delayLongPress 기본 500ms — 스크롤 오작동 최소화
            android_ripple={null}
            accessibilityRole="button"
            accessibilityLabel="메시지 길게 눌러 신고"
          >
            {bubble}
          </Pressable>
        ) : (
          bubble
        )}
      </View>

      {reportable ? (
        <MessageReportSheet
          visible={reportOpen}
          characterId={character.id}
          messageText={(message as ChatShellTextMessage).text}
          messageId={(message as { id?: string }).id ?? null}
          onClose={() => setReportOpen(false)}
        />
      ) : null}
    </View>
  );
}

export function ChatSoftGate({
  onApple,
  onGoogle,
  onBrowse,
  authMessage,
  onKakao,
  onNaver,
  onEmail,
  onPhone,
}: {
  onApple: () => void;
  onGoogle: () => void;
  onBrowse: () => void;
  authMessage?: string | null;
  onKakao?: () => void;
  onNaver?: () => void;
  onEmail?: () => void;
  onPhone?: () => void;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.lg }}>
      <View
        style={{
          borderRadius: 32,
          minHeight: 520,
          overflow: 'hidden',
          paddingTop: fortuneTheme.spacing.xl,
        }}
      >
        <View
          style={{
            borderColor: fortuneTheme.colors.border,
            borderRadius: 220,
            borderWidth: 1,
            height: 320,
            left: -170,
            opacity: 0.45,
            position: 'absolute',
            top: -20,
            width: 320,
          }}
        />
        <View
          style={{
            borderColor: fortuneTheme.colors.border,
            borderRadius: 260,
            borderWidth: 1,
            height: 360,
            opacity: 0.3,
            position: 'absolute',
            right: -150,
            top: -70,
            width: 360,
          }}
        />

        <View style={{ gap: fortuneTheme.spacing.sm, paddingHorizontal: 4 }}>
          <AppText variant="displayLarge" style={{ maxWidth: 280 }}>
            기록과 개인화를{'\n'}계속 이어가세요
          </AppText>
          <AppText
            variant="bodyLarge"
            color={fortuneTheme.colors.textSecondary}
            style={{ maxWidth: 290 }}
          >
            로그인하면 분석 기록, 맞춤 추천, 구매 내역이 계정에 안전하게
            연결됩니다. 지금 둘러본 뒤 필요할 때 바로 이어서 시작할 수 있어요.
          </AppText>
        </View>

        <Card
          style={{
            marginTop: 96,
            paddingBottom: fortuneTheme.spacing.lg,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
            계정을 연결하고 시작
          </AppText>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            <AppleAuthButton label="애플 로그인" onPress={onApple} />
            <SocialAuthPillButton
              label="구글 로그인"
              onPress={onGoogle}
              provider="google"
            />
            {onKakao ? (
              <SocialAuthPillButton
                label="카카오 로그인"
                onPress={onKakao}
                provider="kakao"
              />
            ) : null}
            {onNaver ? (
              <SocialAuthPillButton
                label="네이버 로그인"
                onPress={onNaver}
                provider="naver"
              />
            ) : null}
          </View>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            계속하면 이용약관과 개인정보처리방침에 동의하게 됩니다.
          </AppText>
          {authMessage ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {authMessage}
            </AppText>
          ) : null}

          {onEmail || onPhone ? (
            <>
              <View
                style={{
                  alignItems: 'center',
                  flexDirection: 'row',
                  gap: 12,
                  paddingVertical: 4,
                }}
              >
                <View style={{ flex: 1, height: 1, backgroundColor: fortuneTheme.colors.divider }} />
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  또는
                </AppText>
                <View style={{ flex: 1, height: 1, backgroundColor: fortuneTheme.colors.divider }} />
              </View>
              {onEmail ? (
                <Pressable
                  accessibilityLabel="이메일로 시작"
                  accessibilityRole="button"
                  onPress={onEmail}
                  style={({ pressed }) => ({
                    alignItems: 'center',
                    backgroundColor: '#FFFFFF',
                    borderRadius: fortuneTheme.radius.full,
                    flexDirection: 'row',
                    justifyContent: 'center',
                    minHeight: 52,
                    opacity: pressed ? 0.84 : 1,
                    paddingHorizontal: 16,
                    width: '100%',
                  })}
                >
                  <View style={{ alignItems: 'center', flexDirection: 'row', width: '100%' }}>
                    <View style={{ alignItems: 'center', justifyContent: 'center', width: 24 }}>
                      <Ionicons color="#111111" name="mail-outline" size={18} />
                    </View>
                    <View style={{ flex: 1 }}>
                      <AppText variant="labelLarge" color="#111111" style={{ fontWeight: '700', textAlign: 'center' }}>
                        이메일로 시작
                      </AppText>
                    </View>
                    <View style={{ width: 24 }} />
                  </View>
                </Pressable>
              ) : null}
              {onPhone ? (
                <Pressable
                  accessibilityLabel="전화번호로 시작"
                  accessibilityRole="button"
                  onPress={onPhone}
                  style={({ pressed }) => ({
                    alignItems: 'center',
                    backgroundColor: '#FFFFFF',
                    borderRadius: fortuneTheme.radius.full,
                    flexDirection: 'row',
                    justifyContent: 'center',
                    minHeight: 52,
                    opacity: pressed ? 0.84 : 1,
                    paddingHorizontal: 16,
                    width: '100%',
                  })}
                >
                  <View style={{ alignItems: 'center', flexDirection: 'row', width: '100%' }}>
                    <View style={{ alignItems: 'center', justifyContent: 'center', width: 24 }}>
                      <Ionicons color="#111111" name="call-outline" size={18} />
                    </View>
                    <View style={{ flex: 1 }}>
                      <AppText variant="labelLarge" color="#111111" style={{ fontWeight: '700', textAlign: 'center' }}>
                        전화번호로 시작
                      </AppText>
                    </View>
                    <View style={{ width: 24 }} />
                  </View>
                </Pressable>
              ) : null}
            </>
          ) : null}

          <Pressable
            accessibilityRole="button"
            onPress={onBrowse}
            style={({ pressed }) => ({ opacity: pressed ? 0.8 : 1, paddingTop: 4 })}
          >
            <AppText
              variant="labelLarge"
              color={fortuneTheme.colors.textPrimary}
              style={{ textAlign: 'center' }}
            >
              로그인 없이 둘러보기
            </AppText>
          </Pressable>
        </Card>
      </View>
    </View>
  );
}

export function ChatFirstRunSurface({
  activeTab,
  characters,
  lastFortuneType,
  selectedCharacterId,
  onChangeTab,
  onOpenProfile,
  onOpenRecentResult,
  onSelectCharacter,
  onPickCharacterAction,
  onDeleteFriend,
  romanceScores,
  metaByCharacterId,
}: {
  activeTab: ChatCharacterTab;
  characters: readonly ChatCharacterSpec[];
  lastFortuneType: FortuneTypeId | null;
  selectedCharacterId: string | null;
  onChangeTab: (tab: ChatCharacterTab) => void;
  onOpenProfile: () => void;
  onOpenRecentResult: (fortuneType: FortuneTypeId) => void;
  onSelectCharacter: (characterId: string) => void;
  onPickCharacterAction: (characterId: string, fortuneType: FortuneTypeId) => void;
  onDeleteFriend?: (characterId: string) => void;
  romanceScores?: Record<string, number>;
  metaByCharacterId?: Record<string, CharacterListRowMeta>;
}) {
  const safeCharacters = Array.isArray(characters) ? characters : [];
  const orderedCharacters = [
    ...safeCharacters.filter((character) => character.id === selectedCharacterId),
    ...safeCharacters.filter((character) => character.id !== selectedCharacterId),
  ];
  const visibleCharacters = orderedCharacters;

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <View
        style={{
          alignItems: 'flex-start',
          flexDirection: 'row',
          justifyContent: 'space-between',
        }}
      >
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="displaySmall">메시지</AppText>
          <SegmentedPills activeTab={activeTab} onChangeTab={onChangeTab} />
        </View>
        <HeaderActionButton
          kind="profile"
          label="프로필 열기"
          onPress={onOpenProfile}
        />
      </View>

      {activeTab === 'story' ? (
        <View style={{ marginHorizontal: -20 }}>
          {visibleCharacters.map((character) => (
            <CharacterListRow
              key={character.id}
              badge={character.id.startsWith('custom_') ? '내 친구' : '스토리'}
              character={character}
              meta={metaByCharacterId?.[character.id]}
              onDelete={
                character.id.startsWith('custom_') && onDeleteFriend
                  ? () => onDeleteFriend(character.id)
                  : undefined
              }
              onPress={() => onSelectCharacter(character.id)}
              romanceScore={romanceScores?.[character.id] ?? 0}
              selected={character.id === selectedCharacterId}
            />
          ))}
        </View>
      ) : (
        <View style={{ marginHorizontal: -20 }}>
          {lastFortuneType ? (
            <EntryActionRow
              badge="최근 결과"
              onPress={() => onOpenRecentResult(lastFortuneType)}
              subtitle={`${formatFortuneTypeLabel(lastFortuneType)} 결과를 같은 채팅 안에서 다시 엽니다.`}
              title={`${formatFortuneTypeLabel(lastFortuneType)} 이어보기`}
              tone="accent"
            />
          ) : null}
          {visibleCharacters.map((character) => (
            <CharacterListRow
              key={character.id}
              badge={`${character.specialties.length}개 인사이트`}
              character={character}
              meta={metaByCharacterId?.[character.id]}
              onPress={() => onSelectCharacter(character.id)}
              selected={character.id === selectedCharacterId}
            />
          ))}
        </View>
      )}

    </View>
  );
}

export function ActiveChatComposer({
  draft,
  onDraftChange,
  onSend,
  onOpenPhotoPicker,
  onOpenPersonaSettings,
  onToggleVoiceInput,
  voiceInputState = 'idle',
  quickActions,
  trayOpen,
  onToggleTray,
  onPickAction,
  auxiliaryAction,
  sendDisabled = false,
  hasCustomPersona = false,
  pendingImageUri,
  onRemovePendingImage,
}: {
  draft: string;
  onDraftChange: (value: string) => void;
  onSend: () => void;
  onOpenPhotoPicker: () => void;
  onOpenPersonaSettings?: () => void;
  onToggleVoiceInput: () => void;
  voiceInputState?: VoiceInputState;
  quickActions: ChatShellAction[];
  trayOpen: boolean;
  onToggleTray: () => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
  auxiliaryAction?: {
    label: string;
    onPress: () => void;
  };
  sendDisabled?: boolean;
  hasCustomPersona?: boolean;
  pendingImageUri?: string;
  onRemovePendingImage?: () => void;
}) {
  const composerHasDraft = draft.trim().length > 0;
  const hasPendingImage = Boolean(pendingImageUri);
  // 텍스트가 비어도 이미지가 첨부돼 있으면 전송 버튼이 활성화된다.
  const canSend = composerHasDraft || hasPendingImage;
  const safeQuickActions = Array.isArray(quickActions) ? quickActions : [];
  const trayActions = safeQuickActions.slice(0, 12);
  const voiceRecording = voiceInputState === 'recording';
  const voiceTranscribing = voiceInputState === 'transcribing';
  const voiceActive = voiceInputState !== 'idle';

  // Pulse animation for recording indicator
  const micPulseAnim = useRef(new Animated.Value(1)).current;
  useEffect(() => {
    if (voiceRecording) {
      Animated.loop(
        Animated.sequence([
          Animated.timing(micPulseAnim, {
            toValue: 0.5,
            duration: 600,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
          Animated.timing(micPulseAnim, {
            toValue: 1,
            duration: 600,
            easing: Easing.inOut(Easing.ease),
            useNativeDriver: true,
          }),
        ]),
      ).start();
    } else {
      micPulseAnim.stopAnimation();
      micPulseAnim.setValue(1);
    }
  }, [voiceRecording, micPulseAnim]);

  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: voiceRecording
          ? '#EF4444'
          : voiceActive
            ? fortuneTheme.colors.ctaBackground
            : fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.inputArea,
        borderWidth: 1,
        paddingHorizontal: 12,
        paddingVertical: 8,
      }}
    >
      {trayOpen ? (
        <View style={{ gap: 8, paddingBottom: 10 }}>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            사진 보내기 및 바로 이어갈 액션
          </AppText>
          <View
            style={{
              flexDirection: 'row',
              flexWrap: 'wrap',
              gap: 8,
            }}
          >
            <Pressable
              accessibilityLabel="사진 보내기"
              accessibilityRole="button"
              onPress={onOpenPhotoPicker}
              style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
            >
              <View
                style={{
                  alignItems: 'center',
                  backgroundColor: fortuneTheme.colors.backgroundTertiary,
                  borderRadius: 999,
                  flexDirection: 'row',
                  gap: 8,
                  paddingHorizontal: 14,
                  paddingVertical: 8,
                }}
              >
                <Ionicons
                  color={fortuneTheme.colors.textPrimary}
                  name="image-outline"
                  size={16}
                />
                <AppText variant="labelLarge">사진 보내기</AppText>
              </View>
            </Pressable>
            {onOpenPersonaSettings ? (
              <Pressable
                accessibilityLabel="성격 설정"
                accessibilityRole="button"
                onPress={onOpenPersonaSettings}
                style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
              >
                <View
                  style={{
                    alignItems: 'center',
                    backgroundColor: hasCustomPersona
                      ? 'rgba(232, 236, 255, 0.96)'
                      : fortuneTheme.colors.backgroundTertiary,
                    borderRadius: 999,
                    flexDirection: 'row',
                    gap: 8,
                    paddingHorizontal: 14,
                    paddingVertical: 8,
                  }}
                >
                  <Ionicons
                    color={hasCustomPersona ? fortuneTheme.colors.background : fortuneTheme.colors.textPrimary}
                    name="sparkles-outline"
                    size={16}
                  />
                  <AppText
                    variant="labelLarge"
                    color={hasCustomPersona ? fortuneTheme.colors.background : undefined}
                  >
                    성격 설정
                  </AppText>
                </View>
              </Pressable>
            ) : null}
            {trayActions.map((action, actionIndex) => (
              <Pressable
                key={action.id}
                accessibilityRole="button"
                onPress={() => onPickAction(action.fortuneType)}
                style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
              >
                <View
                  style={{
                    backgroundColor:
                      actionIndex % 4 === 0
                        ? 'rgba(232, 236, 255, 0.96)'
                        : actionIndex % 4 === 1
                          ? 'rgba(205, 244, 213, 0.96)'
                          : actionIndex % 4 === 2
                            ? 'rgba(255, 236, 213, 0.96)'
                            : 'rgba(236, 221, 255, 0.96)',
                    borderRadius: 999,
                    paddingHorizontal: 14,
                    paddingVertical: 8,
                  }}
                >
                  <AppText
                    variant="labelLarge"
                    color={fortuneTheme.colors.background}
                  >
                    {action.label}
                  </AppText>
                </View>
              </Pressable>
            ))}
            {!trayActions.length && auxiliaryAction ? (
              <Pressable
                accessibilityRole="button"
                onPress={auxiliaryAction.onPress}
                style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
              >
                <View
                  style={{
                    backgroundColor: fortuneTheme.colors.backgroundTertiary,
                    borderRadius: 999,
                    paddingHorizontal: 14,
                    paddingVertical: 8,
                  }}
                >
                  <AppText variant="labelLarge">{auxiliaryAction.label}</AppText>
                </View>
              </Pressable>
            ) : null}
          </View>
        </View>
      ) : null}
      {hasPendingImage && pendingImageUri ? (
        <View
          style={{
            paddingBottom: 8,
            flexDirection: 'row',
            alignItems: 'flex-start',
          }}
        >
          <View
            style={{
              position: 'relative',
            }}
          >
            <Image
              source={{ uri: pendingImageUri }}
              style={{
                width: 72,
                height: 72,
                borderRadius: 12,
                backgroundColor: fortuneTheme.colors.surfaceElevated,
              }}
            />
            <Pressable
              accessibilityLabel="첨부 사진 취소"
              accessibilityRole="button"
              onPress={onRemovePendingImage}
              hitSlop={8}
              style={({ pressed }) => ({
                position: 'absolute',
                top: -6,
                right: -6,
                width: 22,
                height: 22,
                borderRadius: 11,
                backgroundColor: 'rgba(20, 20, 26, 0.92)',
                borderWidth: 1,
                borderColor: fortuneTheme.colors.border,
                alignItems: 'center',
                justifyContent: 'center',
                opacity: pressed ? 0.7 : 1,
              })}
            >
              <Ionicons
                color={fortuneTheme.colors.textPrimary}
                name="close"
                size={14}
              />
            </Pressable>
          </View>
        </View>
      ) : null}
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <Pressable
          accessibilityLabel="composer plus actions"
          accessibilityRole="button"
          onPress={onToggleTray}
          // HIG 최소 44pt 터치. 시각 32×32 유지 + hitSlop 6. (W11)
          hitSlop={{ top: 6, bottom: 6, left: 6, right: 6 }}
          style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
        >
          <View
            style={{
              alignItems: 'center',
              backgroundColor: trayOpen
                ? fortuneTheme.colors.backgroundTertiary
                : fortuneTheme.colors.surfaceElevated,
              borderRadius: 16,
              height: 32,
              justifyContent: 'center',
              width: 32,
            }}
          >
            <View
              style={{
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.textSecondary,
                  borderRadius: 999,
                  height: 2,
                  position: 'absolute',
                  width: 11,
                }}
              />
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.textSecondary,
                  borderRadius: 999,
                  height: 11,
                  width: 2,
                }}
              />
            </View>
          </View>
        </Pressable>
        <View style={{ flex: 1 }}>
          <TextInput
            accessibilityLabel="chat composer"
            multiline
            onChangeText={onDraftChange}
            placeholder={voiceRecording ? '녹음 중...' : '메시지...'}
            placeholderTextColor={
              voiceRecording ? '#EF4444' : fortuneTheme.colors.textTertiary
            }
            style={{
              color: fortuneTheme.colors.textPrimary,
              maxHeight: 72,
              minHeight: 28,
              paddingHorizontal: 4,
              paddingVertical: 6,
              textAlignVertical: 'center',
            }}
            value={draft}
          />
        </View>
        <Pressable
          accessibilityLabel={
            canSend && !voiceActive
              ? 'send message'
              : voiceRecording
                ? '녹음 중지'
                : voiceTranscribing
                  ? '변환 중'
                  : 'start voice input'
          }
          accessibilityRole="button"
          accessibilityState={{ disabled: sendDisabled || voiceTranscribing }}
          disabled={sendDisabled || voiceTranscribing}
          onPress={
            sendDisabled && !voiceActive
              ? undefined
              : canSend && !voiceActive
                ? onSend
                : onToggleVoiceInput
          }
          // HIG 최소 44pt 터치. 시각 32×32 유지 + hitSlop 6. (W11)
          hitSlop={{ top: 6, bottom: 6, left: 6, right: 6 }}
          style={{
            alignItems: 'center',
            backgroundColor: canSend && !voiceActive
              ? sendDisabled
                ? fortuneTheme.colors.surfaceElevated
                : fortuneTheme.colors.ctaBackground
              : voiceRecording
                ? '#EF4444'
                : fortuneTheme.colors.surfaceElevated,
            borderRadius: 16,
            height: 32,
            justifyContent: 'center',
            minWidth: 32,
            paddingHorizontal: canSend && !voiceActive ? 10 : 0,
            opacity: sendDisabled && !voiceActive ? 0.72 : 1,
          }}
        >
          {canSend && !voiceActive ? (
            <AppText
              variant="labelLarge"
              color={
                sendDisabled
                  ? fortuneTheme.colors.textSecondary
                  : fortuneTheme.colors.ctaForeground
              }
            >
              {sendDisabled ? '응답 중' : '보내기'}
            </AppText>
          ) : voiceTranscribing ? (
            <ActivityIndicator
              size="small"
              color={fortuneTheme.colors.ctaBackground}
            />
          ) : (
            <Animated.View style={{ opacity: voiceRecording ? micPulseAnim : 1 }}>
              <Ionicons
                color={voiceRecording ? '#FFFFFF' : fortuneTheme.colors.textSecondary}
                name={voiceRecording ? 'mic' : 'mic-outline'}
                size={18}
              />
            </Animated.View>
          )}
        </Pressable>
      </View>
    </View>
  );
}

function formatIsoDate(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(
    d.getDate(),
  ).padStart(2, '0')}`;
}

function SurveyDatePicker({ onSelect }: { onSelect: (isoDate: string) => void }) {
  const [selectedDate, setSelectedDate] = useState<Date | null>(null);
  const [showCalendar, setShowCalendar] = useState(true);

  const handleQuickChip = useCallback(
    (offset: number) => {
      const target = new Date();
      target.setDate(target.getDate() + offset);
      setSelectedDate(target);
      onSelect(formatIsoDate(target));
    },
    [onSelect],
  );

  const handleCalendarSelect = useCallback(
    (date: Date) => {
      setSelectedDate(date);
      onSelect(formatIsoDate(date));
    },
    [onSelect],
  );

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      {/* Quick-pick chips */}
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
        <Pressable
          accessibilityRole="button"
          onPress={() => handleQuickChip(0)}
          style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
        >
          <Chip label={`오늘 ${new Date().getMonth() + 1}/${new Date().getDate()}`} tone="neutral" />
        </Pressable>

        <Pressable
          accessibilityRole="button"
          onPress={() => handleQuickChip(1)}
          style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
        >
          <Chip
            label={(() => {
              const t = new Date();
              t.setDate(t.getDate() + 1);
              return `내일 ${t.getMonth() + 1}/${t.getDate()}`;
            })()}
            tone="neutral"
          />
        </Pressable>

        <Pressable
          accessibilityRole="button"
          onPress={() => setShowCalendar((v) => !v)}
          style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
        >
          <Chip
            label={showCalendar ? '달력 닫기' : '직접 선택'}
            tone={showCalendar ? 'accent' : 'neutral'}
          />
        </Pressable>
      </View>

      {/* Inline calendar */}
      {showCalendar ? (
        <InlineCalendar
          selectedDate={selectedDate}
          onSelectDate={handleCalendarSelect}
        />
      ) : null}
    </View>
  );
}

const MBTI_AXES = [
  { id: 'EI', left: { key: 'E', label: '외향 (E)', desc: '에너지를 밖에서' }, right: { key: 'I', label: '내향 (I)', desc: '에너지를 안에서' } },
  { id: 'SN', left: { key: 'S', label: '감각 (S)', desc: '현실·사실 중심' }, right: { key: 'N', label: '직관 (N)', desc: '가능성·패턴 중심' } },
  { id: 'TF', left: { key: 'T', label: '사고 (T)', desc: '논리·원칙 중심' }, right: { key: 'F', label: '감정 (F)', desc: '가치·공감 중심' } },
  { id: 'JP', left: { key: 'J', label: '판단 (J)', desc: '계획·체계적' }, right: { key: 'P', label: '인식 (P)', desc: '유연·즉흥적' } },
  { id: 'AO', left: { key: 'A', label: '주장적 (A)', desc: '자신감·스트레스 저항' }, right: { key: 'T', label: '격동적 (T)', desc: '완벽주의·자기개선' } },
] as const;

function MbtiAxisPicker({ onSubmit }: { onSubmit: (value: string) => void }) {
  const [selections, setSelections] = useState<Record<string, string | null>>({
    EI: null, SN: null, TF: null, JP: null, AO: null,
  });

  const handleSelect = (axisId: string, value: string) => {
    setSelections((prev) => ({
      ...prev,
      [axisId]: prev[axisId] === value ? null : value,
    }));
  };

  const handleUnknown = (axisId: string) => {
    setSelections((prev) => ({
      ...prev,
      [axisId]: prev[axisId] === '?' ? null : '?',
    }));
  };

  const coreComplete = selections.EI && selections.SN && selections.TF && selections.JP;

  const handleSubmit = () => {
    const core = [
      selections.EI === '?' ? 'X' : (selections.EI || 'X'),
      selections.SN === '?' ? 'X' : (selections.SN || 'X'),
      selections.TF === '?' ? 'X' : (selections.TF || 'X'),
      selections.JP === '?' ? 'X' : (selections.JP || 'X'),
    ].join('');
    const extra = selections.AO && selections.AO !== '?' ? `-${selections.AO}` : '';
    onSubmit(`${core}${extra}`);
  };

  return (
    <View style={{ gap: 12 }}>
      {MBTI_AXES.map((axis) => {
        const sel = selections[axis.id];
        const isOptional = axis.id === 'AO';
        return (
          <View key={axis.id} style={{ gap: 6 }}>
            {isOptional ? (
              <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                선택사항: 정체성 축
              </AppText>
            ) : null}
            <View style={{ flexDirection: 'row', gap: 6 }}>
              <Pressable
                onPress={() => handleSelect(axis.id, axis.left.key)}
                style={({ pressed }) => ({
                  flex: 1,
                  backgroundColor: sel === axis.left.key ? fortuneTheme.colors.ctaBackground + '25' : fortuneTheme.colors.surfaceSecondary,
                  borderWidth: sel === axis.left.key ? 2 : 1,
                  borderColor: sel === axis.left.key ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.border,
                  borderRadius: fortuneTheme.radius.md,
                  paddingVertical: 10,
                  paddingHorizontal: 12,
                  opacity: pressed ? 0.7 : 1,
                })}
              >
                <AppText variant="labelLarge" color={sel === axis.left.key ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.textPrimary}>
                  {axis.left.label}
                </AppText>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  {axis.left.desc}
                </AppText>
              </Pressable>
              <Pressable
                onPress={() => handleSelect(axis.id, axis.right.key)}
                style={({ pressed }) => ({
                  flex: 1,
                  backgroundColor: sel === axis.right.key ? fortuneTheme.colors.ctaBackground + '25' : fortuneTheme.colors.surfaceSecondary,
                  borderWidth: sel === axis.right.key ? 2 : 1,
                  borderColor: sel === axis.right.key ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.border,
                  borderRadius: fortuneTheme.radius.md,
                  paddingVertical: 10,
                  paddingHorizontal: 12,
                  opacity: pressed ? 0.7 : 1,
                })}
              >
                <AppText variant="labelLarge" color={sel === axis.right.key ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.textPrimary}>
                  {axis.right.label}
                </AppText>
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
                  {axis.right.desc}
                </AppText>
              </Pressable>
              <Pressable
                onPress={() => handleUnknown(axis.id)}
                style={({ pressed }) => ({
                  backgroundColor: sel === '?' ? fortuneTheme.colors.surfaceSecondary : 'transparent',
                  borderWidth: 1,
                  borderColor: sel === '?' ? fortuneTheme.colors.textTertiary : fortuneTheme.colors.border,
                  borderRadius: fortuneTheme.radius.md,
                  paddingVertical: 10,
                  paddingHorizontal: 8,
                  alignItems: 'center',
                  justifyContent: 'center',
                  opacity: pressed ? 0.7 : 1,
                })}
              >
                <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>모름</AppText>
              </Pressable>
            </View>
          </View>
        );
      })}
      <Pressable
        onPress={handleSubmit}
        disabled={!coreComplete}
        style={({ pressed }) => ({
          backgroundColor: coreComplete ? fortuneTheme.colors.ctaBackground : fortuneTheme.colors.surfaceSecondary,
          borderRadius: fortuneTheme.radius.full,
          paddingVertical: 14,
          alignItems: 'center',
          opacity: !coreComplete ? 0.5 : pressed ? 0.8 : 1,
        })}
      >
        <AppText variant="labelLarge" color={coreComplete ? '#FFFFFF' : fortuneTheme.colors.textTertiary}>
          {coreComplete ? '확인' : '4개 기본 축을 선택해주세요'}
        </AppText>
      </Pressable>
    </View>
  );
}

function SurveyImagePicker({
  onPickImage,
}: {
  onPickImage: (base64: string) => void;
}) {
  const [previewUri, setPreviewUri] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  async function pickFromSource(source: 'camera' | 'gallery') {
    setIsLoading(true);

    try {
      const permissionResult =
        source === 'camera'
          ? await ImagePicker.requestCameraPermissionsAsync()
          : await ImagePicker.requestMediaLibraryPermissionsAsync();

      if (!permissionResult.granted) {
        setIsLoading(false);
        return;
      }

      const launchFn =
        source === 'camera'
          ? ImagePicker.launchCameraAsync
          : ImagePicker.launchImageLibraryAsync;

      const result = await launchFn({
        mediaTypes: ['images'],
        quality: 0.7,
        base64: true,
        allowsEditing: true,
        aspect: [1, 1],
      });

      if (result.canceled || !result.assets?.[0]) {
        setIsLoading(false);
        return;
      }

      const asset = result.assets[0];
      setPreviewUri(asset.uri);

      if (asset.base64) {
        onPickImage(asset.base64);
      }
    } catch {
      setIsLoading(false);
    }
  }

  if (previewUri) {
    return (
      <View style={{ gap: fortuneTheme.spacing.sm, alignItems: 'center' }}>
        <Image
          source={{ uri: previewUri }}
          style={{
            width: 120,
            height: 120,
            borderRadius: fortuneTheme.radius.card,
            borderWidth: 1,
            borderColor: fortuneTheme.colors.border,
          }}
        />
        <AppText variant="bodySmall" style={{ color: fortuneTheme.colors.textSecondary }}>
          사진이 전송되었어요
        </AppText>
      </View>
    );
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      {/* 개인정보 처리 사전 고지 — 카메라/갤러리 권한 요청 전에 보이도록. (W14) */}
      <View
        style={{
          borderRadius: fortuneTheme.radius.md,
          borderWidth: 1,
          borderColor: fortuneTheme.colors.border,
          backgroundColor: 'rgba(224,167,107,0.06)',
          paddingVertical: 8,
          paddingHorizontal: 12,
        }}
      >
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textSecondary}
          style={{ lineHeight: 18 }}
        >
          선택한 사진은 관상 분석을 위해 안전한 서버로 전송되며, 응답 생성 후
          서버에 저장되지 않아요. 타인의 사진을 본인 동의 없이 업로드하지 말아
          주세요.
        </AppText>
      </View>

      <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
        <View style={{ flex: 1 }}>
          <PrimaryButton
            disabled={isLoading}
            onPress={() => pickFromSource('camera')}
          >
            카메라로 촬영
          </PrimaryButton>
        </View>
        <View style={{ flex: 1 }}>
          <PrimaryButton
            disabled={isLoading}
            tone="secondary"
            onPress={() => pickFromSource('gallery')}
          >
            갤러리에서 선택
          </PrimaryButton>
        </View>
      </View>
      {isLoading ? (
        <AppText
          variant="bodySmall"
          style={{ color: fortuneTheme.colors.textSecondary, textAlign: 'center' }}
        >
          사진을 처리하고 있어요...
        </AppText>
      ) : null}
    </View>
  );
}

export function ActiveSurveyFooter({
  step,
  draft,
  selections,
  surveyAnswers,
  onDraftChange,
  onPickSingle,
  onToggleSelection,
  onSubmitSelection,
  onSubmitText,
  onSkip,
}: {
  step: ChatSurveyStep;
  draft: string;
  selections: readonly string[];
  surveyAnswers?: Record<string, unknown>;
  onDraftChange: (value: string) => void;
  onPickSingle: (value: string) => void;
  onToggleSelection: (value: string) => void;
  onSubmitSelection: () => void;
  onSubmitText: () => void;
  onSkip: () => void;
}) {
  const canSubmitText = draft.trim().length > 0;
  const canSubmitSelection = selections.length > 0;

  if (step.inputKind === 'chips') {
    return (
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {(step.options ?? []).map((option) => (
            <Pressable
              key={option.id}
              accessibilityRole="button"
              onPress={() => onPickSingle(option.id)}
              style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
            >
              <Chip
                label={option.emoji ? `${option.emoji} ${option.label}` : option.label}
                tone="neutral"
              />
            </Pressable>
          ))}
        </View>
      </View>
    );
  }

  if (step.inputKind === 'date') {
    return (
      <SurveyDatePicker onSelect={(isoDate) => onPickSingle(isoDate)} />
    );
  }

  if (step.inputKind === 'card-draw') {
    const deckColorMap: Record<string, { primary: string; secondary: string; label: string }> = {
      classic: { primary: '#4A5568', secondary: '#ECC94B', label: '클래식' },
      moonlight: { primary: '#1A1A4E', secondary: '#A78BFA', label: '문라이트' },
      gold: { primary: '#5C3D1E', secondary: '#FFD700', label: '골드' },
    };
    const selectedDeckId = typeof surveyAnswers?.deckId === 'string' ? surveyAnswers.deckId : 'classic';
    const deck = deckColorMap[selectedDeckId] ?? deckColorMap.classic;
    const deckColors = { primary: deck.primary, secondary: deck.secondary };
    const deckName = deck.label;
    const requiredCount = step.maxSelections ?? 3;

    return (
      <TarotDrawWidget
        requiredCount={requiredCount}
        deckName={deckName}
        deckColors={deckColors}
        onComplete={(cards) => onPickSingle(cards.join(','))}
      />
    );
  }

  if (step.inputKind === 'multi-select') {
    return (
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {(step.options ?? []).map((option) => {
            const selected = selections.includes(option.id);
            return (
              <Pressable
                key={option.id}
                accessibilityRole="button"
                onPress={() => onToggleSelection(option.id)}
                style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
              >
                <Chip
                  label={option.emoji ? `${option.emoji} ${option.label}` : option.label}
                  tone={selected ? 'accent' : 'neutral'}
                />
              </Pressable>
            );
          })}
        </View>
        <PrimaryButton disabled={!canSubmitSelection} onPress={onSubmitSelection}>
          선택 완료
        </PrimaryButton>
      </View>
    );
  }

  if (step.inputKind === 'image') {
    return (
      <SurveyImagePicker onPickImage={onPickSingle} />
    );
  }

  if (step.inputKind === 'mbti-axis') {
    return <MbtiAxisPicker onSubmit={onPickSingle} />;
  }

  return (
    <SurveyComposer
      value={draft}
      onChangeText={onDraftChange}
      onSubmit={onSubmitText}
      onSkip={step.inputKind === 'text-with-skip' ? onSkip : undefined}
      placeholder={step.placeholder ?? '답변을 적어주세요.'}
    />
  );
}

export function ActiveCharacterChatSurface({
  character,
  actions,
  messages,
  surveyEyebrow,
  surveyActive,
  isTyping = false,
  pendingQueueCount = 0,
  onBack,
  onOpenProfile,
  onPickAction,
  showHeader = true,
  romanceScore = 0,
  presenceLine,
}: {
  character: ChatCharacterSpec;
  actions: ChatShellAction[];
  messages: ChatShellMessage[];
  surveyEyebrow?: string | null;
  surveyActive?: boolean;
  isTyping?: boolean;
  /** 응답 대기 중 추가로 쌓인 큐 메시지 수 ("대기 +N" 표시용). */
  pendingQueueCount?: number;
  onBack: () => void;
  onOpenProfile: () => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
  showHeader?: boolean;
  romanceScore?: number;
  /**
   * 카톡식 프레전스 라인 ("커피 내리는 중", "네 생각 중..." 등).
   * 비어있거나 undefined면 기존 `shortDescription`으로 폴백.
   */
  presenceLine?: string | null;
}) {
  const isFortuneCharacter = isFortuneChatCharacter(character);
  const visibleMessages = messages;
  const promptActions = actions;
  const hasEmbeddedResult = visibleMessages.some(
    (message) =>
      message.kind === 'embedded-result' ||
      message.kind === 'fortune-cookie' ||
      message.kind === 'saju-preview' ||
      message.kind === 'story-reveal',
  );
  const previewMessages = visibleMessages.some((message) => message.sender === 'user')
    ? visibleMessages
    : [
        visibleMessages[0] ?? {
          id: `${character.id}-assistant-preview-1`,
          kind: 'text' as const,
          sender: 'assistant' as const,
          text: isFortuneCharacter
            ? `안녕하세요! 오늘 ${character.name}의 흐름으로 먼저 볼까요?`
            : `안녕하세요! ${character.name}과 오늘의 이야기를 먼저 열어볼까요?`,
        },
        {
          id: `${character.id}-user-preview`,
          kind: 'text' as const,
          sender: 'user' as const,
          text:
            promptActions[0]?.prompt ??
            (isFortuneCharacter
              ? `오늘 ${character.name}에게 가장 먼저 물어보면 좋을 흐름이 있을까요?`
              : `오늘 ${character.name}과 가장 먼저 꺼내면 좋을 이야기가 있을까요?`),
        },
        visibleMessages[1] ?? {
          id: `${character.id}-assistant-preview-2`,
          kind: 'text' as const,
          sender: 'assistant' as const,
          text:
            promptActions[0]?.reply ??
            (isFortuneCharacter
              ? `${character.shortDescription} 흐름으로 먼저 풀어드릴게요.`
              : `${character.shortDescription} 분위기로 먼저 대화를 이어가 볼게요.`),
        },
      ];

  const chatTintBg = romanceScore > 5 ? romanceTintBackground(romanceScore) : undefined;

  return (
    <View style={{ gap: fortuneTheme.spacing.md, backgroundColor: chatTintBg }}>
      {showHeader ? (
        <ActiveCharacterChatHeader
          character={character}
          onBack={onBack}
          onOpenProfile={onOpenProfile}
          presenceLine={presenceLine ?? null}
        />
      ) : null}

      {!hasEmbeddedResult ? (
        <View
          style={{
            alignItems: 'center',
            gap: fortuneTheme.spacing.xs,
            paddingTop: 6,
          }}
        >
          <CharacterAvatar
            characterId={character.id}
            name={character.name}
            size={72}
          />
          <View style={{ alignItems: 'center', gap: 4 }}>
            <AppText variant="heading4">{character.name}</AppText>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ maxWidth: 230, textAlign: 'center' }}
            >
              {presenceLine && presenceLine.length > 0
                ? presenceLine
                : character.shortDescription}
            </AppText>
          </View>
          <Pressable
            accessibilityRole="button"
            onPress={onOpenProfile}
            style={({ pressed }) => ({ opacity: pressed ? 0.82 : 1 })}
          >
            <View
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderColor: fortuneTheme.colors.border,
                borderRadius: 999,
                borderWidth: 1,
                paddingHorizontal: 12,
                paddingVertical: 6,
              }}
            >
              <AppText
                variant="caption"
                color={fortuneTheme.colors.textSecondary}
              >
                프로필 보기
              </AppText>
            </View>
          </Pressable>
        </View>
      ) : null}

      <View
        style={{
          alignItems: 'center',
          paddingTop: 2,
          gap: 4,
        }}
      >
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
          {formatChatHeaderTimestamp(new Date())}
        </AppText>
        {surveyActive && surveyEyebrow ? (
          <Chip label={surveyEyebrow} tone="accent" />
        ) : null}
      </View>

      <View style={{ gap: fortuneTheme.spacing.sm }}>
        {previewMessages.map((message) => (
          <ChatThreadMessage
            key={message.id}
            character={character}
            message={message}
          />
        ))}
        {isTyping ? (
          <TypingIndicatorBubble
            character={character}
            queuedCount={pendingQueueCount}
          />
        ) : null}
      </View>

      {!surveyActive && promptActions.length > 0 ? (
        <View
          style={{
            gap: 8,
            paddingLeft: hasEmbeddedResult ? 0 : 32,
          }}
        >
          <View
            style={{
              flexDirection: 'row',
              flexWrap: 'wrap',
              gap: 8,
            }}
          >
            {promptActions.map((action, actionIndex) => (
              <Pressable
                key={action.id}
                accessibilityRole="button"
                onPress={() => onPickAction(action.fortuneType)}
                style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
              >
                <View
                  style={{
                    backgroundColor:
                      actionIndex % 4 === 0
                        ? 'rgba(232, 236, 255, 0.96)'
                        : actionIndex % 4 === 1
                          ? 'rgba(205, 244, 213, 0.96)'
                          : actionIndex % 4 === 2
                            ? 'rgba(255, 236, 213, 0.96)'
                            : 'rgba(236, 221, 255, 0.96)',
                    borderRadius: 999,
                    paddingHorizontal: 14,
                    paddingVertical: 8,
                  }}
                >
                  <AppText
                    variant="bodySmall"
                    color={fortuneTheme.colors.background}
                    style={{ fontWeight: '600' }}
                  >
                    {action.label}
                  </AppText>
                </View>
              </Pressable>
            ))}
          </View>
        </View>
      ) : null}

    </View>
  );
}

export function ActiveCharacterChatHeader({
  character,
  affinity,
  onBack,
  onOpenProfile,
  presenceLine,
}: {
  character: ChatCharacterSpec;
  affinity?: number;
  onBack: () => void;
  onOpenProfile: () => void;
  /**
   * 카톡식 프레전스 라인. 값이 있으면 기본 역할 설명(caption)을 대체.
   */
  presenceLine?: string | null;
}) {
  const isFortuneCharacter = isFortuneChatCharacter(character);
  const showAffinity = !isFortuneCharacter && typeof affinity === 'number' && affinity > 0;
  const affinityLabel =
    affinity == null ? ''
    : affinity < 25 ? '알아가는 중'
    : affinity < 50 ? '관심'
    : affinity < 75 ? '친밀'
    : '깊은 유대';
  const affinityColor =
    affinity == null ? fortuneTheme.colors.ctaBackground
    : affinity < 25 ? '#8E8E93'
    : affinity < 50 ? '#5AC8FA'
    : affinity < 75 ? '#AF52DE'
    : '#FF2D55';

  return (
    <View style={{ gap: 6 }}>
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          justifyContent: 'space-between',
        }}
      >
        <Pressable
          accessibilityRole="button"
          onPress={onBack}
          style={({ pressed }) => ({ opacity: pressed ? 0.8 : 1 })}
        >
          <Ionicons
            color={fortuneTheme.colors.textPrimary}
            name="chevron-back"
            size={22}
          />
        </Pressable>
        <View
          style={{
            alignItems: 'center',
            flex: 1,
            flexDirection: 'row',
            gap: 10,
            justifyContent: 'center',
          }}
        >
          <CharacterAvatar characterId={character.id} name={character.name} size={34} />
          <View style={{ alignItems: 'center', gap: 2 }}>
            <AppText variant="labelLarge">{character.name}</AppText>
            <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
              {presenceLine && presenceLine.length > 0
                ? presenceLine
                : isFortuneCharacter
                  ? 'AI 상담사 · 대화를 이어보세요'
                  : '스토리 캐릭터 · 관계를 이어보세요'}
            </AppText>
          </View>
        </View>
        <Pressable
          accessibilityRole="button"
          onPress={onOpenProfile}
          style={({ pressed }) => ({ opacity: pressed ? 0.8 : 1 })}
        >
          <Ionicons
            color={fortuneTheme.colors.textPrimary}
            name="information-circle-outline"
            size={22}
          />
        </Pressable>
      </View>
      {showAffinity ? (
        <View style={{ alignItems: 'center', gap: 4, paddingHorizontal: 40 }}>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 6 }}>
            <Ionicons name="heart" size={12} color={affinityColor} />
            <AppText variant="caption" color={affinityColor}>
              {affinityLabel}
            </AppText>
          </View>
          <View
            style={{
              width: '100%',
              height: 3,
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: 2,
              overflow: 'hidden',
            }}
          >
            <View
              style={{
                width: `${Math.min(affinity ?? 0, 100)}%`,
                height: '100%',
                backgroundColor: affinityColor,
                borderRadius: 2,
              }}
            />
          </View>
        </View>
      ) : null}
    </View>
  );
}

export function ProfileFlowGateCard({
  birthCompleted,
  interestCompleted,
  firstRunHandoffSeen,
  onContinue,
}: {
  birthCompleted: boolean;
  interestCompleted: boolean;
  firstRunHandoffSeen: boolean;
  onContinue: () => void;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      <View style={{ gap: fortuneTheme.spacing.xs }}>
        <AppText variant="displaySmall">대화를 시작하기 전</AppText>
        <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
          출생 정보와 관심사를 마치면 채팅과 인사이트 흐름이 더 정확하게 이어집니다.
        </AppText>
      </View>

      <Card>
        <View style={{ gap: fortuneTheme.spacing.xs }}>
          <AppText variant="heading4">시작 준비 현황</AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
          >
            대화 전에 필요한 정보가 얼마나 준비됐는지 보여드려요.
          </AppText>
        </View>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`생년월일 ${birthCompleted ? '입력됨' : '입력 필요'}`} tone={birthCompleted ? 'success' : 'neutral'} />
          <Chip label={`관심사 ${interestCompleted ? '선택됨' : '선택 필요'}`} tone={interestCompleted ? 'success' : 'neutral'} />
          <Chip label={`서비스 소개 ${firstRunHandoffSeen ? '확인함' : '확인 필요'}`} tone={firstRunHandoffSeen ? 'success' : 'neutral'} />
        </View>
        <PrimaryButton onPress={onContinue}>대화 준비 이어가기</PrimaryButton>
      </Card>
    </View>
  );
}
