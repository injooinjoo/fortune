import { useCallback, useEffect, useRef, useState } from 'react';

import { router } from 'expo-router';
import { TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import {
  formatKoreanPhone,
  signInWithPhone,
  verifyPhoneOtp,
} from '../lib/email-phone-auth';
import { captureError } from '../lib/error-reporting';
import { authSuccess } from '../lib/haptics';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

type Step = 'phone' | 'otp';

const OTP_TIMEOUT_SECONDS = 180;

const INPUT_STYLE = {
  backgroundColor: fortuneTheme.colors.surfaceSecondary,
  borderRadius: fortuneTheme.radius.md,
  borderWidth: 1,
  borderColor: fortuneTheme.colors.border,
  color: fortuneTheme.colors.textPrimary,
  fontSize: 15,
  paddingHorizontal: 16,
  paddingVertical: 14,
} as const;

function formatTimer(seconds: number): string {
  const min = Math.floor(seconds / 60);
  const sec = seconds % 60;
  return `${min}:${sec.toString().padStart(2, '0')}`;
}

export function PhoneAuthScreen() {
  const { markAuthComplete } = useAppBootstrap();
  const [step, setStep] = useState<Step>('phone');
  const [phone, setPhone] = useState('');
  const [formattedPhone, setFormattedPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [remainingSeconds, setRemainingSeconds] = useState(0);
  const timerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const isPhoneValid = phone.replace(/[^0-9]/g, '').length >= 10;
  const isOtpValid = otp.replace(/[^0-9]/g, '').length === 6;

  const clearTimer = useCallback(() => {
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
  }, []);

  const startTimer = useCallback(() => {
    clearTimer();
    setRemainingSeconds(OTP_TIMEOUT_SECONDS);

    timerRef.current = setInterval(() => {
      setRemainingSeconds((prev) => {
        if (prev <= 1) {
          clearTimer();
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  }, [clearTimer]);

  useEffect(() => {
    return clearTimer;
  }, [clearTimer]);

  async function handleSendOtp() {
    if (!isPhoneValid || isLoading) return;

    setIsLoading(true);
    setErrorMessage(null);

    try {
      const e164Phone = formatKoreanPhone(phone);
      setFormattedPhone(e164Phone);

      const result = await signInWithPhone(e164Phone);

      if (result.status === 'failed') {
        setErrorMessage(
          result.errorMessage ?? '인증 코드 발송에 실패했습니다.',
        );
        setIsLoading(false);
        return;
      }

      setStep('otp');
      setOtp('');
      startTimer();
    } catch (error) {
      await captureError(error, { surface: 'phone-auth:send-otp' });
      setErrorMessage('오류가 발생했습니다. 다시 시도해 주세요.');
    } finally {
      setIsLoading(false);
    }
  }

  async function handleVerifyOtp() {
    if (!isOtpValid || isLoading) return;

    setIsLoading(true);
    setErrorMessage(null);

    try {
      const result = await verifyPhoneOtp(formattedPhone, otp.trim());

      if (result.status === 'failed') {
        setErrorMessage(
          result.errorMessage ?? '인증에 실패했습니다.',
        );
        setIsLoading(false);
        return;
      }

      clearTimer();
      authSuccess();
      await markAuthComplete();
      router.replace('/auth/callback');
    } catch (error) {
      await captureError(error, { surface: 'phone-auth:verify-otp' });
      setErrorMessage('오류가 발생했습니다. 다시 시도해 주세요.');
    } finally {
      setIsLoading(false);
    }
  }

  async function handleResendOtp() {
    if (isLoading) return;

    setIsLoading(true);
    setErrorMessage(null);

    try {
      const result = await signInWithPhone(formattedPhone);

      if (result.status === 'failed') {
        setErrorMessage(
          result.errorMessage ?? '인증 코드 재발송에 실패했습니다.',
        );
        setIsLoading(false);
        return;
      }

      setOtp('');
      startTimer();
    } catch (error) {
      await captureError(error, { surface: 'phone-auth:resend-otp' });
      setErrorMessage('오류가 발생했습니다. 다시 시도해 주세요.');
    } finally {
      setIsLoading(false);
    }
  }

  function handleBackToPhone() {
    clearTimer();
    setStep('phone');
    setOtp('');
    setErrorMessage(null);
  }

  return (
    <Screen
      keyboardAvoiding
      header={<RouteBackHeader fallbackHref="/signup" label="로그인 및 시작" />}
    >
      <AppText variant="displaySmall">전화번호로 시작</AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        {step === 'phone'
          ? '전화번호를 입력하면 인증 코드를 보내드립니다.'
          : '문자로 받은 6자리 인증 코드를 입력해 주세요.'}
      </AppText>

      {step === 'phone' ? (
        <Card>
          <AppText variant="heading4">전화번호 입력</AppText>

          {errorMessage ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.error}>
              {errorMessage}
            </AppText>
          ) : null}

          <View style={{ gap: fortuneTheme.spacing.sm }}>
            <AppText
              variant="labelMedium"
              color={fortuneTheme.colors.textSecondary}
            >
              전화번호
            </AppText>
            <View style={{ flexDirection: 'row', gap: fortuneTheme.spacing.sm }}>
              <View
                style={{
                  ...INPUT_STYLE,
                  alignItems: 'center',
                  justifyContent: 'center',
                  paddingHorizontal: 12,
                }}
              >
                <AppText variant="bodyMedium">+82</AppText>
              </View>
              <TextInput
                autoComplete="tel"
                autoCorrect={false}
                editable={!isLoading}
                keyboardType="phone-pad"
                onChangeText={setPhone}
                placeholder="01012345678"
                placeholderTextColor={fortuneTheme.colors.textTertiary}
                style={[INPUT_STYLE, { flex: 1 }]}
                textContentType="telephoneNumber"
                value={phone}
              />
            </View>
            <AppText
              variant="caption"
              color={fortuneTheme.colors.textTertiary}
            >
              한국 전화번호만 지원됩니다. 앞자리 0은 자동으로 처리됩니다.
            </AppText>
          </View>

          <PrimaryButton
            disabled={!isPhoneValid || isLoading}
            onPress={() => void handleSendOtp()}
          >
            {isLoading ? '발송 중...' : '인증 코드 받기'}
          </PrimaryButton>
        </Card>
      ) : (
        <Card>
          <AppText variant="heading4">인증 코드 입력</AppText>
          <AppText
            variant="bodySmall"
            color={fortuneTheme.colors.textSecondary}
          >
            {formattedPhone}로 발송된 코드를 입력해 주세요.
          </AppText>

          {errorMessage ? (
            <AppText variant="bodySmall" color={fortuneTheme.colors.error}>
              {errorMessage}
            </AppText>
          ) : null}

          <View style={{ gap: fortuneTheme.spacing.sm }}>
            <AppText
              variant="labelMedium"
              color={fortuneTheme.colors.textSecondary}
            >
              인증 코드 (6자리)
            </AppText>
            <TextInput
              autoComplete="one-time-code"
              autoCorrect={false}
              autoFocus
              editable={!isLoading}
              keyboardType="number-pad"
              maxLength={6}
              onChangeText={setOtp}
              placeholder="000000"
              placeholderTextColor={fortuneTheme.colors.textTertiary}
              style={[INPUT_STYLE, { letterSpacing: 8, textAlign: 'center', fontSize: 24 }]}
              textContentType="oneTimeCode"
              value={otp}
            />
          </View>

          {remainingSeconds > 0 ? (
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.textSecondary}
              style={{ textAlign: 'center' }}
            >
              남은 시간: {formatTimer(remainingSeconds)}
            </AppText>
          ) : (
            <AppText
              variant="bodySmall"
              color={fortuneTheme.colors.error}
              style={{ textAlign: 'center' }}
            >
              인증 코드가 만료되었습니다. 다시 요청해 주세요.
            </AppText>
          )}

          <PrimaryButton
            disabled={!isOtpValid || isLoading || remainingSeconds === 0}
            onPress={() => void handleVerifyOtp()}
          >
            {isLoading ? '확인 중...' : '인증하기'}
          </PrimaryButton>

          <PrimaryButton
            disabled={isLoading}
            onPress={() => void handleResendOtp()}
            tone="secondary"
          >
            인증 코드 다시 받기
          </PrimaryButton>

          <PrimaryButton
            onPress={handleBackToPhone}
            tone="secondary"
          >
            전화번호 다시 입력
          </PrimaryButton>
        </Card>
      )}
    </Screen>
  );
}
