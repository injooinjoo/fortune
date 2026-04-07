import type { PropsWithChildren, ReactNode } from 'react';

import { Pressable, TextInput, View } from 'react-native';

import type { FortuneTypeId } from '@fortune/product-contracts';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { Chip } from '../../components/chip';
import { PrimaryButton } from '../../components/primary-button';
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
import { formatFortuneTypeLabel } from '../../lib/chat-shell';
import { fortuneTheme } from '../../lib/theme';
import { EmbeddedResultCard } from '../chat-results/embedded-result-card';
import type { ChatSurveyStep } from '../chat-survey/types';

function CharacterAvatar({
  name,
  size = 48,
}: {
  name: string;
  size?: number;
}) {
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
        width: size,
      }}
    >
      <AppText variant={size >= 56 ? 'heading3' : 'labelLarge'}>
        {name.slice(0, 1)}
      </AppText>
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

function PagerDots() {
  return (
    <View
      style={{
        alignItems: 'center',
        flexDirection: 'row',
        gap: 12,
        justifyContent: 'center',
        paddingTop: fortuneTheme.spacing.xs,
      }}
    >
      {Array.from({ length: 5 }).map((_, index) => (
        <View
          key={index}
          style={{
            backgroundColor:
              index === 0
                ? 'rgba(255,255,255,0.94)'
                : fortuneTheme.colors.surfaceSecondary,
            borderRadius: 999,
            height: 10,
            width: 10,
          }}
        />
      ))}
    </View>
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
  selected = false,
}: {
  character: ChatCharacterSpec;
  badge?: string;
  onPress: () => void;
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
          paddingHorizontal: fortuneTheme.spacing.md,
          paddingVertical: fortuneTheme.spacing.sm,
        }}
      >
        <CharacterAvatar name={character.name} />
        <View style={{ flex: 1, gap: 2 }}>
          <AppText variant="labelLarge">{character.name}</AppText>
          <AppText
            numberOfLines={1}
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
          >
            {character.shortDescription}
          </AppText>
        </View>
        {badge ? (
          <Chip
            label={badge}
            tone={badge === '전문가' ? 'success' : 'neutral'}
          />
        ) : null}
      </View>
    </Pressable>
  );
}

function MessageBubble({ message }: { message: ChatShellTextMessage }) {
  const isAssistant = message.sender === 'assistant';
  const isSystem = message.sender === 'system';

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
          maxWidth: '84%',
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
      <View
        style={{
          alignItems: 'center',
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderRadius: 12,
          height: 24,
          justifyContent: 'center',
          marginTop: 6,
          width: 24,
        }}
      >
        <AppText variant="caption">{character.name.slice(0, 1)}</AppText>
      </View>
      <View
        style={{
          backgroundColor: fortuneTheme.colors.backgroundTertiary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.messageBubble,
          borderWidth: 1,
          maxWidth: '84%',
          paddingHorizontal: 14,
          paddingVertical: 10,
        }}
      >
        <View style={{ flexDirection: 'row', gap: 4, marginBottom: 4 }}>
          {Array.from({ length: 3 }).map((_, index) => (
            <View
              key={index}
              style={{
                backgroundColor: fortuneTheme.colors.textSecondary,
                borderRadius: 999,
                height: 6,
                opacity: 0.7 - index * 0.15,
                width: 6,
              }}
            />
          ))}
        </View>
        <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
          답장하는 중
        </AppText>
      </View>
    </View>
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
  const isEmbeddedResult = message.kind === 'embedded-result';
  const showAssistantAvatar = !isUser && !isEmbeddedResult;

  return (
    <View
      style={{
        alignItems: isUser ? 'flex-end' : 'flex-start',
        flexDirection: isUser ? 'row-reverse' : 'row',
        gap: showAssistantAvatar ? 8 : 0,
      }}
    >
      {showAssistantAvatar ? (
        <View
          style={{
            alignItems: 'center',
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: 12,
            height: 24,
            justifyContent: 'center',
            marginTop: 6,
            width: 24,
          }}
        >
          <AppText variant="caption">{character.name.slice(0, 1)}</AppText>
        </View>
      ) : null}
      <View
        style={{
          flex: isUser || isEmbeddedResult ? 0 : 1,
          maxWidth: isUser ? '84%' : '100%',
          width: isEmbeddedResult ? '100%' : undefined,
        }}
      >
        {message.kind === 'embedded-result' ? (
          <EmbeddedResultMessage message={message} />
        ) : (
          <MessageBubble message={message} />
        )}
      </View>
    </View>
  );
}

