import 'react-native-url-polyfill/auto';

import * as SecureStore from 'expo-secure-store';
import { createClient, processLock, type Session, type SupportedStorage } from '@supabase/supabase-js';

import { appEnv } from './env';

const secureStoreAdapter: SupportedStorage = {
  getItem: (key) => SecureStore.getItemAsync(key),
  setItem: (key, value) => SecureStore.setItemAsync(key, value),
  removeItem: (key) => SecureStore.deleteItemAsync(key),
};

export const supabase = appEnv.isSupabaseConfigured
  ? createClient(appEnv.supabaseUrl, appEnv.supabaseAnonKey, {
      auth: {
        storage: secureStoreAdapter,
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: false,
        lock: processLock,
      },
      global: {
        headers: {
          'x-client-info': '@fortune/mobile-rn',
        },
      },
    })
  : null;

export type SupabaseSession = Session | null;
