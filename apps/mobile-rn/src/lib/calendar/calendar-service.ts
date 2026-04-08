import { Platform } from 'react-native';

import { requireOptionalNativeModule } from 'expo-modules-core';

type CalendarModule = typeof import('expo-calendar');

let calendarNativeModuleAvailable: boolean | null = null;

export interface CalendarEventSummary {
  id: string;
  title: string;
  startDate: string | null;
  endDate: string | null;
  isAllDay: boolean;
  location: string | null;
  notes: string | null;
  calendarTitle: string | null;
}

export interface CalendarSyncContext {
  targetDate: string;
  eventCount: number;
  summary: string;
  tags: string[];
  events: CalendarEventSummary[];
}

function normalizeDate(date: string | Date) {
  if (typeof date === 'string') {
    return new Date(`${date}T00:00:00`);
  }

  return new Date(date.getFullYear(), date.getMonth(), date.getDate());
}

function startOfDay(date: Date) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0);
}

function endOfDay(date: Date) {
  return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 23, 59, 59, 999);
}

function formatDateKey(date: Date) {
  return [
    date.getFullYear(),
    String(date.getMonth() + 1).padStart(2, '0'),
    String(date.getDate()).padStart(2, '0'),
  ].join('-');
}

function normalizeEventDateValue(value: string | Date | null | undefined) {
  if (value instanceof Date) {
    return value.toISOString();
  }

  return typeof value === 'string' ? value : null;
}

function formatEventTime(value: string | Date | null, isAllDay: boolean) {
  if (!value || isAllDay) {
    return isAllDay ? '하루 일정' : null;
  }

  const date = new Date(value);
  return `${String(date.getHours()).padStart(2, '0')}:${String(
    date.getMinutes(),
  ).padStart(2, '0')}`;
}

class CalendarService {
  private calendarModulePromise: Promise<CalendarModule | null> | null = null;

  private async loadCalendarModule() {
    if (Platform.OS === 'web') {
      return null;
    }

    if (calendarNativeModuleAvailable === null) {
      calendarNativeModuleAvailable = Boolean(
        requireOptionalNativeModule('ExpoCalendar'),
      );
    }

    if (!calendarNativeModuleAvailable) {
      return null;
    }

    if (this.calendarModulePromise) {
      return this.calendarModulePromise;
    }

    this.calendarModulePromise = import('expo-calendar').catch(() => null);
    return this.calendarModulePromise;
  }

  async requestPermissions() {
    const calendar = await this.loadCalendarModule();
    if (!calendar) {
      return 'denied';
    }

    const existing = await calendar.getCalendarPermissionsAsync();
    if (existing.granted) {
      return existing.status;
    }

    const requested = await calendar.requestCalendarPermissionsAsync();
    return requested.status;
  }

  async getEventsForDate(date: string | Date) {
    const permissionStatus = await this.requestPermissions();
    if (permissionStatus !== 'granted') {
      return [] as CalendarEventSummary[];
    }

    const calendar = await this.loadCalendarModule();
    if (!calendar) {
      return [] as CalendarEventSummary[];
    }

    const targetDate = normalizeDate(date);
    const calendars = await calendar.getCalendarsAsync(calendar.EntityTypes.EVENT);
    const calendarIds = calendars.map((item) => item.id);
    if (calendarIds.length === 0) {
      return [] as CalendarEventSummary[];
    }

    const events = await calendar.getEventsAsync(
      calendarIds,
      startOfDay(targetDate),
      endOfDay(targetDate),
    );
    const calendarTitleById = new Map(calendars.map((item) => [item.id, item.title]));

    return events
      .sort(
        (left, right) =>
          new Date(left.startDate).getTime() - new Date(right.startDate).getTime(),
      )
      .map((event) => ({
        id: event.id,
        title: event.title ?? '제목 없는 일정',
        startDate: normalizeEventDateValue(event.startDate),
        endDate: normalizeEventDateValue(event.endDate),
        isAllDay: event.allDay ?? false,
        location: event.location ?? null,
        notes: event.notes ?? null,
        calendarTitle: event.calendarId
          ? calendarTitleById.get(event.calendarId) ?? null
          : null,
      }));
  }

  async buildCalendarSyncContext(date: string | Date): Promise<CalendarSyncContext | null> {
    const permissionStatus = await this.requestPermissions();
    if (permissionStatus !== 'granted') {
      return null;
    }

    const targetDate = normalizeDate(date);
    const events = await this.getEventsForDate(targetDate);
    const summary =
      events.length === 0
        ? '일정이 없는 날이라 하루 리듬 자체에 더 집중해 해석합니다.'
        : `${events.length}개의 일정이 있어요. 가장 밀도 높은 시간대를 함께 반영합니다.`;
    const tags = events.slice(0, 3).map((event) => {
      const time = formatEventTime(event.startDate, event.isAllDay);
      return time ? `${time} ${event.title}` : event.title;
    });

    return {
      targetDate: formatDateKey(targetDate),
      eventCount: events.length,
      summary,
      tags,
      events,
    };
  }

  async getUpcomingDateOptions(days = 7) {
    const today = startOfDay(new Date());
    const entries = await Promise.all(
      Array.from({ length: days }, (_, offset) => {
        const targetDate = new Date(today);
        targetDate.setDate(today.getDate() + offset);
        return this.buildCalendarSyncContext(targetDate);
      }),
    );

    return entries.filter((entry): entry is CalendarSyncContext => entry !== null);
  }
}

export const calendarService = new CalendarService();
