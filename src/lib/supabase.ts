import { createClient } from '@supabase/supabase-js';

// Supabase 설정
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://your-project.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'your-anon-key';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// 호환성을 위한 auth 객체 (기존 코드와의 호환성 유지)
export const auth = {
  currentUser: null,
  signInWithGoogle: async () => {
    const { data, error } = await supabase.auth.signInWithOAuth({
      provider: 'google',
      options: {
        redirectTo: `${window.location.origin}/auth/callback`,
        queryParams: {
          access_type: 'offline',
          prompt: 'consent',
        }
      }
    });
    if (error) throw error;
    return data;
  },
  signOut: () => supabase.auth.signOut(),
  onAuthStateChanged: (callback: (user: any) => void) => {
    return supabase.auth.onAuthStateChange((event, session) => {
      console.log('Auth state changed:', event, session?.user?.email);
      callback(session?.user || null);
    });
  },
  getSession: () => supabase.auth.getSession(),
} as any;

// 기존 db 객체 호환성
export const db = supabase;
