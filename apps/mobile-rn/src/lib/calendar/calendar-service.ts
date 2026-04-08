import { Platform } from 'react-native';
import * as Calendar from 'expo-calendar';

export interface CalendarPermissionSnapshot {
  granted: boolean;
  canAskAgain: boolean;
  status: Calendar.PermissionStatus;
}

export interface CalendarSummary {
  id: string;
  title: string;
  calendarId: string;
  calendarTitle: string | null;
  startDate: string;
  endDate: string;
  location: string | null;
  notes: string | null;
  allDay: boolean;
  timeZone: string | null;
  status: Calendar.EventStatus | null;
  availability: Calendar.Availability | null;
  durationMinutes: number;
  isBusy: boolean;
}

export interface ScheduleContext {
  targetDate: string;
  timezone: string;
  calendarCount: number;
  eventCount: number;
  allDayCount: number;
  busyEventCount: number;
  totalBusyMinutes: number;
  calendarTitles: string[];
  events: CalendarSummary[];
  hasAllDayEvent: boolean;
  nextEventAt: string | null;
  lastEventEndsAt: string | null;
}

export interface CalendarEventRangeOptions {
  calendarIds?: string[];
  entityType?: Calendar.EntityTypes;
}

export interface CalendarDayQueryOptions extends CalendarEventRangeOptions {
  includeAllCalendars?: boolean;
}

function toIsoString(value: Date | string) {
  return value instanceof Date ? value.toISOString() : value;
}

function startOfLocalDay(date: Date) {
  return new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
    0,
    0,
    0,
    0,
  );
}

function endOfLocalDay(date: Date) {
  return new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
    23,
    59,
    59,
    999,
  );
}

function normalizeDate(input: Date | string) {
  const date = input instanceof Date ? new Date(input.getTime()) : new Date(input);
  return Number.isNaN(date.getTime()) ? null : date;
}

function getCalendarTitle(calendar: Calendar.Calendar | undefined) {
  return calendar?.title?.trim() || calendar?.name?.trim() || null;
}

function isBusyAvailability(
  availability: Calendar.Availability | null | undefined,
) {
  return availability === null
    ? true
    : availability === Calendar.Availability.BUSY ||
        availability === Calendar.Availability.UNAVAILABLE;
}

function getEventDurationMinutes(startDate: Date, endDate: Date) {
  const diff = endDate.getTime() - startDate.getTime();
  if (!Number.isFinite(diff) || diff <= 0) {
    return 0;
  }

  return Math.round(diff / 60000);
}

function resolveCalendarEntityType(entityType?: Calendar.EntityTypes) {
  return entityType ?? Calendar.EntityTypes.EVENT;
}

export async function getCalendarPermissions(): Promise<CalendarPermissionSnapshot> {
  const permission = await Calendar.getCalendarPermissionsAsync();

  return {
    granted: permission.granted,
    canAskAgain: permission.canAskAgain,
    status: permission.status,
  };
}

export async function requestCalendarPermissions(): Promise<CalendarPermissionSnapshot> {
  const current = await getCalendarPermissions();
  if (current.granted || !current.canAskAgain) {
    return current;
  }

  const requested = await Calendar.requestCalendarPermissionsAsync();

  return {
    granted: requested.granted,
    canAskAgain: requested.canAskAgain,
    status: requested.status,
  };
}

export async function getDeviceCalendars(
  entityType?: Calendar.EntityTypes,
): Promise<Calendar.Calendar[]> {
  return Calendar.getCalendarsAsync(resolveCalendarEntityType(entityType));
}

async function resolveCalendarTitleMap(
  options: CalendarEventRangeOptions,
  events: Calendar.Event[],
) {
  const calendarIds = options.calendarIds?.length
    ? options.calendarIds
    : Array.from(new Set(events.map((event) => event.calendarId)));

  if (calendarIds.length === 0) {
    return new Map<string, string | null>();
  }

  const calendars = await getDeviceCalendars(options.entityType);
  const filteredCalendars = options.calendarIds?.length
    ? calendars.filter((calendar) => calendarIds.includes(calendar.id))
    : calendars;

  return new Map(
    filteredCalendars.map((calendar) => [calendar.id, getCalendarTitle(calendar)]),
  );
}

