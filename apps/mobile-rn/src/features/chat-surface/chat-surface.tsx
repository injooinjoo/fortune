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
import { RecentResultCard } from '../fortune-results/recent-result-card';

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
  character: ChatCharacterSpec;
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

  return (
    <View
      style={{
        alignItems: isUser ? 'flex-end' : 'flex-start',
        flexDirection: isUser ? 'row-reverse' : 'row',
        gap: 8,
      }}
    >
      {isUser ? null : (
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
      <View style={{ flex: isUser ? 0 : 1, maxWidth: isUser ? '84%' : '100%' }}>
        {message.kind === 'embedded-result' ? (
          <EmbeddedResultMessage message={message} />
        ) : (
          <MessageBubble message={message} />
        )}
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
  activeTab,
  featuredCharacter,
  actions,
  characters,
  lastFortuneType,
  selectedCharacterId,
  onChangeTab,
  onCreateFriend,
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
  onOpenRecentResult: (fortuneType: FortuneTypeId) => void;
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
          <SegmentedPills activeTab={activeTab} onChangeTab={onChangeTab} />
        </View>
        <HeaderDots />
      </View>

      {activeTab === 'fortune' ? (
        <SurfaceSection
          title="맞춤 시작점"
          description={`${featuredCharacter.name}의 추천 흐름을 기준으로 바로 운세를 시작할 수 있습니다.`}
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
                badge="운세"
                onPress={() => onPickAction(action.fortuneType)}
                tone="neutral"
              />
            ),
          )}
        </SurfaceSection>
      ) : (
        <SurfaceSection
          title="대화 시작"
          description="세계관 캐릭터와 바로 대화를 열거나, 새 친구 캐릭터를 만들어 이어갈 수 있습니다."
        >
          <EntryActionRow
            badge="친구"
            onPress={onCreateFriend}
            subtitle="문서 기준 5단계 플로우로 새 친구 캐릭터를 만들고 채팅으로 이어갑니다."
            title="새 친구 만들기"
            tone="accent"
          />
        </SurfaceSection>
      )}

      <SurfaceSection
        title={activeTab === 'story' ? '대화 캐릭터' : '운세 상담사'}
        description={
          activeTab === 'story'
            ? '세계관 대화를 바로 시작할 캐릭터를 고르세요.'
            : '설문과 결과가 같은 채팅 안에서 이어지는 운세 전문가를 고르세요.'
        }
      >
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {characters.map((character) => (
            <CharacterListRow
              key={character.id}
              character={character}
              onPress={() => onSelectCharacter(character.id)}
            />
          ))}
        </View>
      </SurfaceSection>

      {activeTab === 'fortune' ? (
        <RecentResultCard
          lastFortuneType={lastFortuneType}
          onOpen={onOpenRecentResult}
          selectedCharacterId={selectedCharacterId}
        />
      ) : null}

      <PagerDots />
    </View>
  );
}

export function ActiveChatComposer({
  draft,
  onDraftChange,
  onSend,
}: {
  draft: string;
  onDraftChange: (value: string) => void;
  onSend: () => void;
}) {
  const composerHasDraft = draft.trim().length > 0;

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
  onBack: () => void;
  onOpenProfile: () => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
  showHeader?: boolean;
}) {
  const isFortuneCharacter = isFortuneChatCharacter(character);
  const visibleMessages = messages;
  const promptActions = actions.slice(0, 4);
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
      </View>

      {!surveyActive && promptActions.length > 0 ? (
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
