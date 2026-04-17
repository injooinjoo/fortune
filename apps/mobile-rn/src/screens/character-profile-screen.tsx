import { Image, View } from 'react-native';

import { router, useLocalSearchParams, type Href } from 'expo-router';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { Chip } from '../components/chip';
import { PrimaryButton } from '../components/primary-button';
import {
  resolveBackDestinationLabel,
  RouteBackHeader,
} from '../components/route-back-header';
import { Screen } from '../components/screen';
import { resolveChatCharacterAvatarSource } from '../lib/chat-character-avatar';
import { getCharacterDetail } from '../lib/character-details';
import { findChatCharacterById, isFortuneChatCharacter } from '../lib/chat-characters';
import { fortuneTheme } from '../lib/theme';

// ---------------------------------------------------------------------------
// Tag pill colours — cycle through chip palette
// ---------------------------------------------------------------------------

const TAG_COLORS = [
  fortuneTheme.colors.chipLavender,
  fortuneTheme.colors.chipGreen,
  fortuneTheme.colors.chipPeach,
  fortuneTheme.colors.chipBlue,
] as const;

function tagColor(index: number) {
  return TAG_COLORS[index % TAG_COLORS.length];
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

export function CharacterProfileScreen() {
  const params = useLocalSearchParams<{ id?: string; returnTo?: string | string[] }>();
  const character = findChatCharacterById(params.id);
  const detail = getCharacterDetail(params.id);
  const avatarSource = resolveChatCharacterAvatarSource(params.id);

  const returnTo =
    typeof params.returnTo === 'string' && params.returnTo.startsWith('/')
      ? params.returnTo
      : '/chat';
  const backDestinationLabel = resolveBackDestinationLabel(returnTo as Href);

  const isFortune = character ? isFortuneChatCharacter(character) : false;

  // -------------------------------------------------------------------------
  // Not found
  // -------------------------------------------------------------------------

  if (!character) {
    return (
      <Screen
        header={
          <RouteBackHeader
            fallbackHref={returnTo as Href}
            label={backDestinationLabel}
          />
        }
      >
        <Card>
          <AppText variant="heading4">캐릭터를 찾을 수 없어요</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            요청한 캐릭터를 찾지 못했어요. 다른 캐릭터를 선택해 주세요.
          </AppText>
          <PrimaryButton onPress={() => router.replace('/chat')}>
            채팅으로 돌아가기
          </PrimaryButton>
        </Card>
      </Screen>
    );
  }

  // -------------------------------------------------------------------------
  // Main profile
  // -------------------------------------------------------------------------

  return (
    <Screen
      header={
        <RouteBackHeader
          fallbackHref={returnTo as Href}
          label={backDestinationLabel}
        />
      }
      footer={
        <PrimaryButton
          onPress={() =>
            router.push({
              pathname: '/chat',
              params: { characterId: character.id },
            })
          }
        >
          이 캐릭터로 채팅하기
        </PrimaryButton>
      }
    >
      {/* ----------------------------------------------------------------- */}
      {/* Hero: Avatar + name + description                                 */}
      {/* ----------------------------------------------------------------- */}
      <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.md }}>
        {avatarSource ? (
          <Image
            source={avatarSource}
            style={{
              width: 120,
              height: 120,
              borderRadius: fortuneTheme.radius.full,
              borderWidth: 2,
              borderColor: fortuneTheme.colors.border,
            }}
          />
        ) : (
          <View
            style={{
              width: 120,
              height: 120,
              borderRadius: fortuneTheme.radius.full,
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <AppText variant="displaySmall">{character.name[0]}</AppText>
          </View>
        )}

        <View style={{ alignItems: 'center', gap: fortuneTheme.spacing.xs }}>
          <AppText variant="heading1" style={{ textAlign: 'center' }}>
            {character.name}
          </AppText>
          <Chip
            label={isFortune ? '인사이트 캐릭터' : '스토리 캐릭터'}
            tone={isFortune ? 'accent' : 'success'}
          />
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ textAlign: 'center', marginTop: fortuneTheme.spacing.xs }}
          >
            {character.shortDescription}
          </AppText>
        </View>
      </View>

      {/* ----------------------------------------------------------------- */}
      {/* Tags                                                              */}
      {/* ----------------------------------------------------------------- */}
      {detail && detail.tags.length > 0 && (
        <View
          style={{
            flexDirection: 'row',
            flexWrap: 'wrap',
            gap: fortuneTheme.spacing.sm,
          }}
        >
          {detail.tags.map((tag, i) => (
            <View
              key={tag}
              style={{
                backgroundColor: tagColor(i),
                borderRadius: fortuneTheme.radius.chip,
                paddingHorizontal: 12,
                paddingVertical: 6,
              }}
            >
              <AppText variant="labelSmall" color={fortuneTheme.colors.chipText}>
                #{tag}
              </AppText>
            </View>
          ))}
        </View>
      )}

      {/* ----------------------------------------------------------------- */}
      {/* First message                                                     */}
      {/* ----------------------------------------------------------------- */}
      {detail?.firstMessage ? (
        <Card>
          <AppText variant="heading4">첫 인사</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            {detail.firstMessage}
          </AppText>
        </Card>
      ) : null}

      {/* ----------------------------------------------------------------- */}
      {/* Worldview                                                         */}
      {/* ----------------------------------------------------------------- */}
      {detail?.worldview ? (
        <Card>
          <AppText variant="heading4">세계관</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ lineHeight: 24 }}
          >
            {detail.worldview}
          </AppText>
        </Card>
      ) : null}

      {/* ----------------------------------------------------------------- */}
      {/* Personality                                                       */}
      {/* ----------------------------------------------------------------- */}
      {detail?.personality ? (
        <Card>
          <AppText variant="heading4">성격 / 특징</AppText>
          <AppText
            variant="bodyMedium"
            color={fortuneTheme.colors.textSecondary}
            style={{ lineHeight: 24 }}
          >
            {detail.personality}
          </AppText>
        </Card>
      ) : null}

      {/* ----------------------------------------------------------------- */}
      {/* Specialties (fortune characters only)                             */}
      {/* ----------------------------------------------------------------- */}
      {detail?.specialtyDescriptions && detail.specialtyDescriptions.length > 0 && (
        <Card>
          <AppText variant="heading4">전문 분야</AppText>
          {detail.specialtyDescriptions.map((s) => (
            <View
              key={s.label}
              style={{
                flexDirection: 'row',
                alignItems: 'flex-start',
                gap: fortuneTheme.spacing.sm,
              }}
            >
              <View
                style={{
                  width: 6,
                  height: 6,
                  borderRadius: 3,
                  backgroundColor: fortuneTheme.colors.ctaBackground,
                  marginTop: 8,
                }}
              />
              <View style={{ flex: 1 }}>
                <AppText variant="labelLarge">{s.label}</AppText>
                <AppText
                  variant="bodySmall"
                  color={fortuneTheme.colors.textSecondary}
                >
                  {s.description}
                </AppText>
              </View>
            </View>
          ))}
        </Card>
      )}

      {detail && detail.galleryImages.length > 0 ? (
        <Card>
          <AppText variant="heading4">갤러리</AppText>
          <View
            style={{
              flexDirection: 'row',
              flexWrap: 'wrap',
              gap: fortuneTheme.spacing.sm,
            }}
          >
            {detail.galleryImages.map((src, i) => (
              <Image
                key={i}
                source={{ uri: src }}
                style={{
                  width: '31%',
                  aspectRatio: 1,
                  borderRadius: fortuneTheme.radius.md,
                  backgroundColor: fortuneTheme.colors.surfaceSecondary,
                }}
              />
            ))}
          </View>
        </Card>
      ) : null}
    </Screen>
  );
}