export async function getDeviceCalendarEventsForRange(
  startDate: Date,
  endDate: Date,
  options: CalendarEventRangeOptions = {},
) {
  const calendarIds = options.calendarIds;
  if (!calendarIds || calendarIds.length === 0) {
    const calendars = await getDeviceCalendars(options.entityType);
    const ids = calendars.map((calendar) => calendar.id);
    if (ids.length === 0) {
      return [];
    }

    return Calendar.getEventsAsync(ids, startDate, endDate);
  }

  return Calendar.getEventsAsync(calendarIds, startDate, endDate);
}

export async function getDeviceCalendarEventsForDate(
  date: Date,
  options: CalendarDayQueryOptions = {},
) {
  const normalizedDate = normalizeDate(date);
  if (!normalizedDate) {
    return [];
  }

  return getDeviceCalendarEventsForRange(
    startOfLocalDay(normalizedDate),
    endOfLocalDay(normalizedDate),
    options,
  );
}

export function summarizeCalendarEvent(
  event: Calendar.Event,
  calendarTitle?: string | null,
): CalendarSummary {
  const startDate = normalizeDate(event.startDate);
  const endDate = normalizeDate(event.endDate);
  const safeStartDate = startDate ?? new Date(event.startDate);
  const safeEndDate = endDate ?? new Date(event.endDate);

  return {
    id: event.id,
    title: event.title?.trim() || '일정',
    calendarId: event.calendarId,
    calendarTitle: calendarTitle ?? null,
    startDate: toIsoString(safeStartDate),
    endDate: toIsoString(safeEndDate),
    location: event.location?.trim() || null,
    notes: event.notes?.trim() || null,
    allDay: event.allDay,
    timeZone: event.timeZone?.trim() || null,
    status: event.status ?? null,
    availability: event.availability ?? null,
    durationMinutes: getEventDurationMinutes(safeStartDate, safeEndDate),
    isBusy: isBusyAvailability(event.availability),
  };
}

export async function getEventSummariesForDate(
  date: Date,
  options: CalendarDayQueryOptions = {},
): Promise<CalendarSummary[]> {
  const events = await getDeviceCalendarEventsForDate(date, options);
  const calendarTitleMap = await resolveCalendarTitleMap(options, events);

  return events
    .map((event) =>
      summarizeCalendarEvent(event, calendarTitleMap.get(event.calendarId)),
    )
    .sort((left, right) => left.startDate.localeCompare(right.startDate));
}

export async function getEventSummariesForRange(
  startDate: Date,
  endDate: Date,
  options: CalendarEventRangeOptions = {},
): Promise<CalendarSummary[]> {
  const events = await getDeviceCalendarEventsForRange(startDate, endDate, options);
  const calendarTitleMap = await resolveCalendarTitleMap(options, events);

  return events
    .map((event) =>
      summarizeCalendarEvent(event, calendarTitleMap.get(event.calendarId)),
    )
    .sort((left, right) => left.startDate.localeCompare(right.startDate));
}

export function extractScheduleContext(
  events: CalendarSummary[],
  targetDate: Date,
): ScheduleContext {
  const sortedEvents = [...events].sort((left, right) =>
    left.startDate.localeCompare(right.startDate),
  );
  const uniqueCalendarIds = new Set(sortedEvents.map((event) => event.calendarId));
  const calendarTitles = Array.from(
    new Set(
      sortedEvents
        .map((event) => event.calendarTitle)
        .filter((value): value is string => Boolean(value)),
    ),
  );

  const busyEvents = sortedEvents.filter((event) => event.isBusy);
  const allDayCount = sortedEvents.filter((event) => event.allDay).length;
  const totalBusyMinutes = busyEvents.reduce(
    (total, event) => total + event.durationMinutes,
    0,
  );
  const nextEventAt = sortedEvents[0]?.startDate ?? null;
  const lastEventEndsAt = sortedEvents.at(-1)?.endDate ?? null;

  return {
    targetDate: toIsoString(targetDate),
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || Platform.OS,
    calendarCount: uniqueCalendarIds.size,
    eventCount: sortedEvents.length,
    allDayCount,
    busyEventCount: busyEvents.length,
    totalBusyMinutes,
    calendarTitles,
    events: sortedEvents,
    hasAllDayEvent: allDayCount > 0,
    nextEventAt,
    lastEventEndsAt,
  };
}

export async function buildScheduleContextForDate(
  date: Date,
  options: CalendarDayQueryOptions = {},
): Promise<ScheduleContext> {
  const events = await getEventSummariesForDate(date, options);
  return extractScheduleContext(events, date);
}
