import type { PropsWithChildren, ReactNode } from 'react';

import { Pressable, TextInput, View } from 'react-native';

import type {
  FortuneCharacterSpec,
  FortuneTypeId,
} from '@fortune/product-contracts';

import { AppText } from '../../components/app-text';
import { Card } from '../../components/card';
import { Chip } from '../../components/chip';
import { PrimaryButton } from '../../components/primary-button';
import type {
  ChatShellAction,
  ChatShellMessage,
} from '../../lib/chat-shell';
import { formatFortuneTypeLabel } from '../../lib/chat-shell';
import { fortuneTheme } from '../../lib/theme';

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

function HeaderDots() {
  return (
    <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderRadius: 999,
          height: 18,
          width: 18,
        }}
      />
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderRadius: 999,
          height: 18,
          width: 18,
        }}
      />
    </View>
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

function SegmentedPills({ fortuneMode }: { fortuneMode: boolean }) {
  return (
    <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.xs }}>
      <View>
        <Chip label="스토리" tone={fortuneMode ? 'neutral' : 'accent'} />
      </View>
      <View>
        <Chip label="운세보기" tone={fortuneMode ? 'accent' : 'neutral'} />
      </View>
    </View>
  );
}

function EntryActionRow({
  title,
  subtitle,
  badge,
  onPress,
  tone = 'neutral',
}: {
  title: string;
  subtitle: string;
  badge?: string;
  onPress: () => void;
  tone?: 'neutral' | 'accent' | 'success';
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
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
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
  onPress,
}: {
  character: FortuneCharacterSpec;
  onPress: () => void;
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
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
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
      </View>
    </Pressable>
  );
}

function MessageBubble({ message }: { message: ChatShellMessage }) {
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

function SurfaceSection({
  title,
  description,
  children,
}: PropsWithChildren<{
  title: string;
  description?: string;
}>) {
  return (
    <Card>
      <View style={{ gap: fortuneTheme.spacing.xs }}>
        <AppText variant="heading4">{title}</AppText>
        {description ? (
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {description}
          </AppText>
        ) : null}
      </View>
      <View style={{ gap: fortuneTheme.spacing.sm }}>{children}</View>
    </Card>
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
}: {
  onApple: () => void;
  onGoogle: () => void;
  onBrowse: () => void;
  authMessage?: string | null;
}) {
  return (
    <View style={{ gap: fortuneTheme.spacing.lg }}>
      <View
        style={{
          borderRadius: 32,
          minHeight: 420,
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
          <Chip label="FIRST RUN / SOFT GATE" />
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
            <SocialActionButton label="Continue with Apple" tone="light" onPress={onApple} />
            <SocialActionButton label="Continue with Google" tone="dark" onPress={onGoogle} />
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
  featuredCharacter,
  actions,
  characters,
  onSelectCharacter,
  onPickAction,
}: {
  featuredCharacter: FortuneCharacterSpec;
  actions: ChatShellAction[];
  characters: readonly FortuneCharacterSpec[];
  onSelectCharacter: (characterId: string) => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
}) {
  const primaryAction = actions[0];
  const secondaryActions = actions.slice(1, 3);
  const orderedActions = [
    secondaryActions[0],
    primaryAction,
    secondaryActions[1],
  ].filter(Boolean) as ChatShellAction[];

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
          <SegmentedPills fortuneMode={false} />
        </View>
        <HeaderDots />
      </View>

      <SurfaceSection
        title="맞춤 시작점"
        description={`${featuredCharacter.name}의 추천 흐름을 기준으로 바로 대화를 시작할 수 있습니다.`}
      >
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
                <AppText variant="labelLarge" color={fortuneTheme.colors.textTertiary}>
                  오늘 함께 풀어갈 대화
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
                      {featuredCharacter.name}과 바로 이어서 볼 수 있어요.
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
              badge="스토리"
              onPress={() => onPickAction(action.fortuneType)}
              tone="neutral"
            />
          ),
        )}
      </SurfaceSection>

      <SurfaceSection title="상담사">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {characters.slice(0, 2).map((character) => (
            <CharacterListRow
              key={character.id}
              character={character}
              onPress={() => onSelectCharacter(character.id)}
            />
          ))}
        </View>
      </SurfaceSection>

      <PagerDots />
    </View>
  );
}

