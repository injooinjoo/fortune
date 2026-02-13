import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhoneAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Send OTP to phone number
  Future<void> sendOTP(
      {required String phoneNumber, required String countryCode}) async {
    try {
      // Format phone number with country code
      final formattedPhone = formatPhoneNumber(phoneNumber, countryCode);

      await _client.auth.signInWithOtp(phone: formattedPhone);

      debugPrint('OTP sent successfully');
    } catch (e) {
      debugPrint('Error sending OTP: $e');
      throw _handleAuthError(e);
    }
  }

  /// Verify OTP and complete phone authentication
  Future<AuthResponse> verifyOTP(
      {required String phoneNumber,
      required String countryCode,
      required String otpCode}) async {
    try {
      final formattedPhone = formatPhoneNumber(phoneNumber, countryCode);

      final response = await _client.auth
          .verifyOTP(type: OtpType.sms, phone: formattedPhone, token: otpCode);

      debugPrint('Phone verification successful');
      return response;
    } catch (e) {
      debugPrint('Error verifying OTP: $e');
      throw _handleAuthError(e);
    }
  }

  /// Link phone number to existing account
  Future<void> linkPhoneToAccount(
      {required String phoneNumber, required String countryCode}) async {
    try {
      final formattedPhone = formatPhoneNumber(phoneNumber, countryCode);

      // First send OTP
      await _client.auth.updateUser(UserAttributes(phone: formattedPhone));

      debugPrint('Phone link initiated successfully');
    } catch (e) {
      debugPrint('Error linking phone: $e');
      throw _handleAuthError(e);
    }
  }

  /// Check if phone number is already registered
  Future<bool> isPhoneRegistered(
      {required String phoneNumber, required String countryCode}) async {
    try {
      final formattedPhone = formatPhoneNumber(phoneNumber, countryCode);

      // Query user_profiles table to check if phone exists
      final response = await _client
          .from('user_profiles')
          .select('id')
          .eq('phone', formattedPhone)
          .maybeSingle();

      return response != null;
    } catch (e) {
      debugPrint('Error checking phone registration: $e');
      return false;
    }
  }

  /// Update phone number in user profile
  Future<void> updateProfilePhone(
      {required String userId,
      required String phoneNumber,
      required String countryCode}) async {
    try {
      final formattedPhone = formatPhoneNumber(phoneNumber, countryCode);

      await _client.from('user_profiles').update({
        'phone': formattedPhone,
        'phone_verified': true,
        'updated_at': null
      }).eq('id', userId);

      debugPrint('Profile phone updated successfully');
    } catch (e) {
      debugPrint('Error updating profile phone: $e');
      rethrow;
    }
  }

  /// Format phone number with country code
  String formatPhoneNumber(String phoneNumber, String countryCode) {
    // Remove any non-digit characters
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Get country dial code
    final dialCode = _getDialCode(countryCode);

    // Remove leading 0 if present
    final phoneWithoutLeadingZero =
        cleanPhone.startsWith('0') ? cleanPhone.substring(1) : cleanPhone;

    // Combine country code and phone number
    return '$dialCode$phoneWithoutLeadingZero';
  }

  /// Get dial code from country code
  String _getDialCode(String countryCode) {
    final dialCodes = {
      'KR': '+82',
      'US': '+1',
      'JP': '+81',
      'CN': '+86',
      'GB': '+44',
      'FR': '+33',
      'DE': '+49',
      'IT': '+39',
      'ES': '+34',
      'AU': '+61',
      'CA': '+1',
      'BR': '+55',
      'MX': '+52',
      'IN': '+91',
      'RU': '+7',
      // Add more as needed
    };

    return dialCodes[countryCode] ?? '+1';
  }

  /// Handle authentication errors
  Exception _handleAuthError(dynamic error) {
    if (error is AuthException) {
      // Check error code first (more specific)
      final errorCode = error.code;
      if (errorCode != null) {
        switch (errorCode) {
          case 'otp_expired':
            return Exception('인증번호가 만료되었습니다. 인증번호 다시 받기를 눌러주세요');
          case 'otp_disabled':
            return Exception('OTP 인증이 비활성화되어 있습니다');
          case 'invalid_otp':
            return Exception('인증번호가 올바르지 않습니다');
        }
      }

      // Fallback to status code
      switch (error.statusCode) {
        case '400':
          if (error.message.contains('Phone number')) {
            return Exception('잘못된 전화번호 형식입니다');
          }
          if (error.message.contains('OTP') ||
              error.message.contains('Token')) {
            return Exception('인증번호가 올바르지 않습니다');
          }
          break;
        case '401':
          return Exception('인증번호가 만료되었습니다. 인증번호 다시 받기를 눌러주세요');
        case '403':
          // OTP expired or invalid token
          if (error.message.contains('expired') ||
              error.message.contains('invalid')) {
            return Exception('인증번호가 만료되었습니다. 인증번호 다시 받기를 눌러주세요');
          }
          return Exception('인증에 실패했습니다. 다시 시도해주세요');
        case '422':
          return Exception('이미 등록된 전화번호입니다');
        case '429':
          return Exception('너무 많은 요청입니다. 잠시 후 다시 시도해주세요');
      }
    }

    // Generic error fallback
    final errorString = error.toString();
    if (errorString.contains('expired') ||
        errorString.contains('otp_expired')) {
      return Exception('인증번호가 만료되었습니다. 인증번호 다시 받기를 눌러주세요');
    }

    return Exception('인증 중 오류가 발생했습니다. 다시 시도해주세요');
  }
}
