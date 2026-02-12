import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 열려있는 캐릭터 채팅방 ID 추적
///
/// - null: 채팅방 안열림 (알림 O, 진동 O)
/// - characterId: 해당 채팅방 열림 (알림 X, 진동 X)
///
/// 카카오톡처럼 채팅방에 있을 때는 푸시/진동이 오지 않도록 함
final activeCharacterChatProvider = StateProvider<String?>((ref) => null);
