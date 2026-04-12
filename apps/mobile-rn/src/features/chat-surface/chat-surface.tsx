import { useState, useEffect, useRef, useCallback, type PropsWithChildren, type ReactNode } from 'react';

import { Ionicons } from '@expo/vector-icons';
import * as ImagePicker from 'expo-image-picker';
import { Animated, Image, PanResponder, Pressable, TextInput, View } from 'react-native';

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
import { fortuneTheme } from '../../lib/theme';
import { EmbeddedResultCard } from '../chat-results/embedded-result-card';
import { FortuneCookieCard } from '../fortune-cookie/fortune-cookie-card';
import { SajuPreviewCard } from '../fortune-cookie/saju-preview-card';
import type { ChatSurveyStep } from '../chat-survey/types';
import { TarotDrawWidget } from '../chat-survey/tarot-draw-widget';

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
      <Pressable
        accessibilityRole="button"
        onPress={() => onChangeTab('fortune')}
        style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
      >
        <Chip
          label="운세보기"
          tone={activeTab === 'fortune' ? 'accent' : 'neutral'}
        />
      </Pressable>
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

function CharacterListRow({
  character,
  badge,
  onPress,
  onDelete,
  onPickAction,
  optionActions = [],
  selected = false,
}: {
  character: ChatCharacterSpec;
  badge?: string;
  onPress: () => void;
  onDelete?: () => void;
  onPickAction?: (fortuneType: FortuneTypeId) => void;
  optionActions?: readonly ChatShellAction[];
  selected?: boolean;
}) {
  const swipeX = useRef(new Animated.Value(0)).current;
  const DELETE_THRESHOLD = -80;

  const panResponder = useRef(
    onDelete
      ? PanResponder.create({
          onMoveShouldSetPanResponder: (_, gesture) =>
            Math.abs(gesture.dx) > 10 && Math.abs(gesture.dy) < 20,
          onPanResponderMove: (_, gesture) => {
            if (gesture.dx < 0) {
              swipeX.setValue(Math.max(gesture.dx, -120));
            }
          },
          onPanResponderRelease: (_, gesture) => {
            if (gesture.dx < DELETE_THRESHOLD) {
              Animated.spring(swipeX, { toValue: -100, useNativeDriver: true }).start();
            } else {
              Animated.spring(swipeX, { toValue: 0, useNativeDriver: true }).start();
            }
          },
        })
      : null,
  ).current;

  const cardContent = (
    <View
      style={{
        backgroundColor: selected
          ? fortuneTheme.colors.backgroundTertiary
          : fortuneTheme.colors.surfaceSecondary,
        borderColor: selected
          ? fortuneTheme.colors.accentTertiary
          : fortuneTheme.colors.border,
        borderRadius: fortuneTheme.radius.lg,
        borderWidth: 1,
        gap: optionActions.length > 0 ? fortuneTheme.spacing.sm : 0,
        paddingHorizontal: fortuneTheme.spacing.md,
        paddingVertical: fortuneTheme.spacing.sm,
      }}
    >
      <Pressable
        accessibilityRole="button"
        onPress={() => { confirmAction(); onPress(); }}
        style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
      >
        <View
          style={{
            alignItems: 'center',
            flexDirection: 'row',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <CharacterAvatar characterId={character.id} name={character.name} />
          <View style={{ flex: 1, gap: 2 }}>
            <AppText variant="labelLarge">{character.name}</AppText>
            <AppText
              numberOfLines={optionActions.length > 0 ? 2 : 1}
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
            >
              {character.shortDescription}
            </AppText>
          </View>
          {badge ? <Chip label={badge} tone="neutral" /> : null}
        </View>
      </Pressable>

      {optionActions.length > 0 && onPickAction ? (
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: 8,
            paddingLeft: 56,
          }}
        >
          {optionActions.map((action, index) => (
            <Pressable
              key={action.id}
              accessibilityRole="button"
              onPress={() => onPickAction(action.fortuneType)}
              style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
            >
              <Chip
                label={action.label}
                tone={
                  selected && index === 0
                    ? 'accent'
                    : index % 3 === 0
                      ? 'success'
                      : 'neutral'
                }
              />
            </Pressable>
          ))}
        </View>
      ) : null}
    </View>
  );

  if (!onDelete) {
    return cardContent;
  }

  return (
    <View style={{ overflow: 'hidden', borderRadius: fortuneTheme.radius.lg }}>
      {/* Delete button behind */}
      <View
        style={{
          position: 'absolute',
          right: 0,
          top: 0,
          bottom: 0,
          width: 100,
          backgroundColor: fortuneTheme.colors.error,
          borderRadius: fortuneTheme.radius.lg,
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <Pressable onPress={onDelete} style={{ alignItems: 'center', padding: 12 }}>
          <Ionicons name="trash-outline" size={22} color="#FFFFFF" />
          <AppText variant="caption" color="#FFFFFF" style={{ marginTop: 2 }}>
            삭제
          </AppText>
        </Pressable>
      </View>
      {/* Swipeable card */}
      <Animated.View
        style={{ transform: [{ translateX: swipeX }] }}
        {...(panResponder?.panHandlers ?? {})}
      >
        {cardContent}
      </Animated.View>
    </View>
  );
}

function MessageBubble({ message }: { message: ChatShellTextMessage }) {
  const isAssistant = message.sender === 'assistant';
  const isSystem = message.sender === 'system';
  const isUser = message.sender === 'user';

  return (
    <View
      style={{
        alignItems: isAssistant || isSystem ? 'flex-start' : 'flex-end',
      }}
    >
      <View
        style={{
          backgroundColor:
            isAssistant || isSystem
              ? fortuneTheme.colors.backgroundTertiary
              : fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.messageBubble,
          borderWidth: 1,
          maxWidth: isUser ? undefined : '84%',
          paddingHorizontal: 14,
          paddingVertical: 10,
        }}
      >
        <AppText
          variant="bodyMedium"
          color={
            isSystem
              ? fortuneTheme.colors.textSecondary
              : fortuneTheme.colors.textPrimary
          }
        >
          {message.text}
        </AppText>
      </View>
    </View>
  );
}

function TypingIndicatorBubble({ character }: { character: ChatCharacterSpec }) {
  return (
    <View
      style={{
        alignItems: 'flex-start',
        flexDirection: 'row',
        gap: 8,
      }}
    >
      <View style={{ marginTop: 6 }}>
        <CharacterAvatar
          characterId={character.id}
          name={character.name}
          size={24}
        />
      </View>
      <View
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.messageBubble,
          borderWidth: 1,
          paddingHorizontal: 14,
          paddingVertical: 12,
        }}
      >
        <View style={{ flexDirection: 'row', gap: 5 }}>
          <PulseDot delay={0} />
          <PulseDot delay={200} />
          <PulseDot delay={400} />
        </View>
      </View>
    </View>
  );
}