export function ActiveCharacterChatSurface({
  character,
  actions,
  messages,
  draft,
  onBack,
  onOpenProfile,
  onPickAction,
  onDraftChange,
  onSend,
}: {
  character: FortuneCharacterSpec;
  actions: ChatShellAction[];
  messages: ChatShellMessage[];
  draft: string;
  onBack: () => void;
  onOpenProfile: () => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
  onDraftChange: (value: string) => void;
  onSend: () => void;
}) {
  const composerHasDraft = draft.trim().length > 0;
  const visibleMessages = messages.slice(-4);
  const promptActions = actions.slice(0, 4);
  const previewMessages = visibleMessages.some((message) => message.sender === 'user')
    ? visibleMessages
    : [
        visibleMessages[0] ?? {
          id: `${character.id}-assistant-preview-1`,
          sender: 'assistant' as const,
          text: `안녕하세요! 오늘 ${character.name}의 흐름으로 먼저 볼까요?`,
        },
        {
          id: `${character.id}-user-preview`,
          sender: 'user' as const,
          text:
            promptActions[0]?.prompt ??
            `오늘 ${character.name}에게 가장 먼저 물어보면 좋을 이야기가 있을까요?`,
        },
        visibleMessages[1] ?? {
          id: `${character.id}-assistant-preview-2`,
          sender: 'assistant' as const,
          text:
            promptActions[0]?.reply ??
            `${character.shortDescription} 흐름으로 먼저 풀어드릴게요.`,
        },
      ];

  return (
    <View style={{ gap: fortuneTheme.spacing.md }}>
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
            소울 운세 · 대화를 이어보세요
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
            <AppText variant="caption" color={fortuneTheme.colors.textSecondary}>
              프로필 보기
            </AppText>
          </View>
        </Pressable>
      </View>

      <View
        style={{
          alignItems: 'center',
          paddingTop: 2,
        }}
      >
        <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
          오늘 3:24
        </AppText>
      </View>

      <View style={{ gap: fortuneTheme.spacing.sm }}>
        {previewMessages.map((message, index) => (
          <View key={message.id} style={{ gap: fortuneTheme.spacing.sm }}>
            <View
              style={{
                alignItems: message.sender === 'user' ? 'flex-end' : 'flex-start',
                flexDirection: message.sender === 'user' ? 'row-reverse' : 'row',
                gap: 8,
              }}
            >
              {message.sender === 'user' ? null : (
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
              )}
              <MessageBubble message={message} />
            </View>
            {index === Math.min(2, previewMessages.length - 1) && promptActions.length > 0 ? (
              <View
                style={{
                  gap: 8,
                  paddingLeft: 32,
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
                            actionIndex === 0
                              ? 'rgba(232, 236, 255, 0.96)'
                              : actionIndex === 1
                                ? 'rgba(205, 244, 213, 0.96)'
                                : actionIndex === 2
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
                <View style={{ alignItems: 'flex-end', paddingRight: 12, paddingTop: 2 }}>
                  <View
                    style={{
                      alignItems: 'center',
                      backgroundColor: fortuneTheme.colors.ctaBackground,
                      borderRadius: 18,
                      flexDirection: 'row',
                      gap: 8,
                      paddingHorizontal: 14,
                      paddingVertical: 8,
                    }}
                  >
                    <AppText
                      variant="bodySmall"
                      color={fortuneTheme.colors.ctaForeground}
                      style={{ letterSpacing: 1 }}
                    >
                      〰〰〰
                    </AppText>
                    <AppText variant="caption" color={fortuneTheme.colors.ctaForeground}>
                      0:08
                    </AppText>
                  </View>
                </View>
              </View>
            ) : null}
          </View>
        ))}
      </View>

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
        <View
          style={{
            alignItems: 'center',
            flexDirection: 'row',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <View
            style={{
              alignItems: 'center',
              backgroundColor: fortuneTheme.colors.surfaceElevated,
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
            accessibilityRole="button"
            onPress={onSend}
            style={{
              alignItems: 'center',
              backgroundColor: composerHasDraft
                ? fortuneTheme.colors.ctaBackground
                : fortuneTheme.colors.surfaceElevated,
              borderRadius: 16,
              height: 32,
              justifyContent: 'center',
              minWidth: 32,
              paddingHorizontal: composerHasDraft ? 10 : 0,
            }}
          >
            {composerHasDraft ? (
              <AppText
                variant="labelLarge"
                color={fortuneTheme.colors.ctaForeground}
              >
                보내기
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

      <SurfaceSection title="온보딩 진행도" description="남은 단계를 먼저 마무리해 주세요.">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          <Chip label={`생년월일 ${birthCompleted ? '완료' : '필요'}`} tone={birthCompleted ? 'success' : 'neutral'} />
          <Chip label={`관심사 ${interestCompleted ? '완료' : '필요'}`} tone={interestCompleted ? 'success' : 'neutral'} />
          <Chip label={`첫 안내 ${firstRunHandoffSeen ? '완료' : '필요'}`} tone={firstRunHandoffSeen ? 'success' : 'neutral'} />
        </View>
        <PrimaryButton onPress={onContinue}>온보딩 계속하기</PrimaryButton>
      </SurfaceSection>
    </View>
  );
}
