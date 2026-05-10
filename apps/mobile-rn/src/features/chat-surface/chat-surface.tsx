import { useState, useEffect, useRef, useCallback, type PropsWithChildren, type ReactNode } from 'react';

import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { ActivityIndicator, Alert, Animated, Dimensions, Easing, Image, Modal, PanResponder, Pressable, ScrollView, TextInput, View } from 'react-native';

import type { VoiceInputState } from '../../lib/use-voice-input';

import type { FortuneTypeId } from '@fortune/product-contracts';

import { AppleAuthButton } from '../../components/apple-auth-button';
import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { Chip } from '../../components/chip';
import { InlineCalendar } from '../../components/inline-calendar';
import { PrimaryButton } from '../../components/primary-button';
import { SpeakerButton } from '../../components/speaker-button';
import { SurveyComposer } from '../../components/survey-composer';
import { SocialAuthPillButton } from '../../components/social-auth-pill-button';
import { VoiceWaveform } from '../../components/voice-waveform';
import { characterDetails } from '../../lib/character-details';
import {
  isFortuneChatCharacter,
  type ChatCharacterSpec,
  type ChatCharacterTab,
} from '../../lib/chat-characters';
import type {
  ChatShellAction,
  ChatShellImageMessage,
  ChatShellMessage,
  ChatShellTextMessage,
} from '../../lib/chat-shell';
import { buildSuggestedActions, formatFortuneTypeLabel } from '../../lib/chat-shell';
import { resolveChatCharacterAvatarSource } from '../../lib/chat-character-avatar';
import { confirmAction } from '../../lib/haptics';
import { fortuneTheme, romanceTintBackground } from '../../lib/theme';
import { useIsTyping } from '../../lib/typing-store';
import { useMobileAppState } from '../../providers/mobile-app-state-provider';

import { MessageReportSheet } from './message-report-sheet';
import { EmbeddedResultCard } from '../chat-results/embedded-result-card';
import { FortuneMenuCard } from '../fortune-results/fortune-menu-card';
import { FadeUpWords, StoryRevealMessage } from '../story-chat-animations';
import { FortuneCookieCard } from '../fortune-cookie/fortune-cookie-card';
import { SajuPreviewCard } from '../fortune-cookie/saju-preview-card';
import { MySajuContextCard } from './my-saju-context-card';
import { ProgressMessageCard } from './progress-message-card';
import type { ChatSurveyStep } from '../chat-survey/types';
import { TarotDrawWidget } from '../chat-survey/tarot-draw-widget';
import { getDeckCoverSource } from '../haneul/tarot-deck-covers';

/**
 * 메시지 ID 에서 unix-ms timestamp 추출. 옛 ID 패턴: `<sender>-<unixMs>-<rand>`.
 * 매칭 안 되면 0 반환 — 정렬 시 맨 앞으로 가지만 stable sort 라 원래 위치 유지.
 */
function extractTimestampFromMessageId(id: string): number {
  const match = id.match(/-(\d{13})-/);
  if (!match?.[1]) return 0;
  const ts = Number(match[1]);
  return Number.isFinite(ts) ? ts : 0;
}

/**
 * 메시지 배열을 ID 내장 timestamp 기준 ascending 정렬.
 * 빠른 연속 send + remote hydrate 충돌로 array index 가 chronology 와
 * 어긋날 때 화면 순서가 망가지던 회귀 fix (2026-05-08).
 */
function sortMessagesByTimestamp<T extends { id: string }>(messages: readonly T[]): T[] {
  const indexed = messages.map((message, index) => ({
    message,
    timestamp: extractTimestampFromMessageId(message.id),
    index,
  }));
  indexed.sort((a, b) => {
    if (a.timestamp !== b.timestamp) return a.timestamp - b.timestamp;
    return a.index - b.index;
  });
  return indexed.map((entry) => entry.message);
}

/**
 * 채팅 목록 preview 와 대화방 render 가 반드시 같은 canonical thread 를 보도록
 * 한 곳에서 정렬 기준을 정의한다. 여기서 바꾼 순서가 목록/방 모두에 적용된다.
 */