function PulseDot({ delay }: { delay: number }) {
  const opacity = useRef(new Animated.Value(0.25)).current;

  useEffect(() => {
    const animation = Animated.loop(
      Animated.sequence([
        Animated.timing(opacity, { toValue: 1, duration: 500, delay, useNativeDriver: true }),
        Animated.timing(opacity, { toValue: 0.25, duration: 500, useNativeDriver: true }),
      ]),
    );
    animation.start();
    return () => animation.stop();
  }, [delay, opacity]);

  return (
    <Animated.View
      style={{
        width: 7,
        height: 7,
        borderRadius: 999,
        backgroundColor: fortuneTheme.colors.ctaBackground,
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
    message.kind === 'embedded-result' || message.kind === 'fortune-cookie' || message.kind === 'saju-preview';
  const showAssistantAvatar = !isUser && !isFullWidth;

  return (
    <View
      style={{
        alignItems: isUser ? 'flex-end' : 'flex-start',
        flexDirection: isUser ? 'row-reverse' : 'row',
        gap: showAssistantAvatar ? 8 : 0,
      }}
    >
      {showAssistantAvatar ? (
        <View style={{ marginTop: 6 }}>
          <CharacterAvatar
            characterId={character.id}
            name={character.name}
            size={24}
          />
        </View>
      ) : null}
      <View
        style={{
          flex: isUser ? undefined : isFullWidth ? undefined : 1,
          flexShrink: isUser ? 1 : isFullWidth ? 0 : undefined,
          maxWidth: isUser ? '84%' : '100%',
          width: isFullWidth ? '100%' : undefined,
        }}
      >
        {message.kind === 'embedded-result' ? (
          <EmbeddedResultMessage message={message} />
        ) : message.kind === 'fortune-cookie' ? (
          <View style={{ width: '100%' }}>
            <FortuneCookieCard />
          </View>
        ) : message.kind === 'saju-preview' ? (
          <View style={{ width: '100%' }}>
            <SajuPreviewCard
              data={message.sajuData as import('../../lib/saju-remote').SajuData}
              userName={message.userName}
            />
          </View>
        ) : (
          <MessageBubble message={message} />
        )}
      </View>
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
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {visibleCharacters.map((character) => (
            <CharacterListRow
              key={character.id}
              badge={character.id.startsWith('custom_') ? '내 친구' : '스토리'}
              character={character}
              onDelete={
                character.id.startsWith('custom_') && onDeleteFriend
                  ? () => onDeleteFriend(character.id)
                  : undefined
              }
              onPress={() => onSelectCharacter(character.id)}
              selected={character.id === selectedCharacterId}
            />
          ))}
        </View>
      ) : (
        <View style={{ gap: fortuneTheme.spacing.md }}>
          <View
            style={{
              alignItems: 'center',
              flexDirection: 'row',
              justifyContent: 'space-between',
              gap: fortuneTheme.spacing.sm,
              paddingHorizontal: 4,
            }}
          >
            <View style={{ flex: 1, gap: 4 }}>
              <AppText variant="heading4">최근 상담</AppText>
              <AppText
                variant="bodySmall"
                color={fortuneTheme.colors.textSecondary}
              >
                설문과 결과가 같은 채팅 안에서 이어지는 전문가 목록입니다.
              </AppText>
            </View>
            <Chip label="운세보기" tone="success" />
          </View>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
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
                badge={`${character.specialties.length}개 운세`}
                character={character}
                onPickAction={(fortuneType) =>
                  onPickCharacterAction(character.id, fortuneType)
                }
                onPress={() => onSelectCharacter(character.id)}
                optionActions={
                  isFortuneChatCharacter(character)
                    ? buildSuggestedActions(character)
                    : []
                }
                selected={character.id === selectedCharacterId}
              />
            ))}
          </View>
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
  onStartVoiceInput,
  quickActions,
  trayOpen,
  onToggleTray,
  onPickAction,
  auxiliaryAction,
  sendDisabled = false,
}: {
  draft: string;
  onDraftChange: (value: string) => void;
  onSend: () => void;
  onOpenPhotoPicker: () => void;
  onStartVoiceInput: () => void;
  quickActions: ChatShellAction[];
  trayOpen: boolean;
  onToggleTray: () => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
  auxiliaryAction?: {
    label: string;
    onPress: () => void;
  };
  sendDisabled?: boolean;
}) {
  const composerHasDraft = draft.trim().length > 0;
  const safeQuickActions = Array.isArray(quickActions) ? quickActions : [];
  const trayActions = safeQuickActions.slice(0, 12);

  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surfaceSecondary,
        borderColor: fortuneTheme.colors.border,
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
        </View>
        <Pressable
          accessibilityLabel={
            composerHasDraft ? 'send message' : 'start voice input'
          }
          accessibilityRole="button"
          accessibilityState={{ disabled: sendDisabled }}
          disabled={sendDisabled}
          onPress={
            sendDisabled
              ? undefined
              : composerHasDraft
                ? onSend
                : onStartVoiceInput
          }
          style={{
            alignItems: 'center',
            backgroundColor: composerHasDraft
              ? sendDisabled
                ? fortuneTheme.colors.surfaceElevated
                : fortuneTheme.colors.ctaBackground
              : fortuneTheme.colors.surfaceElevated,
            borderRadius: 16,
            height: 32,
            justifyContent: 'center',
            minWidth: 32,
            paddingHorizontal: composerHasDraft ? 10 : 0,
            opacity: sendDisabled ? 0.72 : 1,
          }}
        >
          {composerHasDraft ? (
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
          ) : (
            <Ionicons
              color={fortuneTheme.colors.textSecondary}
              name="mic-outline"
              size={18}
            />
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
  onBack,
  onOpenProfile,
  onPickAction,
  showHeader = true,
}: {
  character: ChatCharacterSpec;
  actions: ChatShellAction[];
  messages: ChatShellMessage[];
  surveyEyebrow?: string | null;
  surveyActive?: boolean;
  isTyping?: boolean;
  onBack: () => void;
  onOpenProfile: () => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
  showHeader?: boolean;
}) {
  const isFortuneCharacter = isFortuneChatCharacter(character);
  const visibleMessages = messages;
  const promptActions = actions;
  const hasEmbeddedResult = visibleMessages.some(
    (message) =>
      message.kind === 'embedded-result' || message.kind === 'fortune-cookie' || message.kind === 'saju-preview',
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

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
      {showHeader ? (
        <ActiveCharacterChatHeader
          character={character}
          onBack={onBack}
          onOpenProfile={onOpenProfile}
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
              {character.shortDescription}
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
          오늘 3:24
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
        {isTyping ? <TypingIndicatorBubble character={character} /> : null}
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
  onBack,
  onOpenProfile,
}: {
  character: ChatCharacterSpec;
  onBack: () => void;
  onOpenProfile: () => void;
}) {
  const isFortuneCharacter = isFortuneChatCharacter(character);

  return (
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
            {isFortuneCharacter
              ? '운세 상담사 · 대화를 이어보세요'
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
          출생 정보와 관심사를 마치면 채팅과 운세 흐름이 더 정확하게 이어집니다.
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