function SocialActionButton({
  label,
  tone,
  onPress,
}: {
  label: string;
  tone: 'light' | 'dark';
  onPress: () => void;
}) {
  return (
    <Pressable
      accessibilityRole="button"
      onPress={onPress}
      style={({ pressed }) => ({
        backgroundColor:
          tone === 'light'
            ? fortuneTheme.colors.textPrimary
            : fortuneTheme.colors.surfaceSecondary,
        borderColor:
          tone === 'light'
            ? 'transparent'
            : fortuneTheme.colors.borderOpaque,
        borderRadius: fortuneTheme.radius.full,
        borderWidth: 1,
        opacity: pressed ? 0.84 : 1,
        paddingHorizontal: 18,
        paddingVertical: 15,
      })}
    >
      <AppText
        variant="labelLarge"
        color={
          tone === 'light'
            ? fortuneTheme.colors.background
            : fortuneTheme.colors.textPrimary
        }
        style={{ textAlign: 'center' }}
      >
        {label}
      </AppText>
    </Pressable>
  );
}

export function ChatSoftGate({
  onApple,
  onGoogle,
  onBrowse,
  authMessage,
  onKakao,
  onNaver,
}: {
  onApple: () => void;
  onGoogle: () => void;
  onBrowse: () => void;
  authMessage?: string | null;
  onKakao?: () => void;
  onNaver?: () => void;
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
            먼저 둘러보고{'\n'}필요할 때 이어가세요
          </AppText>
          <AppText
            variant="bodyLarge"
            color={fortuneTheme.colors.textSecondary}
            style={{ maxWidth: 290 }}
          >
            로그인하면 저장과 개인화가 바로 이어지고, 지금은 둘러보기로 가볍게
            시작할 수 있어요.
          </AppText>
        </View>

        <Card
          style={{
            marginTop: 96,
            paddingBottom: fortuneTheme.spacing.lg,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
            계정을 연결하면
          </AppText>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            <SocialActionButton
              label="Apple로 계속하기"
              tone="light"
              onPress={onApple}
            />
            <SocialActionButton
              label="Google로 계속하기"
              tone="dark"
              onPress={onGoogle}
            />
            {onKakao ? (
              <SocialActionButton
                label="Kakao로 계속하기"
                tone="dark"
                onPress={onKakao}
              />
            ) : null}
            {onNaver ? (
              <SocialActionButton
                label="Naver로 계속하기"
                tone="dark"
                onPress={onNaver}
              />
            ) : null}
          </View>
          <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
            계속 진행하면 이용약관 및 개인정보처리방침에 동의한 것으로 간주됩니다.
          </AppText>
          {authMessage ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
              {authMessage}
            </AppText>
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
              둘러보기
            </AppText>
          </Pressable>
        </Card>
      </View>
    </View>
  );
}

export function ChatFirstRunSurface({
  activeTab,
  featuredCharacter,
  actions,
  characters,
  lastFortuneType,
  selectedCharacterId,
  onChangeTab,
  onCreateFriend,
  onOpenProfile,
  onOpenRecentResult,
  onSelectCharacter,
  onPickAction,
}: {
  activeTab: ChatCharacterTab;
  featuredCharacter: ChatCharacterSpec;
  actions: ChatShellAction[];
  characters: readonly ChatCharacterSpec[];
  lastFortuneType: FortuneTypeId | null;
  selectedCharacterId: string | null;
  onChangeTab: (tab: ChatCharacterTab) => void;
  onCreateFriend: () => void;
  onOpenProfile: () => void;
  onOpenRecentResult: (fortuneType: FortuneTypeId) => void;
  onSelectCharacter: (characterId: string) => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
}) {
  const safeActions = Array.isArray(actions) ? actions : [];
  const safeCharacters = Array.isArray(characters) ? characters : [];
  const spotlightCharacter = featuredCharacter ?? safeCharacters[0];
  const primaryAction = safeActions[0];
  const secondaryActions = safeActions.slice(1, 3);
  const orderedActions = [
    secondaryActions[0],
    primaryAction,
    secondaryActions[1],
  ].filter(Boolean) as ChatShellAction[];
  const orderedCharacters = [
    ...safeCharacters.filter((character) => character.id === selectedCharacterId),
    ...safeCharacters.filter((character) => character.id !== selectedCharacterId),
  ];
  const visibleCharacters =
    activeTab === 'story' ? orderedCharacters : orderedCharacters.slice(0, 4);

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

      {activeTab === 'fortune' ? (
        <Card>
          <View style={{ gap: fortuneTheme.spacing.xs }}>
            <AppText variant="heading4">맞춤 시작점</AppText>
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
            >
              {`${spotlightCharacter?.name ?? '상담사'} 기준 추천 흐름으로 같은 채팅 안에서 설문과 결과를 바로 이어갈 수 있습니다.`}
            </AppText>
          </View>
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            {orderedActions.map((action, index) =>
              index === 1 ? (
                <Pressable
                  key={action.id}
                  accessibilityRole="button"
                  onPress={() => onPickAction(action.fortuneType)}
                  style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
                >
                  <View
                    style={{
                      backgroundColor: fortuneTheme.colors.backgroundTertiary,
                      borderRadius: fortuneTheme.radius.lg,
                      padding: fortuneTheme.spacing.md,
                      gap: fortuneTheme.spacing.xs,
                    }}
                  >
                    <AppText
                      variant="labelLarge"
                      color={fortuneTheme.colors.textTertiary}
                    >
                      오늘 함께 풀어갈 운세
                    </AppText>
                    <View
                      style={{
                        alignItems: 'center',
                        flexDirection: 'row',
                        justifyContent: 'space-between',
                        gap: fortuneTheme.spacing.sm,
                      }}
                    >
                      <View style={{ flex: 1, gap: 4 }}>
                        <AppText variant="heading4">{action.label}</AppText>
                        <AppText
                          variant="bodySmall"
                          color={fortuneTheme.colors.textSecondary}
                        >
                          {spotlightCharacter?.name ?? '상담사'}와 바로 이어서 볼 수 있어요.
                        </AppText>
                      </View>
                      <Chip label="전문가" tone="success" />
                    </View>
                  </View>
                </Pressable>
              ) : (
                <EntryActionRow
                  key={action.id}
                  title={action.label}
                  subtitle={action.reply}
                  badge="전문가"
                  onPress={() => onPickAction(action.fortuneType)}
                  tone="neutral"
                />
              ),
            )}
          </View>
        </Card>
      ) : null}

      {activeTab === 'story' ? (
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {visibleCharacters.map((character) => (
            <CharacterListRow
              key={character.id}
              badge="스토리"
              character={character}
              onPress={() => onSelectCharacter(character.id)}
              selected={character.id === selectedCharacterId}
            />
          ))}
        </View>
      ) : (
        <>
          <Card>
            <View
              style={{
                alignItems: 'center',
                flexDirection: 'row',
                justifyContent: 'space-between',
                gap: fortuneTheme.spacing.sm,
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
                  badge="전문가"
                  character={character}
                  onPress={() => onSelectCharacter(character.id)}
                  selected={character.id === selectedCharacterId}
                />
              ))}
            </View>
          </Card>

          <PagerDots />
        </>
      )}

    </View>
  );
}

export function ActiveChatComposer({
  draft,
  onDraftChange,
  onSend,
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
            바로 이어갈 액션
          </AppText>
          <View
            style={{
              flexDirection: 'row',
              flexWrap: 'wrap',
              gap: 8,
            }}
          >
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
            composerHasDraft ? 'send message' : 'run primary quick action'
          }
          accessibilityRole="button"
          accessibilityState={{ disabled: sendDisabled }}
          disabled={sendDisabled}
          onPress={sendDisabled ? undefined : onSend}
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
            <View
              style={{
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <View
                style={{
                  borderColor: fortuneTheme.colors.textSecondary,
                  borderRadius: 999,
                  borderWidth: 1.5,
                  height: 11,
                  width: 11,
                }}
              />
              <View
                style={{
                  backgroundColor: fortuneTheme.colors.textSecondary,
                  borderRadius: 999,
                  height: 3,
                  position: 'absolute',
                  width: 3,
                }}
              />
            </View>
          )}
        </Pressable>
      </View>
    </View>
  );
}

