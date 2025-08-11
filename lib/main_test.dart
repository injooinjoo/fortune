import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 최소한의 초기화만
  await dotenv.dotenv.load(fileName: ".env");
  await initializeDateFormatting('ko_KR', null);
  
  await Supabase.initialize(
    url: Environment.supabaseUrl,
    anonKey: Environment.supabaseAnonKey);
  
  runApp(
    const ProviderScope(
      child: TestApp()));
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fortune Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const Center(
          child: Text('테스트 화면입니다')));
  }
}