import type { ReactNode } from 'react';

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

function categoryLabel(category: string) {
  switch (category) {
    case 'traditional':
      return '사주';
    case 'love':
      return '연애';
    case 'career':
      return '커리어';
    case 'special':
      return '스페셜';
    case 'personality':
      return '분석';
    case 'zodiac':
      return '별자리';
    case 'sports':
      return '액티브';
    case 'lucky':
      return '행운';
    case 'lifestyle':
      return '라이프';
    default:
      return category;
  }
}

function categoryTone(category: string): 'neutral' | 'accent' | 'success' {
  switch (category) {
    case 'love':
    case 'zodiac':
    case 'special':
      return 'accent';
    case 'career':
    case 'sports':
      return 'success';
    default:
      return 'neutral';
  }
}

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
          flexDirection: 'row',
          gap: fortuneTheme.spacing.sm,
          paddingVertical: fortuneTheme.spacing.xs,
        }}
      >
        <CharacterAvatar name={character.name} />
        <View style={{ flex: 1, gap: 2 }}>
          <AppText variant="labelLarge">{character.name}</AppText>
          <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
            {character.shortDescription}
          </AppText>
        </View>
        <Chip
          label={categoryLabel(character.category)}
          tone={categoryTone(character.category)}
        />
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
          backgroundColor: isSystem
            ? fortuneTheme.colors.surfaceSecondary
            : isAssistant
              ? fortuneTheme.colors.backgroundTertiary
              : fortuneTheme.colors.ctaBackground,
          borderColor: isSystem
            ? fortuneTheme.colors.border
            : isAssistant
              ? fortuneTheme.colors.border
              : 'transparent',
          borderRadius: fortuneTheme.radius.messageBubble,
          borderWidth: 1,
          maxWidth: '92%',
          paddingHorizontal: 14,
          paddingVertical: 10,
        }}
      >
        <AppText
          variant="bodyMedium"
          color={
            message.sender === 'user'
              ? fortuneTheme.colors.ctaForeground
              : isSystem
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
}: {
  title: string;
  description?: string;
  children: ReactNode;
}) {
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
  recentResultCard,
  onSelectCharacter,
  onPickAction,
  onOpenPremium,
}: {
  featuredCharacter: FortuneCharacterSpec;
  actions: ChatShellAction[];
  characters: readonly FortuneCharacterSpec[];
  recentResultCard?: ReactNode;
  onSelectCharacter: (characterId: string) => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
  onOpenPremium: () => void;
}) {
  const primaryAction = actions[0];
  const secondaryActions = actions.slice(1, 3);

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
        {secondaryActions.map((action) => (
          <EntryActionRow
            key={action.id}
            title={action.label}
            subtitle={action.reply}
            badge="스토리"
            onPress={() => onPickAction(action.fortuneType)}
            tone="neutral"
          />
        ))}
        {primaryAction ? (
          <Pressable
            accessibilityRole="button"
            onPress={() => onPickAction(primaryAction.fortuneType)}
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
                  <AppText variant="heading4">{primaryAction.label}</AppText>
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
        ) : null}
      </SurfaceSection>

      {recentResultCard}

      <SurfaceSection title="상담사" description="최근 대화가 준비된 캐릭터부터 이어서 볼 수 있습니다.">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {characters.slice(0, 4).map((character) => (
            <CharacterListRow
              key={character.id}
              character={character}
              onPress={() => onSelectCharacter(character.id)}
            />
          ))}
        </View>
      </SurfaceSection>

      <Card
        style={{
          backgroundColor: fortuneTheme.colors.surfaceElevated,
          gap: fortuneTheme.spacing.md,
        }}
      >
        <View
          style={{
            alignItems: 'center',
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: fortuneTheme.radius.lg,
            height: 144,
            justifyContent: 'center',
          }}
        >
          <AppText variant="displaySmall">⌘</AppText>
          <AppText variant="heading4">프리미엄 사주</AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            style={{ textAlign: 'center' }}
          >
            더 깊은 해석과 카드형 리포트를 이어서 볼 수 있어요.
          </AppText>
        </View>
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <EntryActionRow
            title="아름다운 인사이트"
            subtitle="전문 작가의 손길로 정리된 장문형 해석"
            onPress={onOpenPremium}
          />
          <EntryActionRow
            title="스토리텔링"
            subtitle="서사형 운세 체험으로 몰입감 있는 리딩"
            onPress={onOpenPremium}
          />
          <EntryActionRow
            title="심층 분석"
            subtitle="더 깊이 읽는 인사이트 분석 제공"
            onPress={onOpenPremium}
          />
        </View>
        <PrimaryButton onPress={onOpenPremium}>프리미엄 사주 시작하기</PrimaryButton>
      </Card>
    </View>
  );
}

