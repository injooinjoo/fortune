// 기존 HomeScreen 백업 파일
// 필요시 복원 가능

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/fortune.dart' as fortune_entity;
import '../../domain/entities/user_profile.dart';
import '../../presentation/widgets/daily_fortune_summary_card.dart' as summary_card;
import '../../presentation/widgets/fortune_card.dart';
import '../../presentation/widgets/profile_completion_banner.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../presentation/providers/fortune_provider.dart';
import '../../presentation/providers/recommendation_provider.dart';
import '../../presentation/screens/ad_loading_screen.dart';
import '../../services/cache_service.dart';
import '../../services/storage_service.dart';
import '../../models/fortune_model.dart';
import '../../core/theme/app_colors.dart';
import 'fortune_story_viewer.dart';
import '../../services/weather_service.dart';
import '../../presentation/providers/fortune_story_provider.dart';

// 기존 HomeScreen 전체 코드는 home_screen_backup.dart에 보관됨