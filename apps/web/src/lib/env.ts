/**
 * 웹 앱 환경변수 단일 진입점.
 *
 * NEXT_PUBLIC_* 만 읽는다. SUPABASE_SERVICE_ROLE_KEY 는 이 앱 어디에서도
 * 참조하지 않는다 — 서버 권한 작업은 전부 Edge Function 소관.
 *
 * 값이 없어도 throw 하지 않는다: CI 가 시크릿 없이 `next build` 를 돌리기
 * 때문에 모듈 로드 시점에 터지면 빌드 자체가 실패한다. 대신
 * `isSupabaseConfigured` 로 호출부가 분기한다.
 */

// process.env.NEXT_PUBLIC_* 는 반드시 리터럴로 접근해야 번들러가 인라인한다.
export const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL ?? '';
export const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ?? '';
export const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3100';

export const isSupabaseConfigured = supabaseUrl.length > 0 && supabaseAnonKey.length > 0;
