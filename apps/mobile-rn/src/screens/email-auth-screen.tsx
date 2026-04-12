import { useState } from 'react';

import { router } from 'expo-router';
import { TextInput, View } from 'react-native';

import { AppText } from '../components/app-text';
import { Card } from '../components/card';
import { PrimaryButton } from '../components/primary-button';
import { RouteBackHeader } from '../components/route-back-header';
import { Screen } from '../components/screen';
import { signInWithEmail, signUpWithEmail } from '../lib/email-phone-auth';
import { captureError } from '../lib/error-reporting';
import { authSuccess } from '../lib/haptics';
import { fortuneTheme } from '../lib/theme';
import { useAppBootstrap } from '../providers/app-bootstrap-provider';

type AuthMode = 'login' | 'signup';

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

export function EmailAuthScreen() {
  const { markAuthComplete } = useAppBootstrap();
  const [mode, setMode] = useState<AuthMode>('login');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const isSignup = mode === 'signup';
  const isFormValid = isSignup
    ? email.trim().length > 0 &&
      password.length >= 6 &&
      password === confirmPassword
    : email.trim().length > 0 && password.length >= 1;

  async function handleSubmit() {
    if (!isFormValid || isLoading) return;

    setIsLoading(true);
    setErrorMessage(null);

    try {
      if (isSignup && password !== confirmPassword) {
        setErrorMessage('비밀번호가 일치하지 않습니다.');
        setIsLoading(false);
        return;
      }

      const result = isSignup
        ? await signUpWithEmail(email.trim(), password)
        : await signInWithEmail(email.trim(), password);

      if (result.status === 'failed') {
        setErrorMessage(result.errorMessage ?? '로그인에 실패했습니다.');
        setIsLoading(false);
        return;
      }

      authSuccess();
      await markAuthComplete();
      router.replace('/auth/callback');
    } catch (error) {
      await captureError(error, { surface: 'email-auth:submit' });
      setErrorMessage('오류가 발생했습니다. 다시 시도해 주세요.');
    } finally {
      setIsLoading(false);
    }
  }

  function handleToggleMode() {
    setMode(isSignup ? 'login' : 'signup');
    setErrorMessage(null);
    setConfirmPassword('');
  }

  return (
    <Screen
      keyboardAvoiding
      header={<RouteBackHeader fallbackHref="/signup" label="로그인 및 시작" />}
    >
      <AppText variant="displaySmall">
        {isSignup ? '이메일로 가입하기' : '이메일로 로그인'}
      </AppText>
      <AppText variant="bodyLarge" color={fortuneTheme.colors.textSecondary}>
        {isSignup
          ? '이메일과 비밀번호를 입력하여 새 계정을 만듭니다.'
          : '가입한 이메일과 비밀번호를 입력해 주세요.'}
      </AppText>

      <Card>
        <AppText variant="heading4">
          {isSignup ? '계정 만들기' : '로그인'}
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
            이메일
          </AppText>
          <TextInput
            autoCapitalize="none"
            autoComplete="email"
            autoCorrect={false}
            editable={!isLoading}
            keyboardType="email-address"
            onChangeText={setEmail}
            placeholder="example@email.com"
            placeholderTextColor={fortuneTheme.colors.textTertiary}
            style={INPUT_STYLE}
            textContentType="emailAddress"
            value={email}
          />
        </View>

        <View style={{ gap: fortuneTheme.spacing.sm }}>
          <AppText
            variant="labelMedium"
            color={fortuneTheme.colors.textSecondary}
          >
            비밀번호
          </AppText>
          <TextInput
            autoCapitalize="none"
            autoComplete={isSignup ? 'new-password' : 'current-password'}
            autoCorrect={false}
            editable={!isLoading}
            onChangeText={setPassword}
            placeholder="6자 이상 입력"
            placeholderTextColor={fortuneTheme.colors.textTertiary}
            secureTextEntry
            style={INPUT_STYLE}
            textContentType={isSignup ? 'newPassword' : 'password'}
            value={password}
          />
        </View>

        {isSignup ? (
          <View style={{ gap: fortuneTheme.spacing.sm }}>
            <AppText
              variant="labelMedium"
              color={fortuneTheme.colors.textSecondary}
            >
              비밀번호 확인
            </AppText>
            <TextInput
              autoCapitalize="none"
              autoComplete="new-password"
              autoCorrect={false}
              editable={!isLoading}
              onChangeText={setConfirmPassword}
              placeholder="비밀번호를 다시 입력"
              placeholderTextColor={fortuneTheme.colors.textTertiary}
              secureTextEntry
              style={INPUT_STYLE}
              textContentType="newPassword"
              value={confirmPassword}
            />
          </View>
        ) : null}

        <PrimaryButton
          disabled={!isFormValid || isLoading}
          onPress={() => void handleSubmit()}
        >
          {isLoading
            ? '처리 중...'
            : isSignup
              ? '가입하기'
              : '로그인'}
        </PrimaryButton>

        <PrimaryButton onPress={handleToggleMode} tone="secondary">
          {isSignup
            ? '이미 계정이 있으신가요? 로그인'
            : '계정이 없으신가요? 가입하기'}
        </PrimaryButton>
      </Card>
    </Screen>
  );
}
