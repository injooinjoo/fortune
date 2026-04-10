import { useState, useMemo, useCallback } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { Pressable, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

const DAY_LABELS = ['일', '월', '화', '수', '목', '금', '토'] as const;
const CELL_SIZE = 36;
const GAP = 4;

interface InlineCalendarProps {
  selectedDate: Date | null;
  onSelectDate: (date: Date) => void;
  minDate?: Date;
  maxDate?: Date;
}

/** Strip time components so two Date objects can be compared by day only. */
function startOfDay(d: Date): Date {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

function isSameDay(a: Date, b: Date): boolean {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

function isBeforeDay(a: Date, b: Date): boolean {
  return startOfDay(a).getTime() < startOfDay(b).getTime();
}

function isAfterDay(a: Date, b: Date): boolean {
  return startOfDay(a).getTime() > startOfDay(b).getTime();
}

/** Return a flat array of Date | null for every cell in the calendar grid.
 *  null entries are placeholders for days before the 1st of the month. */
function buildMonthGrid(year: number, month: number): (Date | null)[] {
  const firstDay = new Date(year, month, 1);
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const startDow = firstDay.getDay(); // 0 = Sunday

  const cells: (Date | null)[] = [];

  // Leading blanks
  for (let i = 0; i < startDow; i++) {
    cells.push(null);
  }

  // Actual days
  for (let d = 1; d <= daysInMonth; d++) {
    cells.push(new Date(year, month, d));
  }

  return cells;
}

export function InlineCalendar({
  selectedDate,
  onSelectDate,
  minDate,
  maxDate,
}: InlineCalendarProps) {
  const today = useMemo(() => startOfDay(new Date()), []);

  const [viewYear, setViewYear] = useState(
    selectedDate ? selectedDate.getFullYear() : today.getFullYear(),
  );
  const [viewMonth, setViewMonth] = useState(
    selectedDate ? selectedDate.getMonth() : today.getMonth(),
  );

  const cells = useMemo(() => buildMonthGrid(viewYear, viewMonth), [viewYear, viewMonth]);

  const goToPrevMonth = useCallback(() => {
    setViewMonth((m) => {
      if (m === 0) {
        setViewYear((y) => y - 1);
        return 11;
      }
      return m - 1;
    });
  }, []);

  const goToNextMonth = useCallback(() => {
    setViewMonth((m) => {
      if (m === 11) {
        setViewYear((y) => y + 1);
        return 0;
      }
      return m + 1;
    });
  }, []);

  const monthLabel = `${viewYear}년 ${viewMonth + 1}월`;

  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surface,
        borderRadius: fortuneTheme.radius.card,
        padding: 12,
      }}
    >
      {/* Month / Year header with nav arrows */}
      <View
        style={{
          alignItems: 'center',
          flexDirection: 'row',
          justifyContent: 'space-between',
          marginBottom: 8,
          paddingHorizontal: 4,
        }}
      >
        <Pressable
          accessibilityLabel="이전 달"
          accessibilityRole="button"
          hitSlop={12}
          onPress={goToPrevMonth}
          style={({ pressed }) => ({ opacity: pressed ? 0.5 : 1 })}
        >
          <Ionicons
            color={fortuneTheme.colors.textSecondary}
            name="chevron-back"
            size={20}
          />
        </Pressable>

        <AppText variant="heading4">{monthLabel}</AppText>

        <Pressable
          accessibilityLabel="다음 달"
          accessibilityRole="button"
          hitSlop={12}
          onPress={goToNextMonth}
          style={({ pressed }) => ({ opacity: pressed ? 0.5 : 1 })}
        >
          <Ionicons
            color={fortuneTheme.colors.textSecondary}
            name="chevron-forward"
            size={20}
          />
        </Pressable>
      </View>

      {/* Day-of-week headers */}
      <View style={{ flexDirection: 'row', marginBottom: 4 }}>
        {DAY_LABELS.map((label, idx) => {
          const color =
            idx === 0
              ? fortuneTheme.colors.error
              : idx === 6
                ? fortuneTheme.colors.textSecondary
                : fortuneTheme.colors.textTertiary;

          return (
            <View
              key={label}
              style={{
                alignItems: 'center',
                height: CELL_SIZE,
                justifyContent: 'center',
                width: `${100 / 7}%`,
              }}
            >
              <AppText variant="labelSmall" color={color}>
                {label}
              </AppText>
            </View>
          );
        })}
      </View>

      {/* Date grid */}
      <View style={{ flexDirection: 'row', flexWrap: 'wrap' }}>
        {cells.map((date, idx) => {
          if (!date) {
            return (
              <View
                key={`blank-${idx}`}
                style={{ height: CELL_SIZE + GAP, width: `${100 / 7}%` }}
              />
            );
          }

          const isToday = isSameDay(date, today);
          const isSelected = selectedDate ? isSameDay(date, selectedDate) : false;
          const isPast = isBeforeDay(date, today);
          const dow = date.getDay();

          const disabled =
            (minDate != null && isBeforeDay(date, minDate)) ||
            (maxDate != null && isAfterDay(date, maxDate));

          // Text color
          let textColor: string = fortuneTheme.colors.textPrimary;
          if (isSelected) {
            textColor = fortuneTheme.colors.ctaForeground;
          } else if (disabled) {
            textColor = fortuneTheme.colors.textTertiary;
          } else if (dow === 0) {
            textColor = fortuneTheme.colors.error;
          } else if (dow === 6) {
            textColor = fortuneTheme.colors.textSecondary;
          }

          return (
            <View
              key={date.toISOString()}
              style={{
                alignItems: 'center',
                height: CELL_SIZE + GAP,
                justifyContent: 'center',
                width: `${100 / 7}%`,
              }}
            >
              <Pressable
                accessibilityLabel={`${date.getMonth() + 1}월 ${date.getDate()}일`}
                accessibilityRole="button"
                disabled={disabled}
                onPress={() => onSelectDate(date)}
                style={({ pressed }) => ({
                  alignItems: 'center',
                  backgroundColor: isSelected
                    ? fortuneTheme.colors.ctaBackground
                    : 'transparent',
                  borderColor: isToday && !isSelected
                    ? fortuneTheme.colors.ctaBackground
                    : 'transparent',
                  borderRadius: CELL_SIZE / 2,
                  borderWidth: isToday && !isSelected ? 1.5 : 0,
                  height: CELL_SIZE,
                  justifyContent: 'center',
                  opacity: disabled ? 0.4 : pressed ? 0.6 : isPast && !isSelected ? 0.55 : 1,
                  width: CELL_SIZE,
                })}
              >
                <AppText variant="bodySmall" color={textColor}>
                  {date.getDate()}
                </AppText>
              </Pressable>
            </View>
          );
        })}
      </View>
    </View>
  );
}
