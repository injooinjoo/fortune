import { useState } from 'react';

import {
  ActionSheetIOS,
  Alert,
  Platform,
  Pressable,
  TextInput,
  View,
} from 'react-native';

import { AppText } from '../../components/app-text';
import { PrimaryButton } from '../../components/primary-button';
import { fortuneTheme } from '../../lib/theme';

// ─── Survey Slider ───────────────────────────────────────────────

export function SurveySlider({
  min = 0,
  max = 100,
  step = 1,
  unit = '',
  onSubmit,
}: {
  min?: number;
  max?: number;
  step?: number;
  unit?: string;
  onSubmit: (value: number, label: string) => void;
}) {
  const [value, setValue] = useState(Math.round((min + max) / 2));
  const totalSteps = Math.round((max - min) / step);
  const currentStep = Math.round((value - min) / step);

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          gap: fortuneTheme.spacing.sm,
        }}
      >
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="감소"
          onPress={() => setValue(Math.max(min, value - step))}
          style={{
            alignItems: 'center',
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: 16,
            height: 32,
            justifyContent: 'center',
            width: 32,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
            −
          </AppText>
        </Pressable>

        <View style={{ flex: 1, height: 32, justifyContent: 'center' }}>
          {/* Track */}
          <View
            style={{
              backgroundColor: fortuneTheme.colors.surfaceSecondary,
              borderRadius: 4,
              height: 6,
              width: '100%',
            }}
          />
          {/* Fill */}
          <View
            style={{
              backgroundColor: fortuneTheme.colors.ctaBackground,
              borderRadius: 4,
              height: 6,
              left: 0,
              position: 'absolute',
              width: `${(currentStep / totalSteps) * 100}%`,
            }}
          />
          {/* Thumb indicator */}
          <View
            style={{
              backgroundColor: fortuneTheme.colors.ctaBackground,
              borderRadius: 10,
              height: 20,
              left: `${(currentStep / totalSteps) * 100}%`,
              marginLeft: -10,
              position: 'absolute',
              width: 20,
            }}
          />
        </View>

        <Pressable
          accessibilityRole="button"
          accessibilityLabel="증가"
          onPress={() => setValue(Math.min(max, value + step))}
          style={{
            alignItems: 'center',
            backgroundColor: fortuneTheme.colors.surfaceSecondary,
            borderRadius: 16,
            height: 32,
            justifyContent: 'center',
            width: 32,
          }}
        >
          <AppText variant="labelLarge" color={fortuneTheme.colors.textSecondary}>
            +
          </AppText>
        </Pressable>
      </View>

      <View style={{ alignItems: 'center' }}>
        <AppText variant="heading4" color={fortuneTheme.colors.textPrimary}>
          {value}
          {unit ? ` ${unit}` : ''}
        </AppText>
      </View>

      <PrimaryButton onPress={() => onSubmit(value, `${value}${unit}`)}>
        선택 완료
      </PrimaryButton>
    </View>
  );
}

// ─── Birth Datetime Picker ───────────────────────────────────────