function formatDateLabel(offset: number) {
  const target = new Date();
  target.setDate(target.getDate() + offset);

  const month = target.getMonth() + 1;
  const day = target.getDate();

  if (offset === 0) {
    return `오늘 ${month}/${day}`;
  }

  if (offset === 1) {
    return `내일 ${month}/${day}`;
  }

  return `${month}/${day}`;
}

function buildDateAnswer(offset: number) {
  const target = new Date();
  target.setDate(target.getDate() + offset);

  return `${target.getFullYear()}-${String(target.getMonth() + 1).padStart(2, '0')}-${String(
    target.getDate(),
  ).padStart(2, '0')}`;
}

export function ActiveSurveyFooter({
  step,
  draft,
  selections,
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
      <View style={{ gap: fortuneTheme.spacing.sm }}>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {[0, 1, 2, 3, 4].map((offset) => (
            <Pressable
              key={offset}
              accessibilityRole="button"
              onPress={() => onPickSingle(buildDateAnswer(offset))}
              style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
            >
              <Chip label={formatDateLabel(offset)} tone="neutral" />
            </Pressable>
          ))}
        </View>
      </View>
    );
  }

  if (step.inputKind === 'multi-select' || step.inputKind === 'card-draw') {
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

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.inputArea,
          borderWidth: 1,
          paddingHorizontal: 12,
          paddingVertical: 10,
        }}
      >
        <TextInput
          multiline
          onChangeText={onDraftChange}
          placeholder={step.placeholder ?? '답변을 적어주세요.'}
          placeholderTextColor={fortuneTheme.colors.textTertiary}
          style={{
            color: fortuneTheme.colors.textPrimary,
            minHeight: 36,
            maxHeight: 120,
            textAlignVertical: 'top',
          }}
          value={draft}
        />
      </View>
      <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
        {step.inputKind === 'text-with-skip' ? (
          <PrimaryButton onPress={onSkip} tone="secondary">
            건너뛰기
          </PrimaryButton>
        ) : null}
        <PrimaryButton disabled={!canSubmitText} onPress={onSubmitText}>
          답변 보내기
        </PrimaryButton>
      </View>
    </View>
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
    (message) => message.kind === 'embedded-result',
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
          <CharacterAvatar name={character.name} size={72} />
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
        <AppText variant="heading4">‹</AppText>
      </Pressable>
      <View style={{ alignItems: 'center', flex: 1, gap: 2 }}>
        <AppText variant="labelLarge">{character.name}</AppText>
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
          {isFortuneCharacter
            ? '운세 상담사 · 대화를 이어보세요'
            : '스토리 캐릭터 · 관계를 이어보세요'}
        </AppText>
      </View>
      <Pressable
        accessibilityRole="button"
        onPress={onOpenProfile}
        style={({ pressed }) => ({ opacity: pressed ? 0.8 : 1 })}
      >
        <AppText variant="heading4">ⓘ</AppText>
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
          <AppText variant="heading4">온보딩 진행도</AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
          >
            남은 단계를 먼저 마무리해 주세요.
          </AppText>
        </View>
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`생년월일 ${birthCompleted ? '완료' : '필요'}`} tone={birthCompleted ? 'success' : 'neutral'} />
          <Chip label={`관심사 ${interestCompleted ? '완료' : '필요'}`} tone={interestCompleted ? 'success' : 'neutral'} />
          <Chip label={`첫 안내 ${firstRunHandoffSeen ? '완료' : '필요'}`} tone={firstRunHandoffSeen ? 'success' : 'neutral'} />
        </View>
        <PrimaryButton onPress={onContinue}>온보딩 계속하기</PrimaryButton>
      </Card>
    </View>
  );
}