export function ActiveCharacterChatSurface({
  character,
  actions,
  messages,
  draft,
  recentResultCard,
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
  recentResultCard?: ReactNode;
  onBack: () => void;
  onOpenProfile: () => void;
  onPickAction: (fortuneType: FortuneTypeId) => void;
  onDraftChange: (value: string) => void;
  onSend: () => void;
}) {
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

      <Card style={{ alignItems: 'center', gap: fortuneTheme.spacing.sm }}>
        <CharacterAvatar name={character.name} size={72} />
        <View style={{ alignItems: 'center', gap: 4 }}>
          <AppText variant="heading4">{character.name}</AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
            style={{ textAlign: 'center' }}
          >
            {character.shortDescription}
          </AppText>
        </View>
        <PrimaryButton onPress={onOpenProfile} tone="secondary">
          프로필 보기
        </PrimaryButton>
      </Card>

      {recentResultCard}

      <SurfaceSection title="빠른 질문" description="채팅 흐름을 끊지 않고 바로 운세 화면으로 넘어갈 수 있습니다.">
        <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
          {actions.map((action, index) => (
            <Pressable
              key={action.id}
              accessibilityRole="button"
              onPress={() => onPickAction(action.fortuneType)}
              style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
            >
              <View>
                <Chip
                  label={action.label}
                  tone={index === 1 ? 'success' : index === 2 ? 'neutral' : 'accent'}
                />
              </View>
            </Pressable>
          ))}
        </View>
      </SurfaceSection>

      <SurfaceSection title="대화" description="활성 캐릭터 채팅 표면">
        <View style={{ gap: fortuneTheme.spacing.sm }}>
          {messages.map((message) => (
            <MessageBubble key={message.id} message={message} />
          ))}
        </View>
      </SurfaceSection>

      <Card>
        <View
          style={{
            alignItems: 'flex-end',
            flexDirection: 'row',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          <View style={{ flex: 1 }}>
            <TextInput
              accessibilityLabel="chat composer"
              multiline
              onChangeText={onDraftChange}
              placeholder={`${character.name}에게 질문을 남겨보세요`}
              placeholderTextColor={fortuneTheme.colors.textTertiary}
              style={{
                backgroundColor: fortuneTheme.colors.surfaceSecondary,
                borderColor: fortuneTheme.colors.border,
                borderRadius: fortuneTheme.radius.inputArea,
                borderWidth: 1,
                color: fortuneTheme.colors.textPrimary,
                maxHeight: 140,
                minHeight: 54,
                paddingHorizontal: 16,
                paddingVertical: 14,
                textAlignVertical: 'top',
              }}
              value={draft}
            />
          </View>
          <Pressable
            accessibilityRole="button"
            onPress={onSend}
            style={({ pressed }) => ({
              alignItems: 'center',
              backgroundColor: fortuneTheme.colors.ctaBackground,
              borderRadius: 22,
              height: 44,
              justifyContent: 'center',
              opacity: pressed ? 0.84 : 1,
              width: 64,
            })}
          >
            <AppText variant="labelLarge" color={fortuneTheme.colors.ctaForeground}>
              보내기
            </AppText>
          </Pressable>
        </View>
      </Card>
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
