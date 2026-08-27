interface GoogleAuthError {
  message: string;
}

interface GoogleAuthResult {
  error: GoogleAuthError | null;
}

interface GoogleAuthClient {
  auth: {
    getUser(): Promise<{
      data: { user: { is_anonymous?: boolean } | null };
    }>;
    linkIdentity(input: {
      provider: 'google';
      options: { redirectTo: string };
    }): Promise<GoogleAuthResult>;
    signInWithOAuth(input: {
      provider: 'google';
      options: { redirectTo: string };
    }): Promise<GoogleAuthResult>;
  };
}

/**
 * Anonymous Supabase users must keep their current user id so their 5-Ondo
 * balance and fortune history survive Google login. Other visitors use the
 * normal OAuth sign-in path.
 */
export async function beginGoogleAuth(
  client: GoogleAuthClient,
  redirectTo: string,
): Promise<GoogleAuthResult> {
  const {
    data: { user },
  } = await client.auth.getUser();
  const options = { redirectTo };

  if (user?.is_anonymous) {
    return client.auth.linkIdentity({ provider: 'google', options });
  }

  return client.auth.signInWithOAuth({ provider: 'google', options });
}