export function getCanonicalVisibleMessages(messages: readonly ChatShellMessage[]): ChatShellMessage[] {
  return sortMessagesByTimestamp(messages);
}

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

  // webp 원본은 portrait 인물사진(약 576×1024 / 9:16). 정사각형 동그라미에
  // resizeMode='cover' 디폴트를 그대로 두면 좌우 기준 cover crop 으로 얼굴이
  // 위로 빠져나가 어깨/가슴이 보인다. 이미지를 컨테이너 폭에 맞추고 비율 유지로
  // 세로를 늘린 뒤 top:0 으로 align — 얼굴이 동그라미 위쪽에 들어와 보이게.
  const PORTRAIT_ASPECT = 9 / 16;
  const imageHeight = size / PORTRAIT_ASPECT;

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
          resizeMode="cover"
          style={{
            height: imageHeight,
            left: 0,
            position: 'absolute',
            top: 0,
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

// PR-B1: SegmentedPills (스토리/호기심 chip 라인) 제거.
// 호기심 chip 은 이미 비활성, 스토리 chip 단독은 의미 없는 시각 노이즈.
// 사용자가 명시적으로 "그 chip 라인바 자체가 없어도 돼" 라고 요청.
// 운세는 하늘이 채팅 안의 메뉴 카드로 통합 — 별도 탭 자체가 불필요.

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
  /**
   * 마지막 활동 시각(ms epoch). 받은 메시지 / 보낸 메시지 가장 최근 것.
   * 채팅 목록 정렬 (최근 활동 desc) 에 사용. 정보 없으면 0.
   */
  lastActivityAt: number;
}

/**
 * 메시지 한 개에서 활동 시각(ms epoch) 을 최대한 추출한다. ChatShellMessage 가
 * 타입별로 시간 필드를 다르게 가지므로 우선순위:
 *   1) `createMessageId` (chat-shell.ts:596) 가 박은 `${prefix}-${Date.now()}-rand`
 *      → id.split('-')[1] 의 ms epoch (가장 흔한 케이스)
 *   2) my-saju-context.timestamp (number)
 *   3) text 의 proactive.generatedAt (ISO8601)
 *   4) text 의 readAt (ISO8601, 사용자 메시지 읽음 시각)
 * 어느 것도 없으면 0 — 정렬 시 가장 뒤로 보낸다.
 */
function extractActivityFromMessage(message: ChatShellMessage): number {
  const idParts = message.id.split('-');
  const idTimestamp = Number(idParts[1]);
  // 2017-07-14 이후 ms epoch 만 유효 — 더 작은 값은 ID 가 다른 형식 (예:
  // `${characterId}:${fortuneType}`) 인 케이스라 무시.
  if (Number.isFinite(idTimestamp) && idTimestamp > 1_500_000_000_000) {
    return idTimestamp;
  }
  if (message.kind === 'my-saju-context') {
    return message.timestamp;
  }
  if (message.kind === 'text') {
    if (message.proactive?.generatedAt) {
      const parsed = Date.parse(message.proactive.generatedAt);
      if (Number.isFinite(parsed)) return parsed;
    }
    if (message.readAt) {
      const parsed = Date.parse(message.readAt);
      if (Number.isFinite(parsed)) return parsed;
    }
  }
  return 0;
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
    case 'progress':
      return message.error ? `⚠️ ${message.phase}` : `⏳ ${message.phase}`;
    default:
      return '';
  }
}

