import Constants from 'expo-constants';

interface ExpoExtra {
  appEnv?: string;
  supabaseUrl?: string;
  supabaseAnonKey?: string;
  appDomain?: string;
  sentryDsn?: string;
  mixpanelToken?: string;
  googleWebClientId?: string;
  googleIosClientId?: string;
  googleAndroidClientId?: string;
  kakaoAppKey?: string;
}

const extra = (Constants.expoConfig?.extra ?? {}) as ExpoExtra;

export const appEnv = {
  environment: extra.appEnv ?? 'development',
  supabaseUrl: extra.supabaseUrl ?? '',
  supabaseAnonKey: extra.supabaseAnonKey ?? '',
  appDomain: extra.appDomain ?? '',
  sentryDsn: extra.sentryDsn ?? '',
  mixpanelToken: extra.mixpanelToken ?? '',
  googleWebClientId: extra.googleWebClientId ?? '',
  googleIosClientId: extra.googleIosClientId ?? '',
  googleAndroidClientId: extra.googleAndroidClientId ?? '',
  kakaoAppKey: extra.kakaoAppKey ?? '',
  get isSupabaseConfigured() {
    return Boolean(this.supabaseUrl && this.supabaseAnonKey);
  },
  get isAnalyticsConfigured() {
    return Boolean(this.mixpanelToken);
  },
  get isCrashReportingConfigured() {
    return Boolean(this.sentryDsn);
  },
} as const;
