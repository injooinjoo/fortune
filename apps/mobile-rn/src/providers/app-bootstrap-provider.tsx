import { createContext, useContext, useEffect, useMemo, useState, type PropsWithChildren } from 'react';

import { trackEvent } from '../lib/analytics';
import { captureError } from '../lib/error-reporting';
import { supabase, type SupabaseSession } from '../lib/supabase';

type BootstrapStatus = 'loading' | 'ready';

interface BootstrapContextValue {
  status: BootstrapStatus;
  session: SupabaseSession;
  hasSupabase: boolean;
}

const BootstrapContext = createContext<BootstrapContextValue>({
  status: 'loading',
  session: null,
  hasSupabase: false,
});

export function AppBootstrapProvider({ children }: PropsWithChildren) {
  const [status, setStatus] = useState<BootstrapStatus>('loading');
  const [session, setSession] = useState<SupabaseSession>(null);

  useEffect(() => {
    let mounted = true;

    trackEvent('app_open').catch(() => undefined);

    if (!supabase) {
      setStatus('ready');
      return;
    }

    supabase.auth
      .getSession()
      .then(({ data }) => {
        if (!mounted) {
          return;
        }

        setSession(data.session);
        setStatus('ready');
      })
      .catch((error) => {
        captureError(error, { surface: 'bootstrap:getSession' }).catch(
          () => undefined,
        );
        if (mounted) {
          setStatus('ready');
        }
      });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, nextSession) => {
      if (mounted) {
        setSession(nextSession);
      }
    });

    return () => {
      mounted = false;
      subscription.unsubscribe();
    };
  }, []);

  const value = useMemo(
    () => ({
      status,
      session,
      hasSupabase: Boolean(supabase),
    }),
    [session, status],
  );

  return (
    <BootstrapContext.Provider value={value}>
      {children}
    </BootstrapContext.Provider>
  );
}

export function useAppBootstrap() {
  return useContext(BootstrapContext);
}
