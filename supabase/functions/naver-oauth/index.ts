/**
 * 네이버 OAuth (Naver OAuth) Edge Function
 *
 * 지원 모드
 * - GET  ?mode=start    : RN용 OAuth 시작
 * - GET  ?mode=callback : RN용 OAuth 콜백
 * - POST { access_token }: legacy Flutter/native 토큰 교환
 */
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
};

const NAVER_AUTHORIZE_URL = "https://nid.naver.com/oauth2.0/authorize";
const NAVER_TOKEN_URL = "https://nid.naver.com/oauth2.0/token";
const NAVER_PROFILE_URL = "https://openapi.naver.com/v1/nid/me";
const DEFAULT_RETURN_TO = "/chat";
const DEFAULT_MOBILE_SCHEME = "com.beyond.fortune";
const DEFAULT_MOBILE_CALLBACK_HOST = "auth-callback";
const DEFAULT_LEGACY_FLUTTER_CALLBACK = "io.supabase.flutter://login-callback";

interface NaverUserResponse {
  resultcode: string;
  message: string;
  response: {
    id: string;
    nickname?: string;
    name?: string;
    email?: string;
    gender?: string;
    age?: string;
    birthday?: string;
    profile_image?: string;
    birthyear?: string;
    mobile?: string;
  };
}

interface SessionLike {
  access_token: string;
  refresh_token: string;
  expires_in?: number;
  expires_at?: number;
  token_type?: string;
}

