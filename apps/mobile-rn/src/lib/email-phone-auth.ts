import { supabase } from './supabase';

export interface AuthResult {
  status: 'success' | 'failed';
  errorMessage?: string;
}

function resolveKoreanErrorMessage(error: unknown): string {
  if (error && typeof error === 'object' && 'message' in error) {
    const message = String((error as { message: string }).message);

    if (message.includes('Invalid login credentials')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }

    if (message.includes('User already registered')) {
      return '이미 가입된 이메일입니다.';
    }

    if (message.includes('Email not confirmed')) {
      return '이메일 인증이 완료되지 않았습니다. 메일함을 확인해 주세요.';
    }

    if (message.includes('Password should be at least')) {
      return '비밀번호는 6자 이상이어야 합니다.';
    }

    if (message.includes('known to be weak') || message.includes('choose a different')) {
      return '약한 비밀번호입니다. 영문, 숫자, 특수문자를 조합해 주세요.';
    }

    if (message.includes('Unable to validate email address')) {
      return '올바른 이메일 주소를 입력해 주세요.';
    }

    if (message.includes('Token has expired')) {
      return '인증 코드가 만료되었습니다. 다시 요청해 주세요.';
    }

    if (message.includes('Invalid OTP') || message.includes('Token is invalid')) {
      return '인증 코드가 올바르지 않습니다.';
    }

    if (message.includes('rate limit') || message.includes('too many requests')) {
      return '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.';
    }

    if (message.includes('Database error') || message.includes('querying schema')) {
      return '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해 주세요.';
    }

    return message;
  }

  return '알 수 없는 오류가 발생했습니다.';
}

export async function signUpWithEmail(
  email: string,
  password: string,
): Promise<AuthResult> {
  if (!supabase) {
    return {
      status: 'failed',
      errorMessage: 'Supabase 환경이 아직 설정되지 않았습니다.',
    };
  }

  try {
    const { error } = await supabase.auth.signUp({ email, password });

    if (error) {
      return {
        status: 'failed',
        errorMessage: resolveKoreanErrorMessage(error),
      };
    }

    return { status: 'success' };
  } catch (error) {
    return {
      status: 'failed',
      errorMessage: resolveKoreanErrorMessage(error),
    };
  }
}

export async function signInWithEmail(
  email: string,
  password: string,
): Promise<AuthResult> {
  if (!supabase) {
    return {
      status: 'failed',
      errorMessage: 'Supabase 환경이 아직 설정되지 않았습니다.',
    };
  }

  try {
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return {
        status: 'failed',
        errorMessage: resolveKoreanErrorMessage(error),
      };
    }

    return { status: 'success' };
  } catch (error) {
    return {
      status: 'failed',
      errorMessage: resolveKoreanErrorMessage(error),
    };
  }
}

export async function signInWithPhone(phone: string): Promise<AuthResult> {
  if (!supabase) {
    return {
      status: 'failed',
      errorMessage: 'Supabase 환경이 아직 설정되지 않았습니다.',
    };
  }

  try {
    const { error } = await supabase.auth.signInWithOtp({ phone });

    if (error) {
      return {
        status: 'failed',
        errorMessage: resolveKoreanErrorMessage(error),
      };
    }

    return { status: 'success' };
  } catch (error) {
    return {
      status: 'failed',
      errorMessage: resolveKoreanErrorMessage(error),
    };
  }
}

export async function verifyPhoneOtp(
  phone: string,
  token: string,
): Promise<AuthResult> {
  if (!supabase) {
    return {
      status: 'failed',
      errorMessage: 'Supabase 환경이 아직 설정되지 않았습니다.',
    };
  }

  try {
    const { error } = await supabase.auth.verifyOtp({
      phone,
      token,
      type: 'sms',
    });

    if (error) {
      return {
        status: 'failed',
        errorMessage: resolveKoreanErrorMessage(error),
      };
    }

    return { status: 'success' };
  } catch (error) {
    return {
      status: 'failed',
      errorMessage: resolveKoreanErrorMessage(error),
    };
  }
}

/**
 * Format a Korean phone number to E.164 format (+82).
 * Strips the leading 0 and prepends +82.
 * e.g. "01012345678" → "+821012345678"
 */
export function formatKoreanPhone(input: string): string {
  const digits = input.replace(/[^0-9]/g, '');

  if (digits.startsWith('0')) {
    return `+82${digits.slice(1)}`;
  }

  if (digits.startsWith('82')) {
    return `+${digits}`;
  }

  return `+82${digits}`;
}