export function buildCharacterListMeta(
  messages: readonly ChatShellMessage[] | undefined,
  lastSeenMessageId: string | undefined,
): CharacterListRowMeta {
  if (!messages || messages.length === 0) {
    return { lastMessagePreview: null, unreadCount: 0, unread: false, lastActivityAt: 0 };
  }

  // 대화방 렌더와 동일한 canonical ordering 을 사용한다. 이전 구현은 원본
  // array tail 을 preview 로 썼고, 대화방은 timestamp 정렬 후 렌더해서 빠른
  // 전송/원격 hydrate/merge 뒤에 목록 마지막 문구와 방 안 마지막 문구가 갈라졌다.
  const canonicalMessages = getCanonicalVisibleMessages(messages);
  const last = canonicalMessages[canonicalMessages.length - 1];
  const preview = last ? extractMessagePreview(last) : '';
  const lastActivityAt = last ? extractActivityFromMessage(last) : 0;

  // Unread 판정 (일반 메신저 표준):
  //   "lastSeen 이후로 도착한 assistant/system 메시지 개수" 를 센다. 0 이면
  //   읽음 상태. 배지에 카운트를 띄우려고 boolean 대신 count 를 보관.
  // 과거 구현은 "마지막 메시지가 assistant 인지"만 봐서, AI 가 여러 번 연속
  // 보내고 유저가 짧게 답하면 마지막이 user → 안 읽힌 AI 메시지가 있어도
  // 닷이 사라지는 버그가 있었다.
  let startIndex: number;
  if (!lastSeenMessageId) {
    // 한 번도 안 본 캐릭터 — 전체 메시지를 unread 로 카운트.
    startIndex = 0;
  } else {
    const found = canonicalMessages.findIndex((m) => m.id === lastSeenMessageId);
    if (found === -1) {
      // 저장된 lastSeen ID 가 현재 메시지 배열에 없음 — 원격 재동기화로 ID
      // 가 바뀌었거나 메시지 prune 등 시스템 사정. lastSeen 이 존재한다는
      // 사실 자체가 "한 번 이상 채팅방을 열었다" 는 증거이므로, 모르는 ID
      // 를 만났을 때 "전부 안 읽음" 으로 해석하면 사용자 체감 회귀가 크다.
      // 보수적으로 "이미 다 읽음" (startIndex = 끝) 으로 처리.
      startIndex = canonicalMessages.length;
    } else {
      startIndex = found + 1;
    }
  }
  let unreadCount = 0;
  for (let i = startIndex; i < canonicalMessages.length; i += 1) {
    const m = canonicalMessages[i];
    if (m.sender === 'assistant' || m.sender === 'system') {
      unreadCount += 1;
    }
  }
  return {
    lastMessagePreview: preview.length > 0 ? preview : null,
    unreadCount,
    unread: unreadCount > 0,
    lastActivityAt,
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
  // typing-store 글로벌 read — 채팅창에 진입 안 해도 다른 surface (예: 콜드
  // 스타트 펜딩 답장 재개) 에서 set true 면 list 행에 "입력 중…" 노출.
  const isTyping = useIsTyping(character.id);

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
            isTyping
              ? fortuneTheme.colors.accentSecondary
              : meta?.unread
                ? fortuneTheme.colors.textPrimary
                : fortuneTheme.colors.textSecondary
          }
          style={
            isTyping || meta?.unread ? { fontWeight: '600' } : undefined
          }
        >
          {isTyping
            ? '입력 중…'
            : (meta?.lastMessagePreview ?? character.shortDescription)}
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
  // 단어 reveal 마다 가벼운 selection 햅틱 — 프로필 chatHapticsEnabled 게이트.
  const { state: mobileAppState } = useMobileAppState();
  const chatHapticsEnabled = mobileAppState.settings.chatHapticsEnabled;

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
            hapticsEnabled={chatHapticsEnabled}
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

function TypingIndicatorBubble(_props: {
  character: ChatCharacterSpec;
  /** @deprecated 배칭은 사용자에게 투명. 호출자 호환을 위해 시그니처만 유지. */
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

/**
 * Slice 2: proactive 사진 버블 — loading skeleton, onError fallback, tap → fullscreen.
 * PROACTIVE_MESSAGING_PLAN.md Slice 2 §2.2.8 (A8 + T3).
 */
function ProactiveImageBubble({
  imageUrl,
  caption,
}: {
  imageUrl: string;
  caption?: string;
}) {
  const [loadState, setLoadState] = useState<'loading' | 'loaded' | 'error'>(
    'loading',
  );
  const [fullscreenOpen, setFullscreenOpen] = useState(false);

  if (loadState === 'error') {
    return (
      <View
        style={{
          width: 200,
          padding: fortuneTheme.spacing.sm,
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderRadius: fortuneTheme.radius.card,
        }}
      >
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          어 사진 안 갔다… 다시 보낼게
        </AppText>
      </View>
    );
  }

  return (
    <View style={{ gap: 4 }}>
      <Pressable
        onPress={() => setFullscreenOpen(true)}
        accessibilityRole="imagebutton"
        accessibilityLabel="사진 크게 보기"
      >
        <View
          style={{
            width: 200,
            height: 200,
            borderRadius: fortuneTheme.radius.card,
            overflow: 'hidden',
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
          }}
        >
          <Image
            source={{ uri: imageUrl }}
            style={{ width: '100%', height: '100%' }}
            resizeMode="cover"
            onLoadStart={() => setLoadState('loading')}
            onLoad={() => setLoadState('loaded')}
            onError={() => setLoadState('error')}
          />
          {loadState === 'loading' ? (
            <View
              style={{
                position: 'absolute',
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <ActivityIndicator
                size="small"
                color={fortuneTheme.colors.textSecondary}
              />
            </View>
          ) : null}
        </View>
      </Pressable>
      {caption ? (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {caption}
        </AppText>
      ) : null}

      <Modal
        visible={fullscreenOpen}
        transparent
        animationType="fade"
        onRequestClose={() => setFullscreenOpen(false)}
      >
        <Pressable
          style={{
            flex: 1,
            backgroundColor: 'rgba(0,0,0,0.92)',
            justifyContent: 'center',
            alignItems: 'center',
          }}
          onPress={() => setFullscreenOpen(false)}
          accessibilityRole="button"
          accessibilityLabel="닫기"
        >
          <ScrollView
            maximumZoomScale={4}
            minimumZoomScale={1}
            contentContainerStyle={{
              flexGrow: 1,
              justifyContent: 'center',
              alignItems: 'center',
            }}
            style={{ flex: 1, width: '100%' }}
          >
            <Image
              source={{ uri: imageUrl }}
              style={{ width: '100%', aspectRatio: 1 }}
              resizeMode="contain"
            />
          </ScrollView>
        </Pressable>
      </Modal>
    </View>
  );
}

function ChatThreadMessage({
  character,
  message,
  showProactiveCaption,
  onDeleteUserMessage,
  ttsControllerStatus,
  ttsActiveMessageId,
  ttsError,
  onPlayTts,
  onStopTts,
  onSelectFortuneMenuEntry,
}: {
  character: ChatCharacterSpec;
  message: ChatShellMessage;
  /** Slice 2: 연속된 proactive run 의 첫 메시지일 때만 true → "먼저 톡 보냄" 캡션 표시. */
  showProactiveCaption?: boolean;
  /** 본인이 보낸 텍스트 메시지를 길게 눌러 삭제할 수 있게 하는 핸들러. */
  onDeleteUserMessage?: (messageId: string) => void;
  /** TTS controller 상태 — assistant text 메시지 아래 SpeakerButton 표시용. */
  ttsControllerStatus?: import('../../lib/use-text-to-speech').TtsStatus;
  ttsActiveMessageId?: string | null;
  ttsError?: import('../../lib/use-text-to-speech').TtsErrorState | null;
  onPlayTts?: (args: { messageId: string; text: string; emotion?: string }) => void;
  onStopTts?: () => void;
  /** PR-B2: 운세 메뉴 카드 entry 탭 시 호출. chat-screen 이 cost modal 띄움. */
  onSelectFortuneMenuEntry?: (entry: import('@fortune/product-contracts').FortuneCatalogEntry) => void;
}) {
  const isUser = message.sender === 'user';
  const isFullWidth =
    message.kind === 'embedded-result' ||
    message.kind === 'fortune-cookie' ||
    message.kind === 'saju-preview' ||
    message.kind === 'story-reveal' ||
    message.kind === 'my-saju-context' ||
    message.kind === 'progress';
  const isImage = message.kind === 'image';

  // Apple 5.2.3 — assistant 텍스트 메시지 long-press로 신고 시트 오픈.
  // text 이외 타입(결과 카드/서베이/사주 프리뷰 등)은 시스템-생성 혹은 위젯이라
  // 신고 대상이 아님. 사용자 본인의 발화도 신고 불필요.
  const reportable =
    message.kind === 'text' &&
    message.sender === 'assistant' &&
    message.text?.trim().length > 0;
  // assistant 텍스트 응답은 음성 재생 가능. 카드/이미지/사주 프리뷰 등은 제외.
  const ttsPlayable =
    message.kind === 'text' &&
    message.sender === 'assistant' &&
    message.text?.trim().length > 0 &&
    typeof onPlayTts === 'function' &&
    typeof onStopTts === 'function';
  // 본인이 보낸 텍스트 메시지는 길게 눌러 삭제 옵션 노출.
  const userDeletable =
    message.kind === 'text' &&
    message.sender === 'user' &&
    typeof onDeleteUserMessage === 'function';
  const [reportOpen, setReportOpen] = useState(false);

  const handleUserLongPress = () => {
    if (!userDeletable) return;
    Alert.alert(
      '메시지',
      '이 메시지를 삭제할까요?',
      [
        { text: '취소', style: 'cancel' },
        {
          text: '삭제',
          style: 'destructive',
          onPress: () => onDeleteUserMessage?.(message.id),
        },
      ],
      { cancelable: true },
    );
  };

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
    if (message.kind === 'progress')
      return (
        <View style={{ width: '100%' }}>
          <ProgressMessageCard message={message} characterId={character.id} />
        </View>
      );
    if (isImage)
      return (
        <ProactiveImageBubble
          imageUrl={message.imageUrl}
          caption={message.caption}
        />
      );
    return (
      <MessageBubble
        message={message}
        useOracleVoice={isFortuneChatCharacter(character)}
      />
    );
  })();

  // Slice 2: proactive 첫 메시지에 "먼저 톡 보냄 · HH:MM" 1-line 캡션.
  // PROACTIVE_MESSAGING_PLAN.md Slice 2 §2.2.7 (A7).
  const proactiveMeta = (message.kind === 'text' || message.kind === 'image')
    ? (message as ChatShellTextMessage | ChatShellImageMessage).proactive
    : undefined;
  const proactiveCaptionLabel = (() => {
    if (!showProactiveCaption || !proactiveMeta?.generatedAt) return null;
    const ts = Date.parse(proactiveMeta.generatedAt);
    if (Number.isNaN(ts)) return '먼저 톡 보냄';
    const d = new Date(ts);
    const hh = String(d.getHours()).padStart(2, '0');
    const mm = String(d.getMinutes()).padStart(2, '0');
    return `먼저 톡 보냄 · ${hh}:${mm}`;
  })();

  return (
    <View style={{ width: '100%' }}>
      {proactiveCaptionLabel ? (
        <AppText
          variant="bodySmall"
          color={fortuneTheme.colors.textTertiary}
          style={{ marginBottom: 4, marginLeft: 8 }}
        >
          {proactiveCaptionLabel}
        </AppText>
      ) : null}
      <View style={{ width: isFullWidth ? '100%' : undefined }}>
        {reportable ? (
          // alignSelf flex-start — assistant 메시지는 좌측 정렬. Pressable 이
          // 100% 폭 stretch 되면 우측 빈 공간 탭이 long-press Pressable 에 잡혀
          // keyboard.dismiss 가 안 됨. 버블 폭 (maxWidth 86%) 만큼만 차지.
          <Pressable
            style={{ alignSelf: 'flex-start' }}
            onLongPress={() => setReportOpen(true)}
            // delayLongPress 기본 500ms — 스크롤 오작동 최소화
            android_ripple={null}
            accessibilityRole="button"
            accessibilityLabel="메시지 길게 눌러 신고"
          >
            {bubble}
          </Pressable>
        ) : userDeletable ? (
          // user 메시지는 우측 정렬. 좌측 빈 공간이 dismiss 영역.
          <Pressable
            style={{ alignSelf: 'flex-end' }}
            onLongPress={handleUserLongPress}
            android_ripple={null}
            accessibilityRole="button"
            accessibilityLabel="메시지 길게 눌러 삭제"
          >
            {bubble}
          </Pressable>
        ) : (
          bubble
        )}
      </View>

      {ttsPlayable ? (
        <SpeakerButton
          messageId={message.id}
          controllerStatus={ttsControllerStatus ?? 'idle'}
          controllerActiveMessageId={ttsActiveMessageId ?? null}
          controllerError={ttsError ?? null}
          onPress={() =>
            onPlayTts?.({
              messageId: message.id,
              text: (message as ChatShellTextMessage).text,
              emotion: (message as ChatShellTextMessage).emotionTag,
            })
          }
          onStop={() => onStopTts?.()}
        />
      ) : null}

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
  // 정렬은 호출자(chat-screen.tsx) 가 metaByCharacterId 의 unread/lastActivityAt
  // 으로 미리 끝낸 상태로 받는다. 여기서는 입력 순서를 그대로 보존.
  const visibleCharacters = Array.isArray(characters) ? characters : [];

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
  voiceVolume = 0,
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
  /** 0~1 정규화된 마이크 음량. recording 중에만 의미 있음. */
  voiceVolume?: number;
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
          {voiceRecording ? (
            <View
              style={{
                alignItems: 'center',
                flexDirection: 'row',
                minHeight: 28,
                paddingHorizontal: 4,
                paddingVertical: 6,
              }}
            >
              <VoiceWaveform
                color="#EF4444"
                height={20}
                volume={voiceVolume}
              />
            </View>
          ) : (
            <TextInput
              accessibilityLabel="chat composer"
              multiline
              onChangeText={onDraftChange}
              placeholder="메시지..."
              placeholderTextColor={fortuneTheme.colors.textTertiary}
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
          )}
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
        // 0.9 = 시각적 무손실에 가까우면서 base64 size 합리적 유지.
        quality: 0.9,
        base64: true,
        // iOS 기본 1:1 강제 크롭 비활성 (위아래 잘림 방지).
        // 손금/얼굴/전신 모두 원본 비율 유지 — Edge Function 이 알아서 처리.
        allowsEditing: false,
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

  if (step.inputKind === 'deck-picker') {
    // 비주얼 덱 picker — 2-열 그리드. 8개 덱이 viewport 보다 길어서 ScrollView 로 감싸 스크롤 가능.
    // Screen footer 슬롯은 height 제약이 없어서 ScrollView 가 content 만큼 늘어남 → maxHeight 로 viewport 기준 cap.
    // cover 이미지: assets/tarot-decks/{deck_id}/major/00_fool.webp.
    const deckPickerMaxHeight = Math.round(Dimensions.get('window').height * 0.6);
    return (
      <ScrollView
        style={{ maxHeight: deckPickerMaxHeight }}
        contentContainerStyle={{
          gap: fortuneTheme.spacing.sm,
          paddingBottom: fortuneTheme.spacing.lg,
        }}
        showsVerticalScrollIndicator={false}
      >
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          {(step.options ?? []).map((option) => {
            const cover = option.coverColors ?? {
              primary: '#1F1B4D',
              secondary: '#E0A76B',
            };
            const coverImage = getDeckCoverSource(option.id);
            return (
              <Pressable
                key={option.id}
                accessibilityRole="button"
                accessibilityLabel={option.label}
                onPress={() => onPickSingle(option.id)}
                style={({ pressed }) => ({
                  flexBasis: '48%',
                  flexGrow: 1,
                  borderRadius: fortuneTheme.radius.lg,
                  borderWidth: 1,
                  borderColor: cover.secondary,
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                  overflow: 'hidden',
                  opacity: pressed ? 0.84 : 1,
                })}
              >
                <View
                  style={{
                    height: 140,
                    backgroundColor: cover.primary,
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderBottomWidth: 1,
                    borderBottomColor: cover.secondary,
                  }}
                >
                  {coverImage ? (
                    <Image
                      source={coverImage}
                      style={{ width: 84, height: 124, borderRadius: 6 }}
                      resizeMode="cover"
                    />
                  ) : (
                    <View
                      style={{
                        width: 56,
                        height: 80,
                        borderRadius: 6,
                        borderWidth: 1.5,
                        borderColor: cover.secondary,
                        backgroundColor: 'rgba(0,0,0,0.25)',
                        alignItems: 'center',
                        justifyContent: 'center',
                      }}
                    >
                      <AppText variant="bodyLarge" color={cover.secondary}>
                        ✦
                      </AppText>
                    </View>
                  )}
                </View>
                <View style={{ padding: fortuneTheme.spacing.sm, gap: 2 }}>
                  <AppText
                    variant="labelLarge"
                    color={fortuneTheme.colors.textPrimary}
                    numberOfLines={1}
                  >
                    {option.label}
                  </AppText>
                  {option.description ? (
                    <AppText
                      variant="bodySmall"
                      color={fortuneTheme.colors.textSecondary}
                      numberOfLines={2}
                    >
                      {option.description}
                    </AppText>
                  ) : null}
                </View>
              </Pressable>
            );
          })}
        </View>
      </ScrollView>
    );
  }

  if (step.inputKind === 'date') {
    return (
      <SurveyDatePicker onSelect={(isoDate) => onPickSingle(isoDate)} />
    );
  }

  if (step.inputKind === 'card-draw') {
    // 8 덱 — supabase/functions/fortune-tarot/tarotCatalog.ts 매핑.
    const deckColorMap: Record<string, { primary: string; secondary: string; label: string }> = {
      rider_waite: { primary: '#1F1B4D', secondary: '#E0A76B', label: '라이더-웨이트' },
      thoth: { primary: '#311B5E', secondary: '#A78BFA', label: '토트' },
      ancient_italian: { primary: '#5C2A1B', secondary: '#FBBF24', label: '고대 이탈리아' },
      before_tarot: { primary: '#0F3D3E', secondary: '#22D3EE', label: '비포' },
      after_tarot: { primary: '#3D0F2E', secondary: '#EC4899', label: '애프터' },
      golden_dawn_cicero: { primary: '#3F3000', secondary: '#FFD700', label: '골든 던 매지컬' },
      golden_dawn_wang: { primary: '#1A2B4D', secondary: '#60A5FA', label: '골든 던' },
      grand_etteilla: { primary: '#3A1F1F', secondary: '#DC2626', label: '그랑 에테이야' },
    };
    const selectedDeckId = typeof surveyAnswers?.deckId === 'string' ? surveyAnswers.deckId : 'rider_waite';
    const deck = deckColorMap[selectedDeckId] ?? deckColorMap.rider_waite;
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

/**
 * Story 캐릭터의 상황극(worldview) 설정을 채팅방 진입 시점에 사용자에게 노출.
 *
 * 이전엔 worldview 가 `프로필 보기` 안쪽에만 있어서, 사용자가 인트로
 * 메시지("...이서준입니다.") 만 보고 들어와 LLM 답변에 당황 ("회사 OJT
 * 사수와의..." 같은 컨텍스트에 "이게 뭐지?"). 채팅방 상단에 항상 표시되는
 * 상황 카드로 사용자가 들어가는 세계 + 자신의 역할 + 톤 (태그) 을 한눈에
 * 파악하게 한다.
 *
 * Fortune 캐릭터는 상황극 없이 점성/사주 카운슬링이라 worldview 가 비어
 * 있는데, 그 경우 카드 자체를 안 그린다.
 */
function ScenarioCard({ character }: { character: ChatCharacterSpec }) {
  const [expanded, setExpanded] = useState(true);
  const detail = characterDetails[character.id];
  if (!detail || !detail.worldview || detail.worldview.trim().length === 0) {
    return null;
  }
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityLabel={
        expanded ? '상황 설명 접기' : '상황 설명 펼치기'
      }
      onPress={() => setExpanded((v) => !v)}
      style={({ pressed }) => ({
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.card,
        borderWidth: 1,
        opacity: pressed ? 0.85 : 1,
        paddingHorizontal: 14,
        paddingVertical: 12,
      })}
    >
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          gap: 6,
          marginBottom: expanded ? 8 : 0,
        }}
      >
        <Ionicons
          color={fortuneTheme.colors.textSecondary}
          name="book-outline"
          size={14}
        />
        <AppText
          variant="caption"
          color={fortuneTheme.colors.textSecondary}
          style={{ fontWeight: '700', flex: 1 }}
        >
          상황 설정
        </AppText>
        <Ionicons
          color={fortuneTheme.colors.textTertiary}
          name={expanded ? 'chevron-up' : 'chevron-down'}
          size={14}
        />
      </View>
      {expanded ? (
        <>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            style={{ lineHeight: 20 }}
          >
            {detail.worldview}
          </AppText>
          {detail.tags.length > 0 ? (
            <View
              style={{
                flexDirection: 'row',
                flexWrap: 'wrap',
                gap: 6,
                marginTop: 10,
              }}
            >
              {detail.tags.map((tag) => (
                <View
                  key={tag}
                  style={{
                    backgroundColor: fortuneTheme.colors.accentSubtle,
                    borderRadius: 999,
                    paddingHorizontal: 8,
                    paddingVertical: 3,
                  }}
                >
                  <AppText
                    variant="caption"
                    color={fortuneTheme.colors.textTertiary}
                  >
                    #{tag}
                  </AppText>
                </View>
              ))}
            </View>
          ) : null}
        </>
      ) : null}
    </Pressable>
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
  onDeleteUserMessage,
  ttsControllerStatus,
  ttsActiveMessageId,
  ttsError,
  onPlayTts,
  onStopTts,
  showHeader = true,
  romanceScore = 0,
  presenceLine,
  onSelectFortuneMenuEntry,
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
  /**
   * 본인 텍스트 메시지를 길게 눌러 삭제하는 핸들러. 미지정이면 길게 눌러도
   * 메뉴가 안 뜬다 (chat-screen 외 다른 surface 에선 의도적으로 비활성).
   */
  onDeleteUserMessage?: (messageId: string) => void;
  /** TTS controller — assistant text 메시지 아래 SpeakerButton 표시 + 재생/정지. */
  ttsControllerStatus?: import('../../lib/use-text-to-speech').TtsStatus;
  ttsActiveMessageId?: string | null;
  ttsError?: import('../../lib/use-text-to-speech').TtsErrorState | null;
  onPlayTts?: (args: { messageId: string; text: string; emotion?: string }) => void;
  onStopTts?: () => void;
  showHeader?: boolean;
  romanceScore?: number;
  /**
   * 카톡식 프레전스 라인 ("커피 내리는 중", "네 생각 중..." 등).
   * 비어있거나 undefined면 기존 `shortDescription`으로 폴백.
   */
  presenceLine?: string | null;
  /** PR-B2: 운세 메뉴 entry 탭 시 호출. chat-screen 이 cost modal 띄움. */
  onSelectFortuneMenuEntry?: (entry: import('@fortune/product-contracts').FortuneCatalogEntry) => void;
}) {
  // 메시지 순서 정렬 — 옛날엔 array index 그대로 렌더했는데, 빠른 연속 send +
  // 백그라운드 → 포어그라운드 hydrate (SecureStore + remote) 가 겹치면서 user
  // 메시지가 뒤늦게 array 끝에 append → DB 의 chronological 순서와 어긋남.
  // ID 에 unix-ms 가 내장 (`user-1778217138036-...`) 되어 있어서 그걸 추출해
  // ascending 정렬. 안전 — id 패턴 안 맞으면 array index 폴백 (sort stability).
  const visibleMessages = getCanonicalVisibleMessages(messages);
  const promptActions = actions;
  const hasEmbeddedResult = visibleMessages.some(
    (message) =>
      message.kind === 'embedded-result' ||
      message.kind === 'fortune-cookie' ||
      message.kind === 'saju-preview' ||
      message.kind === 'story-reveal',
  );
  // 진짜 메시지만 렌더 (placeholder 안 만든다).
  // 이전엔 user 메시지가 하나도 없을 때 3개의 가짜 메시지(가상 인트로 + 가상
  // 유저 프롬프트 + 가상 AI 응답)를 그려 "이미 대화 중인 듯" 한 느낌을 줬는데,
  // 사용자가 실제 메시지 한 통이라도 보내는 순간 이 placeholder 들이 통째로
  // 사라지고 진짜 메시지만 남으면서 "방금 보였던 기존 메시지가 사라졌다" 는
  // 체감 회귀를 일으켰다 (실제로는 placeholder 였음). 카톡/iMessage 같은
  // 메신저들도 이런 placeholder 를 쓰지 않으니 동일하게 진짜 메시지만 표시.
  // 빈 상태에서도 chat-screen useState 초기화에서 캐릭터 인트로 1개 (story
  // 캐릭터의 경우 buildPilotStoryInitialThread) 가 들어 있어 화면이 비지
  // 않는다.
  const previewMessages = visibleMessages;

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

      <ScenarioCard character={character} />

      <View style={{ gap: fortuneTheme.spacing.sm }}>
        {previewMessages.map((message, idx) => {
          // Slice 2: 연속된 proactive run 의 첫 메시지에만 "먼저 톡 보냄" 캡션 표시.
          // 이전 메시지가 proactive 가 아니거나 user 메시지면 첫 run 시작.
          const prev = idx > 0 ? previewMessages[idx - 1] : null;
          const messageHasProactive =
            (message.kind === 'text' || message.kind === 'image') &&
            'proactive' in message &&
            message.proactive != null;
          const prevHasProactive =
            prev != null &&
            (prev.kind === 'text' || prev.kind === 'image') &&
            'proactive' in prev &&
            prev.proactive != null &&
            prev.sender === 'assistant';
          const showProactiveCaption =
            messageHasProactive && !prevHasProactive;
          return (
            <ChatThreadMessage
              key={message.id}
              character={character}
              message={message}
              showProactiveCaption={showProactiveCaption}
              onDeleteUserMessage={onDeleteUserMessage}
              ttsControllerStatus={ttsControllerStatus}
              ttsActiveMessageId={ttsActiveMessageId}
              ttsError={ttsError}
              onPlayTts={onPlayTts}
              onStopTts={onStopTts}
            />
          );
        })}
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
          accessibilityLabel="뒤로 가기"
          onPress={onBack}
          // 22pt 아이콘을 raw 로 감싸면 터치 영역이 22x22 라 백버튼이 잘 안
          // 눌린다는 보고 다수. Apple HIG 최소 44x44pt 보장 위해 hitSlop +
          // padding 으로 터치 박스 확장. padding 은 시각적 위치 변화를 막기
          // 위해 음수 margin 으로 offset 처리하지 않고, 헤더가 row 컨테이너라
          // 자연스럽게 옆으로만 살짝 늘어나도록 둔다.
          hitSlop={{ top: 16, bottom: 16, left: 16, right: 16 }}
          style={({ pressed }) => ({
            opacity: pressed ? 0.6 : 1,
            padding: 8,
          })}
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
                  : 'AI 스토리 캐릭터 · 관계를 이어보세요'}
            </AppText>
          </View>
        </View>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="캐릭터 프로필 보기"
          onPress={onOpenProfile}
          hitSlop={{ top: 16, bottom: 16, left: 16, right: 16 }}
          style={({ pressed }) => ({
            opacity: pressed ? 0.6 : 1,
            padding: 8,
          })}
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
