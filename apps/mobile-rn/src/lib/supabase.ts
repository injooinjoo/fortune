import 'react-native-url-polyfill/auto';

import { createClient, processLock, type Session, type SupportedStorage } from '@supabase/supabase-js';

import { appEnv } from './env';
import {
  deleteSecureItem,
  getSecureItem,
  setSecureItem,
} from './secure-store-storage';

const secureStoreAdapter: SupportedStorage = {
  getItem: (key) => getSecureItem(key),
  setItem: (key, value) => setSecureItem(key, value),
  removeItem: (key) => deleteSecureItem(key),
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
