import { useState, useMemo, useCallback, useEffect, useRef } from 'react';

import { Ionicons } from '@expo/vector-icons';
import { Pressable, ScrollView, View } from 'react-native';

import { fortuneTheme } from '../lib/theme';
import { AppText } from './app-text';

const DAY_LABELS = ['일', '월', '화', '수', '목', '금', '토'] as const;
const CELL_SIZE = 36;
const GAP = 4;
// 연도 그리드 범위 — 생년월일 입력 커버용. 오늘 기준 과거 120년 ~ 미래 10년.
const YEAR_RANGE_PAST = 120;
const YEAR_RANGE_FUTURE = 10;
const YEAR_GRID_COLS = 4;
const YEAR_CELL_HEIGHT = 44;

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
  // 생년월일 같이 연도를 크게 점프해야 할 때 레이블 탭으로 연도 그리드 진입.
  const [mode, setMode] = useState<'month' | 'year'>('month');
  const yearScrollRef = useRef<ScrollView | null>(null);

  const cells = useMemo(() => buildMonthGrid(viewYear, viewMonth), [viewYear, viewMonth]);

  const years = useMemo(() => {
    const currentYear = today.getFullYear();
    const start = currentYear - YEAR_RANGE_PAST;
    const end = currentYear + YEAR_RANGE_FUTURE;
    const out: number[] = [];
    // 최신 연도가 위에 오도록 내림차순 — 생년월일 스크롤 시 현재부터 과거로 탐색.
    for (let y = end; y >= start; y -= 1) {
      out.push(y);
    }
    return out;
  }, [today]);

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

  const handleToggleMode = useCallback(() => {
    setMode((current) => (current === 'month' ? 'year' : 'month'));
  }, []);

  const handlePickYear = useCallback((year: number) => {
    setViewYear(year);
    setMode('month');
  }, []);

  // year 모드 진입 시 현재 보고 있는 연도가 화면 중앙에 보이도록 자동 스크롤.
  useEffect(() => {
    if (mode !== 'year') return;
    const idx = years.indexOf(viewYear);
    if (idx < 0) return;
    const rowIndex = Math.floor(idx / YEAR_GRID_COLS);
    const offsetY = Math.max(0, rowIndex * YEAR_CELL_HEIGHT - YEAR_CELL_HEIGHT * 2);
    requestAnimationFrame(() => {
      yearScrollRef.current?.scrollTo({ y: offsetY, animated: false });
    });
  }, [mode, years, viewYear]);

  const monthLabel = `${viewYear}년 ${viewMonth + 1}월`;

  return (
    <View
      style={{
        backgroundColor: fortuneTheme.colors.surface,
        borderRadius: fortuneTheme.radius.card,
        padding: 12,
      }}
    >
      {/* Month / Year header — 레이블 탭하면 연도 그리드로 전환 (iOS 캘린더와 동일) */}
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
          disabled={mode === 'year'}
          hitSlop={12}
          onPress={goToPrevMonth}
          style={({ pressed }) => ({
            opacity: mode === 'year' ? 0.3 : pressed ? 0.5 : 1,
          })}
        >
          <Ionicons
            color={fortuneTheme.colors.textSecondary}
            name="chevron-back"
            size={20}
          />
        </Pressable>

        <Pressable
          accessibilityLabel={mode === 'month' ? '연도 선택 열기' : '월 보기로 돌아가기'}
          accessibilityRole="button"
          hitSlop={8}
          onPress={handleToggleMode}
          style={({ pressed }) => ({
            alignItems: 'center',
            flexDirection: 'row',
            gap: 4,
            opacity: pressed ? 0.6 : 1,
          })}
        >
          <AppText variant="heading4">{monthLabel}</AppText>
          <Ionicons
            color={fortuneTheme.colors.textSecondary}
            name={mode === 'month' ? 'chevron-down' : 'chevron-up'}
            size={16}
          />
        </Pressable>

        <Pressable
          accessibilityLabel="다음 달"
          accessibilityRole="button"
          disabled={mode === 'year'}
          hitSlop={12}
          onPress={goToNextMonth}
          style={({ pressed }) => ({
            opacity: mode === 'year' ? 0.3 : pressed ? 0.5 : 1,
          })}
        >
          <Ionicons
            color={fortuneTheme.colors.textSecondary}
            name="chevron-forward"
            size={20}
          />
        </Pressable>
      </View>

      {mode === 'year' ? (
        <ScrollView
          ref={yearScrollRef}
          style={{ maxHeight: YEAR_CELL_HEIGHT * 6 }}
          showsVerticalScrollIndicator={false}
        >
          <View
            style={{
              flexDirection: 'row',
              flexWrap: 'wrap',
              paddingVertical: 4,
            }}
          >
            {years.map((year) => {
              const isSelected = year === viewYear;
              const isCurrent = year === today.getFullYear();
              return (
                <View
                  key={year}
                  style={{
                    alignItems: 'center',
                    height: YEAR_CELL_HEIGHT,
                    justifyContent: 'center',
                    width: `${100 / YEAR_GRID_COLS}%`,
                  }}
                >
                  <Pressable
                    accessibilityLabel={`${year}년`}
                    accessibilityRole="button"
                    onPress={() => handlePickYear(year)}
                    // HIG 44pt 확보. (W11)
                    hitSlop={{ top: 4, bottom: 4, left: 4, right: 4 }}
                    style={({ pressed }) => ({
                      alignItems: 'center',
                      backgroundColor: isSelected
                        ? fortuneTheme.colors.ctaBackground
                        : 'transparent',
                      borderColor:
                        isCurrent && !isSelected
                          ? fortuneTheme.colors.ctaBackground
                          : 'transparent',
                      borderRadius: 999,
                      borderWidth: isCurrent && !isSelected ? 1 : 0,
                      height: 36,
                      justifyContent: 'center',
                      opacity: pressed ? 0.6 : 1,
                      paddingHorizontal: 10,
                      minWidth: 64,
                    })}
                  >
                    <AppText
                      variant="bodySmall"
                      color={
                        isSelected
                          ? fortuneTheme.colors.ctaForeground
                          : fortuneTheme.colors.textPrimary
                      }
                    >
                      {year}
                    </AppText>
                  </Pressable>
                </View>
              );
            })}
          </View>
        </ScrollView>
      ) : (
        <>
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
                // HIG 44pt 확보 — 셀 시각 36×36 유지, hitSlop 4. (W11)
                hitSlop={{ top: 4, bottom: 4, left: 4, right: 4 }}
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
        </>
      )}
    </View>
  );
}
