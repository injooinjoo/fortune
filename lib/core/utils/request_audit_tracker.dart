import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'logger.dart';

class RequestAuditTracker {
  RequestAuditTracker._();

  static final Map<String, _RequestAuditEntry> _entries = {};

  static void record({
    required String key,
    required String trigger,
    required String source,
  }) {
    if (!kDebugMode) return;

    final now = DateTime.now();
    final entry = _entries.putIfAbsent(
      key,
      () => _RequestAuditEntry(
        count: 0,
        triggers: <String>{},
        sources: <String>{},
        lastRecordedAt: now,
      ),
    );

    entry.count += 1;
    entry.triggers.add(trigger);
    entry.sources.add(source);
    entry.lastRecordedAt = now;

    if (entry.count <= 3 || entry.count % 5 == 0) {
      Logger.debug(
        '[RequestAudit] $key x${entry.count}',
        {
          'trigger': trigger,
          'source': source,
        },
      );
    }
  }

  static void reset() {
    if (!kDebugMode) return;
    _entries.clear();
  }

  static Map<String, RequestAuditSnapshot> snapshot() {
    if (!kDebugMode) return const <String, RequestAuditSnapshot>{};

    final snapshot = _entries.map(
      (key, entry) => MapEntry(
        key,
        RequestAuditSnapshot(
          count: entry.count,
          triggers: entry.triggers.toList()..sort(),
          sources: entry.sources.toList()..sort(),
          lastRecordedAt: entry.lastRecordedAt,
        ),
      ),
    );

    return UnmodifiableMapView(snapshot);
  }

  static void debugPrintSummary() {
    if (!kDebugMode || _entries.isEmpty) return;

    final sortedEntries = _entries.entries.toList()
      ..sort((a, b) => b.value.count.compareTo(a.value.count));

    for (final entry in sortedEntries) {
      Logger.debug(
        '[RequestAudit] ${entry.key} summary',
        {
          'count': entry.value.count,
          'triggers': entry.value.triggers.toList()..sort(),
          'sources': entry.value.sources.toList()..sort(),
          'lastRecordedAt': entry.value.lastRecordedAt.toIso8601String(),
        },
      );
    }
  }
}

class _RequestAuditEntry {
  int count;
  final Set<String> triggers;
  final Set<String> sources;
  DateTime lastRecordedAt;

  _RequestAuditEntry({
    required this.count,
    required this.triggers,
    required this.sources,
    required this.lastRecordedAt,
  });
}

@immutable
class RequestAuditSnapshot {
  final int count;
  final List<String> triggers;
  final List<String> sources;
  final DateTime lastRecordedAt;

  const RequestAuditSnapshot({
    required this.count,
    required this.triggers,
    required this.sources,
    required this.lastRecordedAt,
  });
}