function jsonResponse(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function redirectResponse(location: string, status = 302) {
  return new Response(null, {
    status,
    headers: {
      ...corsHeaders,
      Location: location,
      "Cache-Control": "no-store",
    },
  });
}

function normalizeReturnTo(value: string | null | undefined) {
  return value && value.startsWith("/") ? value : DEFAULT_RETURN_TO;
}

function readRequiredEnv(name: string) {
  const value = Deno.env.get(name);

  if (!value) {
    throw new Error(`Missing environment variable: ${name}`);
  }

  return value;
}

function resolveSupabaseUrl() {
  return readRequiredEnv("SUPABASE_URL").replace(/\/$/, "");
}

function resolveFunctionsBaseUrl() {
  return `${resolveSupabaseUrl()}/functions/v1`;
}

function resolveMobileScheme() {
  return Deno.env.get("MOBILE_APP_SCHEME") || DEFAULT_MOBILE_SCHEME;
}

function resolveMobileCallbackHost() {
  return (
    Deno.env.get("MOBILE_AUTH_CALLBACK_HOST") || DEFAULT_MOBILE_CALLBACK_HOST
  );
}

function resolveLegacyFlutterCallbackUrl() {
  return (
    Deno.env.get("LEGACY_FLUTTER_AUTH_CALLBACK_URL") ||
    DEFAULT_LEGACY_FLUTTER_CALLBACK
  );
}

function resolveNaverCallbackUrl() {
  return `${resolveFunctionsBaseUrl()}/naver-oauth?mode=callback`;
}

function encodeState(payload: Record<string, unknown>) {
  return btoa(JSON.stringify(payload))
    .replace(/\+/g, "-")
    .replace(/\//g, "_")
    .replace(/=+$/g, "");
}

function decodeState(state: string | null | undefined) {
  if (!state) {
    return {};
  }

  try {
    const normalized = state.replace(/-/g, "+").replace(/_/g, "/");
    const padding = normalized.length % 4 === 0
      ? ""
      : "=".repeat(4 - (normalized.length % 4));

    return JSON.parse(atob(`${normalized}${padding}`)) as Record<
      string,
      unknown
    >;
  } catch {
    return {};
  }
}

function buildMobileCallbackUrl(input: {
  returnTo?: string | null;
  accessToken?: string | null;
  refreshToken?: string | null;
  error?: string | null;
  errorDescription?: string | null;
}) {
  const callbackUrl = new URL(
    `${resolveMobileScheme()}://${resolveMobileCallbackHost()}`,
  );

  callbackUrl.searchParams.set("provider", "naver");
  callbackUrl.searchParams.set("screen", "chat");
  callbackUrl.searchParams.set("returnTo", normalizeReturnTo(input.returnTo));

  if (input.accessToken) {
    callbackUrl.searchParams.set("access_token", input.accessToken);
  }

  if (input.refreshToken) {
    callbackUrl.searchParams.set("refresh_token", input.refreshToken);
  }

  if (input.error) {
    callbackUrl.searchParams.set("error", input.error);
  }

  if (input.errorDescription) {
    callbackUrl.searchParams.set("error_description", input.errorDescription);
  }

  return callbackUrl.toString();
}

function buildSupabaseClient() {
  return createClient(
    resolveSupabaseUrl(),
    readRequiredEnv("SUPABASE_SERVICE_ROLE_KEY"),
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    },
  );
}

async function fetchNaverUser(accessToken: string) {
  const naverResponse = await fetch(NAVER_PROFILE_URL, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!naverResponse.ok) {
    throw new Error(`Naver API error: ${naverResponse.status}`);
  }

  const naverData: NaverUserResponse = await naverResponse.json();

  if (naverData.resultcode !== "00") {
    throw new Error(`Naver API failed: ${naverData.message}`);
  }

  return naverData.response;
}

async function upsertNaverUser(
  supabase: ReturnType<typeof buildSupabaseClient>,
  naverUser: NaverUserResponse["response"],
) {
  const email = naverUser.email || `naver_${naverUser.id}@zpzg.co.kr`;
  const displayName = naverUser.name || naverUser.nickname ||
    email.split("@")[0];
  const { data: listUsersData, error: userError } = await supabase.auth.admin
    .listUsers();

  if (userError) {
    throw userError;
  }

  const existingUser = listUsersData.users.find((user) => user.email === email);
  const existingLinkedProviders = Array.isArray(
      existingUser?.user_metadata?.linked_providers,
    )
    ? (existingUser?.user_metadata?.linked_providers as string[])
    : [];
  const linkedProviders = Array.from(
    new Set([...existingLinkedProviders, "naver"]),
  );

  let user = existingUser;

  if (existingUser) {
    const { error: updateError } = await supabase.auth.admin.updateUserById(
      existingUser.id,
      {
        user_metadata: {
          ...existingUser.user_metadata,
          provider: "naver",
          primary_provider: existingUser.user_metadata?.primary_provider ||
            "naver",
          linked_providers: linkedProviders,
          naver_id: naverUser.id,
          name: displayName,
          nickname: naverUser.nickname,
          profile_image: naverUser.profile_image,
          email,
        },
      },
    );

    if (updateError) {
      throw updateError;
    }
  } else {
    const { data: createdUser, error: createError } = await supabase.auth.admin
      .createUser({
        email,
        password: `naver_${naverUser.id}_${
          Math.random().toString(36).slice(2)
        }`,
        email_confirm: true,
        user_metadata: {
          provider: "naver",
          primary_provider: "naver",
          linked_providers: ["naver"],
          naver_id: naverUser.id,
          name: displayName,
          nickname: naverUser.nickname,
          email,
          profile_image: naverUser.profile_image,
        },
      });

    if (createError) {
      throw createError;
    }

    user = createdUser.user;
  }

  if (!user) {
    throw new Error("Failed to resolve Naver user in Supabase");
  }

  const { data: existingProfile } = await supabase
    .from("user_profiles")
    .select("created_at, linked_providers, primary_provider")
    .eq("id", user.id)
    .maybeSingle();

  const existingProfileProviders =
    Array.isArray(existingProfile?.linked_providers)
      ? (existingProfile?.linked_providers as string[])
      : [];
  const profileLinkedProviders = Array.from(
    new Set([...existingProfileProviders, "naver"]),
  );

  const profileData = {
    id: user.id,
    email,
    name: displayName,
    profile_image_url: naverUser.profile_image,
    primary_provider: existingProfile?.primary_provider || "naver",
    linked_providers: profileLinkedProviders,
    created_at: existingProfile?.created_at || new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };

  const { error: profileError } = await supabase.from("user_profiles").upsert(
    profileData,
    {
      onConflict: "id",
    },
  );

  if (profileError) {
    throw profileError;
  }

  return {
    user,
    email,
    displayName,
    profileImage: naverUser.profile_image ?? null,
  };
}

async function createSupabaseSessionForEmail(
  supabase: ReturnType<typeof buildSupabaseClient>,
  email: string,
  redirectTo: string,
) {
  const { data: magicLink, error: linkError } = await supabase.auth.admin
    .generateLink({
      type: "magiclink",
      email,
      options: {
        redirectTo,
      },
    });

  if (linkError) {
    throw linkError;
  }

  let session: SessionLike | null = null;

  if (magicLink?.properties?.hashed_token) {
    const { data: verifyData, error: verifyError } = await supabase.auth
      .verifyOtp({
        token_hash: magicLink.properties.hashed_token,
        type: "email",
      });

    if (verifyError) {
      console.error("Naver OAuth verifyOtp failed:", verifyError);
    } else if (verifyData?.session) {
      session = {
        access_token: verifyData.session.access_token,
        refresh_token: verifyData.session.refresh_token,
        expires_at: verifyData.session.expires_at,
        expires_in: verifyData.session.expires_in,
        token_type: verifyData.session.token_type,
      };
    }
  }

  return {
    session,
    sessionUrl: magicLink?.properties?.action_link ?? null,
  };
}

async function exchangeAuthorizationCodeForAccessToken(
  code: string,
  state: string,
) {
  const tokenUrl = new URL(NAVER_TOKEN_URL);
  tokenUrl.searchParams.set("grant_type", "authorization_code");
  tokenUrl.searchParams.set("client_id", readRequiredEnv("NAVER_CLIENT_ID"));
  tokenUrl.searchParams.set(
    "client_secret",
    readRequiredEnv("NAVER_CLIENT_SECRET"),
  );
  tokenUrl.searchParams.set("code", code);
  tokenUrl.searchParams.set("state", state);

  const response = await fetch(tokenUrl.toString(), {
    method: "GET",
  });

  if (!response.ok) {
    throw new Error(`Naver token exchange failed: ${response.status}`);
  }

  const payload = await response.json();

  if (!payload.access_token) {
    throw new Error(payload.error_description || "Naver token exchange failed");
  }

  return payload.access_token as string;
}

async function completeNaverAuth(input: {
  accessToken: string;
  sessionRedirectTo: string;
}) {
  const supabase = buildSupabaseClient();
  const naverUser = await fetchNaverUser(input.accessToken);
  const { user, email, displayName, profileImage } = await upsertNaverUser(
    supabase,
    naverUser,
  );
  const { session, sessionUrl } = await createSupabaseSessionForEmail(
    supabase,
    email,
    input.sessionRedirectTo,
  );

  return {
    success: true,
    user: {
      id: user.id,
      email,
      name: displayName,
      profile_image: profileImage,
    },
    session,
    session_url: sessionUrl,
    naver_user: naverUser,
  };
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  const requestUrl = new URL(req.url);

  try {
    if (req.method === "GET") {
      const mode = requestUrl.searchParams.get("mode") ?? "start";

      if (mode === "start") {
        const returnTo = normalizeReturnTo(
          requestUrl.searchParams.get("returnTo"),
        );
        const state = encodeState({ returnTo });
        const authorizeUrl = new URL(NAVER_AUTHORIZE_URL);

        authorizeUrl.searchParams.set("response_type", "code");
        authorizeUrl.searchParams.set(
          "client_id",
          readRequiredEnv("NAVER_CLIENT_ID"),
        );
        authorizeUrl.searchParams.set(
          "redirect_uri",
          resolveNaverCallbackUrl(),
        );
        authorizeUrl.searchParams.set("state", state);

        return redirectResponse(authorizeUrl.toString());
      }

      if (mode !== "callback") {
        return jsonResponse({ error: `Unsupported mode: ${mode}` }, 400);
      }

      const state = requestUrl.searchParams.get("state");
      const decodedState = decodeState(state);
      const returnTo = normalizeReturnTo(
        typeof decodedState.returnTo === "string"
          ? decodedState.returnTo
          : requestUrl.searchParams.get("returnTo"),
      );

      const error = requestUrl.searchParams.get("error");
      const errorDescription =
        requestUrl.searchParams.get("error_description") ||
        requestUrl.searchParams.get("description");

      if (error) {
        return redirectResponse(
          buildMobileCallbackUrl({
            returnTo,
            error,
            errorDescription: errorDescription ||
              "네이버 로그인 연결에 실패했습니다.",
          }),
        );
      }

      const code = requestUrl.searchParams.get("code");

      if (!code || !state) {
        return redirectResponse(
          buildMobileCallbackUrl({
            returnTo,
            error: "naver_callback_missing_code",
            errorDescription: "네이버 로그인 응답이 올바르지 않습니다.",
          }),
        );
      }

      const naverAccessToken = await exchangeAuthorizationCodeForAccessToken(
        code,
        state,
      );
      const result = await completeNaverAuth({
        accessToken: naverAccessToken,
        sessionRedirectTo: buildMobileCallbackUrl({ returnTo }),
      });

      if (result.session?.access_token && result.session.refresh_token) {
        return redirectResponse(
          buildMobileCallbackUrl({
            returnTo,
            accessToken: result.session.access_token,
            refreshToken: result.session.refresh_token,
          }),
        );
      }

      if (result.session_url) {
        return redirectResponse(result.session_url);
      }

      return redirectResponse(
        buildMobileCallbackUrl({
          returnTo,
          error: "naver_session_missing",
          errorDescription: "세션 생성에 실패했습니다. 다시 시도해 주세요.",
        }),
      );
    }

    if (req.method !== "POST") {
      return jsonResponse({ error: "Method not allowed" }, 405);
    }

    const body = await req.json();
    const accessToken = body?.access_token;

    if (!accessToken) {
      return jsonResponse({ error: "Access token is required" }, 400);
    }

    const result = await completeNaverAuth({
      accessToken,
      sessionRedirectTo: resolveLegacyFlutterCallbackUrl(),
    });

    return jsonResponse(result, 200);
  } catch (error) {
    console.error("Naver OAuth error:", error);

    if (req.method === "GET") {
      const state = requestUrl.searchParams.get("state");
      const decodedState = decodeState(state);
      const returnTo = normalizeReturnTo(
        typeof decodedState.returnTo === "string"
          ? decodedState.returnTo
          : null,
      );

      return redirectResponse(
        buildMobileCallbackUrl({
          returnTo,
          error: "naver_oauth_error",
          errorDescription: error instanceof Error
            ? error.message
            : "네이버 로그인 처리 중 오류가 발생했습니다.",
        }),
      );
    }

    return jsonResponse(
      {
        error: error instanceof Error ? error.message : "Internal server error",
        details: String(error),
      },
      500,
    );
  }
});