export function SurveyBirthDatetimePicker({
  onSubmit,
}: {
  onSubmit: (value: string, label: string) => void;
}) {
  const [year, setYear] = useState('1995');
  const [month, setMonth] = useState('1');
  const [day, setDay] = useState('1');
  const [hour, setHour] = useState('');
  const [minute, setMinute] = useState('');

  const canSubmit = year.length === 4 && month.length > 0 && day.length > 0;

  function handleSubmit() {
    const dateStr = `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
    const timeStr =
      hour && minute
        ? `${hour.padStart(2, '0')}:${minute.padStart(2, '0')}`
        : '';
    const full = timeStr ? `${dateStr} ${timeStr}` : dateStr;
    const label = timeStr
      ? `${year}년 ${month}월 ${day}일 ${hour}시 ${minute}분`
      : `${year}년 ${month}월 ${day}일`;
    onSubmit(full, label);
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <View style={{ flexDirection: 'row', gap: 8 }}>
        <View style={{ flex: 2 }}>
          <InputField
            label="년"
            value={year}
            onChange={setYear}
            placeholder="1995"
            keyboardType="number-pad"
            maxLength={4}
          />
        </View>
        <View style={{ flex: 1 }}>
          <InputField
            label="월"
            value={month}
            onChange={setMonth}
            placeholder="1"
            keyboardType="number-pad"
            maxLength={2}
          />
        </View>
        <View style={{ flex: 1 }}>
          <InputField
            label="일"
            value={day}
            onChange={setDay}
            placeholder="1"
            keyboardType="number-pad"
            maxLength={2}
          />
        </View>
      </View>

      <View style={{ flexDirection: 'row', gap: 8 }}>
        <View style={{ flex: 1 }}>
          <InputField
            label="시 (선택)"
            value={hour}
            onChange={setHour}
            placeholder="--"
            keyboardType="number-pad"
            maxLength={2}
          />
        </View>
        <View style={{ flex: 1 }}>
          <InputField
            label="분 (선택)"
            value={minute}
            onChange={setMinute}
            placeholder="--"
            keyboardType="number-pad"
            maxLength={2}
          />
        </View>
        <View style={{ flex: 1 }} />
      </View>

      <PrimaryButton disabled={!canSubmit} onPress={handleSubmit}>
        입력 완료
      </PrimaryButton>
    </View>
  );
}

function InputField({
  label,
  value,
  onChange,
  placeholder,
  keyboardType = 'default',
  maxLength,
}: {
  label: string;
  value: string;
  onChange: (text: string) => void;
  placeholder?: string;
  keyboardType?: 'default' | 'number-pad';
  maxLength?: number;
}) {
  return (
    <View style={{ gap: 4 }}>
      <AppText variant="caption" color={fortuneTheme.colors.textTertiary}>
        {label}
      </AppText>
      <View
        style={{
          backgroundColor: fortuneTheme.colors.surfaceSecondary,
          borderColor: fortuneTheme.colors.border,
          borderRadius: fortuneTheme.radius.sm,
          borderWidth: 1,
          paddingHorizontal: 10,
          paddingVertical: 8,
        }}
      >
        <TextInput
          keyboardType={keyboardType}
          maxLength={maxLength}
          onChangeText={onChange}
          placeholder={placeholder}
          placeholderTextColor={fortuneTheme.colors.textTertiary}
          style={{
            color: fortuneTheme.colors.textPrimary,
            fontSize: 15,
            textAlign: 'center',
          }}
          value={value}
        />
      </View>
    </View>
  );
}

// ─── Calendar Picker ─────────────────────────────────────────────

export function SurveyCalendarPicker({
  onSubmit,
}: {
  onSubmit: (value: string, label: string) => void;
}) {
  const today = new Date();
  const [selectedOffset, setSelectedOffset] = useState<number | null>(null);

  const days = Array.from({ length: 14 }, (_, i) => {
    const date = new Date(today);
    date.setDate(date.getDate() + i);
    return {
      offset: i,
      label: formatCalendarDay(date, i),
      dateStr: `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`,
    };
  });

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
        {days.map((day) => (
          <Pressable
            key={day.offset}
            accessibilityRole="button"
            onPress={() => setSelectedOffset(day.offset)}
            style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
          >
            <View
              style={{
                backgroundColor:
                  selectedOffset === day.offset
                    ? fortuneTheme.colors.chipLavender
                    : fortuneTheme.colors.surfaceSecondary,
                borderRadius: fortuneTheme.radius.chip,
                paddingHorizontal: 12,
                paddingVertical: 6,
              }}
            >
              <AppText
                variant="labelSmall"
                color={
                  selectedOffset === day.offset
                    ? fortuneTheme.colors.chipText
                    : fortuneTheme.colors.textSecondary
                }
              >
                {day.label}
              </AppText>
            </View>
          </Pressable>
        ))}
      </View>
      <PrimaryButton
        disabled={selectedOffset === null}
        onPress={() => {
          if (selectedOffset !== null) {
            const day = days[selectedOffset];
            onSubmit(day.dateStr, day.label);
          }
        }}
      >
        날짜 선택
      </PrimaryButton>
    </View>
  );
}

function formatCalendarDay(date: Date, offset: number) {
  const month = date.getMonth() + 1;
  const day = date.getDate();
  if (offset === 0) return `오늘 ${month}/${day}`;
  if (offset === 1) return `내일 ${month}/${day}`;
  const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
  return `${weekdays[date.getDay()]} ${month}/${day}`;
}

// ─── Image Input (survey step) ───────────────────────────────────

export function SurveyImageInput({
  hint,
  onSubmit,
}: {
  hint?: string;
  onSubmit: (value: string, label: string) => void;
}) {
  const [selectedSource, setSelectedSource] = useState<string | null>(null);

  function handlePickCamera() {
    setSelectedSource('camera');
    // In a real implementation, this would use expo-image-picker
    onSubmit('camera://photo', '카메라 촬영');
  }

  function handlePickGallery() {
    setSelectedSource('gallery');
    onSubmit('gallery://photo', '갤러리 선택');
  }

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      {hint ? (
        <AppText variant="bodySmall" color={fortuneTheme.colors.textSecondary}>
          {hint}
        </AppText>
      ) : null}
      <View style={{ flexDirection: 'row', gap: 8 }}>
        <Pressable
          accessibilityRole="button"
          onPress={handlePickCamera}
          style={({ pressed }) => ({
            alignItems: 'center',
            backgroundColor:
              selectedSource === 'camera'
                ? fortuneTheme.colors.chipLavender
                : fortuneTheme.colors.surfaceSecondary,
            borderColor: fortuneTheme.colors.border,
            borderRadius: fortuneTheme.radius.md,
            borderWidth: 1,
            flex: 1,
            gap: 4,
            justifyContent: 'center',
            opacity: pressed ? 0.84 : 1,
            paddingVertical: 16,
          })}
        >
          <AppText variant="heading4">📷</AppText>
          <AppText
            variant="labelSmall"
            color={fortuneTheme.colors.textSecondary}
          >
            카메라
          </AppText>
        </Pressable>
        <Pressable
          accessibilityRole="button"
          onPress={handlePickGallery}
          style={({ pressed }) => ({
            alignItems: 'center',
            backgroundColor:
              selectedSource === 'gallery'
                ? fortuneTheme.colors.chipLavender
                : fortuneTheme.colors.surfaceSecondary,
            borderColor: fortuneTheme.colors.border,
            borderRadius: fortuneTheme.radius.md,
            borderWidth: 1,
            flex: 1,
            gap: 4,
            justifyContent: 'center',
            opacity: pressed ? 0.84 : 1,
            paddingVertical: 16,
          })}
        >
          <AppText variant="heading4">🖼️</AppText>
          <AppText
            variant="labelSmall"
            color={fortuneTheme.colors.textSecondary}
          >
            갤러리
          </AppText>
        </Pressable>
      </View>
    </View>
  );
}

// ─── Match Selector (compatibility fortunes) ─────────────────────

export function SurveyMatchSelector({
  onSubmit,
}: {
  onSubmit: (value: string, label: string) => void;
}) {
  const [selectedId, setSelectedId] = useState<string | null>(null);

  const profiles = [
    { id: 'self', label: '나', emoji: '🙋' },
    { id: 'partner', label: '연인/배우자', emoji: '💑' },
    { id: 'friend', label: '친구', emoji: '🤝' },
    { id: 'family', label: '가족', emoji: '👨‍👩‍👧' },
    { id: 'pet', label: '반려동물', emoji: '🐾' },
  ];

  return (
    <View style={{ gap: fortuneTheme.spacing.sm }}>
      <View style={{ flexDirection: 'row', flexWrap: 'wrap', gap: 8 }}>
        {profiles.map((profile) => (
          <Pressable
            key={profile.id}
            accessibilityRole="button"
            onPress={() => setSelectedId(profile.id)}
            style={({ pressed }) => ({ opacity: pressed ? 0.84 : 1 })}
          >
            <View
              style={{
                alignItems: 'center',
                backgroundColor:
                  selectedId === profile.id
                    ? fortuneTheme.colors.chipLavender
                    : fortuneTheme.colors.surfaceSecondary,
                borderColor:
                  selectedId === profile.id
                    ? fortuneTheme.colors.chipLavender
                    : fortuneTheme.colors.border,
                borderRadius: fortuneTheme.radius.md,
                borderWidth: 1,
                gap: 4,
                paddingHorizontal: 16,
                paddingVertical: 12,
              }}
            >
              <AppText variant="heading3">{profile.emoji}</AppText>
              <AppText
                variant="labelSmall"
                color={
                  selectedId === profile.id
                    ? fortuneTheme.colors.chipText
                    : fortuneTheme.colors.textSecondary
                }
              >
                {profile.label}
              </AppText>
            </View>
          </Pressable>
        ))}
      </View>
      <PrimaryButton
        disabled={!selectedId}
        onPress={() => {
          const profile = profiles.find((p) => p.id === selectedId);
          if (profile) {
            onSubmit(profile.id, `${profile.emoji} ${profile.label}`);
          }
        }}
      >
        선택 완료
      </PrimaryButton>
    </View>
  );
}
