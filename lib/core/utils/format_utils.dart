import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Formatting utilities following Toss design system
/// Provides consistent formatting for dates, times, numbers, and currency
class FormatUtils {
  // Date formatters
  static final DateFormat _dateFormatFull = DateFormat('yyyy년 M월 d일', 'ko_KR');
  static final DateFormat _dateFormatMedium = DateFormat('M월 d일', 'ko_KR');
  static final DateFormat _dateFormatShort = DateFormat('M/d', 'ko_KR');
  static final DateFormat _dateFormatWeekday = DateFormat('EEEE', 'ko_KR');
  
  // Time formatters
  static final DateFormat _timeFormat24 = DateFormat('HH:mm', 'ko_KR');
  static final DateFormat _timeFormat12 = DateFormat('h:mm', 'ko_KR');
  static final DateFormat _timeFormatSeconds = DateFormat('HH:mm:ss', 'ko_KR');
  
  // Number formatters
  static final NumberFormat _numberFormat = NumberFormat('#,###', 'ko_KR');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.0#', 'ko_KR');
  static final NumberFormat _percentFormat = NumberFormat.percentPattern('ko_KR');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ko_KR',
    symbol: '₩',
    decimalDigits: 0
  );
  
  /// Format date based on context and relative time
  static String formatDate(DateTime date, {bool showYear = true}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    // Today
    if (dateOnly == today) {
      return '오늘';
    }
    
    // Yesterday
    if (dateOnly == yesterday) {
      return '어제';
    }
    
    // This week (within 7 days,
    if (dateOnly.isAfter(today.subtract(const Duration(days: 7))) && 
        dateOnly.isBefore(today)) {
      return _dateFormatWeekday.format(date);
    }
    
    // This year
    if (date.year == now.year && !showYear) {
      return _dateFormatMedium.format(date);
    }
    
    // Other dates
    return _dateFormatFull.format(date);
  }
  
  /// Format relative time (e.g., "3분 전", "1시간 전",
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return '방금';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks주 전';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months개월 전';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years년 전';
    }
  }
  
  /// Format time (24-hour or 12-hour based on settings,
  static String formatTime(DateTime time, {bool use24Hour = true}) {
    if (use24Hour) {
      return _timeFormat24.format(time);
    } else {
      return _timeFormat12.format(time);
    }
  }
  
  /// Format time with seconds
  static String formatTimeWithSeconds(DateTime time) {
    return _timeFormatSeconds.format(time);
  }
  
  /// Format number with thousand separators
  static String formatNumber(num number) {
    return _numberFormat.format(number);
  }
  
  /// Format decimal number (max 2 decimal places,
  static String formatDecimal(double number, {int? decimalPlaces}) {
    if (decimalPlaces != null) {
      return number.toStringAsFixed(decimalPlaces);
    }
    return _decimalFormat.format(number);
  }
  
  /// Format large numbers with abbreviations (K, M, B,
  static String formatCompactNumber(num number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(1)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 10000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return formatNumber(number);
  }
  
  /// Format currency (Korean Won,
  static String formatCurrency(num amount) {
    if (amount >= 100000000) {
      // 억원 단위
      final billions = amount / 100000000;
      if (billions == billions.toInt()) {
        return '${billions.toInt()}억원';
      }
      return '${billions.toStringAsFixed(1)}억원';
    } else if (amount >= 10000) {
      // 만원 단위
      final tenThousands = amount / 10000;
      if (tenThousands == tenThousands.toInt()) {
        return '${tenThousands.toInt()}만원';
      }
      return '${tenThousands.toStringAsFixed(1)}만원';
    }
    return _currencyFormat.format(amount);
  }
  
  /// Format percentage
  static String formatPercent(double value, {int decimalPlaces = 0}) {
    if (decimalPlaces == 0) {
      return '${(value * 100).round()}%';
    }
    return '${(value * 100).toStringAsFixed(decimalPlaces)}%';
  }
  
  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
  
  /// Format duration (e.g., "1:23:45" or "23:45",
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Format phone number (Korean format,
  static String formatPhoneNumber(String phoneNumber) {
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleaned.length == 11) {
      // 010-1234-5678
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    } else if (cleaned.length == 10) {
      // 02-1234-5678 or 031-123-4567
      if (cleaned.startsWith('02')) {
        return '${cleaned.substring(0, 2)}-${cleaned.substring(2, 6)}-${cleaned.substring(6)}';
      }
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    return phoneNumber;
  }
  
  /// Format birth date (YYYY-MM-DD,
  static String formatBirthDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  /// Format month and year (e.g., "2024년 1월",
  static String formatMonthYear(DateTime date) {
    return DateFormat('yyyy년 M월', 'ko_KR').format(date);
  }
  
  /// Format day of week (e.g., "월요일",
  static String formatDayOfWeek(DateTime date) {
    return _dateFormatWeekday.format(date);
  }
  
  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && 
           date.month == yesterday.month && 
           date.day == yesterday.day;
  }
}