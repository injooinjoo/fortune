"use client";

import { useEffect, useState } from 'react';
import { logger } from '@/lib/logger';

export function AuthDebugPanel() {
  const [debugInfo, setDebugInfo] = useState<{
    hasCodeVerifier: boolean;
    hasAuthToken: boolean;
    storageKeys: string[];
    supabaseKeys: string[];
  }>({
    hasCodeVerifier: false,
    hasAuthToken: false,
    storageKeys: [],
    supabaseKeys: []
  });

  useEffect(() => {
    const checkAuthState = () => {
      try {
        // Check both localStorage and sessionStorage for relevant keys
        const localStorageKeys = Object.keys(localStorage);
        const sessionStorageKeys = Object.keys(sessionStorage);
        const allKeys = [...localStorageKeys, ...sessionStorageKeys.map(k => `session:${k}`)];
        
        const supabaseKeys = localStorageKeys.filter(key => 
          key.includes('supabase') || 
          key.includes('auth') || 
          key.includes('pkce') ||
          key.includes('code_verifier') ||
          key.startsWith('sb-') // Supabase default key pattern
        );
        
        // Also check sessionStorage
        const sessionSupabaseKeys = sessionStorageKeys.filter(key => 
          key.includes('supabase') || 
          key.includes('auth') || 
          key.includes('pkce') ||
          key.includes('code_verifier') ||
          key.startsWith('sb-')
        );

        // Check for specific PKCE-related items in both storages
        // Supabase stores code_verifier under various patterns
        const hasCodeVerifier = supabaseKeys.some(key => {
          const value = localStorage.getItem(key);
          if (!value) return false;
          
          // Check if the key contains code_verifier or if the value contains it
          if (key.includes('code_verifier')) return true;
          
          // Check if it's a Supabase auth token that might contain PKCE data
          try {
            const parsed = JSON.parse(value);
            return parsed.code_verifier || parsed.codeVerifier || 
                   (parsed.auth && (parsed.auth.code_verifier || parsed.auth.codeVerifier)) ||
                   (parsed.currentSession && parsed.currentSession.code_verifier);
          } catch {
            return false;
          }
        }) || sessionSupabaseKeys.some(key => {
          const value = sessionStorage.getItem(key);
          if (!value) return false;
          
          if (key.includes('code_verifier')) return true;
          
          try {
            const parsed = JSON.parse(value);
            return parsed.code_verifier || parsed.codeVerifier;
          } catch {
            return false;
          }
        });

        const hasAuthToken = supabaseKeys.some(key => 
          (key.includes('token') || key.startsWith('sb-')) && localStorage.getItem(key)
        );

        setDebugInfo({
          hasCodeVerifier,
          hasAuthToken,
          storageKeys: allKeys,
          supabaseKeys: [...supabaseKeys, ...sessionSupabaseKeys.map(k => `session:${k}`)]
        });

        // Log current state with more details
        const pkceDetails: Record<string, any> = {};
        supabaseKeys.forEach(key => {
          const value = localStorage.getItem(key);
          if (value && (key.includes('code_verifier') || key.includes('pkce'))) {
            pkceDetails[key] = value.substring(0, 50) + '...';
          }
          // Check Supabase default storage pattern
          if (key.startsWith('sb-') && value) {
            try {
              const parsed = JSON.parse(value);
              if (parsed.code_verifier || parsed.codeVerifier || 
                  parsed.currentSession?.code_verifier) {
                pkceDetails[key] = 'Contains code_verifier';
              }
            } catch {}
          }
        });
        
        // Also check sessionStorage
        sessionSupabaseKeys.forEach(key => {
          const value = sessionStorage.getItem(key);
          if (value && (key.includes('code_verifier') || key.includes('pkce'))) {
            pkceDetails[`session:${key}`] = value.substring(0, 50) + '...';
          }
        });
        
        logger.debug('Auth Debug Info:', {
          hasCodeVerifier,
          hasAuthToken,
          supabaseKeys,
          pkceDetails,
          allStorageKeys: allKeys.length
        });
      } catch (error) {
        logger.error('Debug panel error:', error);
      }
    };

    // Check immediately and on storage changes
    checkAuthState();
    window.addEventListener('storage', checkAuthState);

    return () => {
      window.removeEventListener('storage', checkAuthState);
    };
  }, []);

  if (process.env.NODE_ENV !== 'development') {
    return null;
  }

  return (
    <div className="fixed bottom-4 right-4 bg-black/80 text-white p-4 rounded-lg max-w-sm text-xs font-mono">
      <h3 className="font-bold mb-2">Auth Debug Panel</h3>
      <div className="space-y-1">
        <div>Code Verifier: {debugInfo.hasCodeVerifier ? '✅' : '❌'}</div>
        <div>Auth Token: {debugInfo.hasAuthToken ? '✅' : '❌'}</div>
        <div>Storage Keys: {debugInfo.storageKeys.length}</div>
        <div>Supabase Keys: {debugInfo.supabaseKeys.length}</div>
        <details className="mt-2">
          <summary className="cursor-pointer">Keys</summary>
          <div className="mt-1 max-h-40 overflow-y-auto">
            {debugInfo.supabaseKeys.map(key => (
              <div key={key} className="text-xs opacity-70">{key}</div>
            ))}
          </div>
        </details>
      </div>
    </div>
  );
}