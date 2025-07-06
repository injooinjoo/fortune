"use client";

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase, userProfileService } from '@/lib/supabase';
import { getUserProfile, saveUserProfile, updateUserProfile } from '@/lib/user-storage';
import AuthSessionManager from '@/lib/auth-session-manager';

export default function AuthCallbackPage() {
  const router = useRouter();
  const [isProcessing, setIsProcessing] = useState(true);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [isClient, setIsClient] = useState(false);

  // 클라이언트 사이드 마운트 확인 (hydration 오류 방지)
  useEffect(() => {
    setIsClient(true);
  }, []);

  useEffect(() => {
    if (!isClient) return;

    let isProcessed = false; // 중복 처리 방지 플래그

    const handleAuthCallback = async () => {
      if (isProcessed) return; // 이미 처리된 경우 중단
      isProcessed = true;

      try {
        console.log('🔄 Auth callback started');
        
        // URL에서 직접 파라미터 추출
        const urlParams = new URLSearchParams(window.location.search);
        const urlHash = window.location.hash;
        
        console.log('📍 URL params:', urlParams.toString());
        console.log('📍 URL hash:', urlHash);

        // code 파라미터 확인 (OAuth authorization code)
        const code = urlParams.get('code');
        const error = urlParams.get('error');
        const errorDescription = urlParams.get('error_description');

        // 먼저 현재 세션 확인
        const { data: sessionData, error: sessionError } = await supabase.auth.getSession();
        
        if (sessionData?.session && !code) {
          console.log('✅ 이미 유효한 세션이 존재합니다');
          const user = sessionData.session.user;
          
          // 기존 세션이 있으면 프로필 확인 후 리다이렉트
          const existingProfile = await userProfileService.getProfile(user.id);
          
          if (existingProfile && existingProfile.onboarding_completed) {
            router.replace('/home');
          } else {
            router.replace('/onboarding');
          }
          return;
        }

        if (error) {
          console.error('🚨 OAuth error:', error, errorDescription);
          setErrorMessage(`OAuth 인증 오류: ${errorDescription || error}`);
          setIsProcessing(false);
          setTimeout(() => router.replace('/'), 3000);
          return;
        }

        if (code) {
          console.log('✅ Authorization code found, exchanging for session...');
          
          try {
            // code를 session으로 교환
            const { data, error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
            
            if (exchangeError) {
              console.error('🚨 Code exchange error:', exchangeError);
              
              // PKCE 관련 오류인 경우 특별 처리
              if (exchangeError.message?.includes('code verifier')) {
                setErrorMessage('인증 세션이 만료되었습니다. 다시 로그인해주세요.');
                
                // 전체 인증 스토리지 리셋
                AuthSessionManager.resetAuthStorage();
                setTimeout(() => router.replace('/'), 2000);
                return;
              }
              
              setErrorMessage('토큰 교환 중 오류가 발생했습니다.');
              setIsProcessing(false);
              setTimeout(() => router.replace('/'), 3000);
              return;
            }
            
            // 성공 시 임시 데이터 정리
            AuthSessionManager.cleanupAfterAuth();
            
            if (data?.session?.user) {
              const user = data.session.user;
              console.log('✅ User authenticated:', user.email);
            
            // 사용자 프로필 확인
            const existingProfile = await userProfileService.getProfile(user.id);
            
            // 로컬 스토리지에서 기존 데이터 확인
            const localProfile = getUserProfile();
            
            if (existingProfile && existingProfile.onboarding_completed) {
              // 기존 사용자 - 로컬 데이터와 병합
              console.log('👤 Existing user, merging with local data');
              
              // 로캼 데이터가 있으면 병합
              if (localProfile && localProfile.onboarding_completed) {
                const mergedProfile = {
                  ...existingProfile,
                  // 로캼에서 더 최신 데이터가 있으면 사용
                  name: localProfile.name || existingProfile.name,
                  birth_date: localProfile.birth_date || existingProfile.birth_date,
                  birth_time: localProfile.birth_time || existingProfile.birth_time,
                  mbti: localProfile.mbti || existingProfile.mbti,
                  updated_at: new Date().toISOString()
                };
                
                // Supabase에 업데이트
                await userProfileService.upsertProfile(mergedProfile);
                // 로컬에도 업데이트
                saveUserProfile(mergedProfile);
                console.log('🔄 데이터 병합 완료');
              } else {
                // 로컬 데이터가 없으면 Supabase 데이터를 로컬에 저장
                saveUserProfile(existingProfile);
              }
              
              router.replace('/home');
            } else {
              // 신규 사용자 또는 온보딩 미완료
              console.log('🆕 New user or onboarding incomplete, redirecting to onboarding');
              
              // 기본 프로필 생성
              if (!existingProfile) {
                const newProfile = {
                  id: user.id,
                  email: user.email,
                  name: user.user_metadata?.full_name || user.email?.split('@')[0] || '사용자',
                  avatar_url: user.user_metadata?.avatar_url,
                  onboarding_completed: false,
                  created_at: new Date().toISOString()
                };
                
                // 로컼 데이터가 있으면 병합
                if (localProfile) {
                  const mergedProfile = {
                    ...newProfile,
                    name: localProfile.name || newProfile.name,
                    birth_date: localProfile.birth_date,
                    birth_time: localProfile.birth_time,
                    mbti: localProfile.mbti,
                    onboarding_completed: localProfile.onboarding_completed || false,
                    updated_at: new Date().toISOString()
                  };
                  
                  await userProfileService.upsertProfile(mergedProfile);
                  saveUserProfile(mergedProfile);
                  console.log('🔄 로캼 데이터와 병합한 신규 프로필 생성');
                } else {
                  await userProfileService.upsertProfile(newProfile);
                  saveUserProfile(newProfile);
                }
              }
              
              router.replace('/onboarding');
            }
            } else {
              console.log('❌ No session after code exchange');
              setErrorMessage('세션 생성에 실패했습니다.');
              setIsProcessing(false);
              setTimeout(() => router.replace('/'), 3000);
            }
          } catch (codeError) {
            console.error('🚨 Code exchange exception:', codeError);
            setErrorMessage('인증 처리 중 오류가 발생했습니다.');
            setIsProcessing(false);
            setTimeout(() => router.replace('/'), 3000);
          }
        } else {
          // code도 없고 URL hash에서 session 확인 시도
          console.log('🔍 No code found, checking for session from URL...');
          
          const { data, error: sessionError } = await supabase.auth.getSession();
          
          if (sessionError) {
            console.error('🚨 Session retrieval error:', sessionError);
            setErrorMessage('세션 확인 중 오류가 발생했습니다.');
            setIsProcessing(false);
            setTimeout(() => router.replace('/'), 3000);
            return;
          }

          if (data.session?.user) {
            const user = data.session.user;
            console.log('✅ Session found, user:', user.email);
            
            // 사용자 프로필 확인
            const existingProfile = await userProfileService.getProfile(user.id);
            
            // 로컬 스토리지에서 기존 데이터 확인
            const localProfile = getUserProfile();
            
            if (existingProfile && existingProfile.onboarding_completed) {
              console.log('👤 Existing user with session, merging with local data');
              
              // 로캼 데이터가 있으면 병합
              if (localProfile && localProfile.onboarding_completed) {
                const mergedProfile = {
                  ...existingProfile,
                  name: localProfile.name || existingProfile.name,
                  birth_date: localProfile.birth_date || existingProfile.birth_date,
                  birth_time: localProfile.birth_time || existingProfile.birth_time,
                  mbti: localProfile.mbti || existingProfile.mbti,
                  updated_at: new Date().toISOString()
                };
                
                await userProfileService.upsertProfile(mergedProfile);
                saveUserProfile(mergedProfile);
                console.log('🔄 데이터 병합 완료');
              } else {
                saveUserProfile(existingProfile);
              }
              
              router.replace('/home');
            } else {
              console.log('🆕 New user with session, redirecting to onboarding');
              
              if (!existingProfile) {
                const newProfile = {
                  id: user.id,
                  email: user.email,
                  name: user.user_metadata?.full_name || user.email?.split('@')[0] || '사용자',
                  avatar_url: user.user_metadata?.avatar_url,
                  onboarding_completed: false,
                  created_at: new Date().toISOString()
                };
                
                if (localProfile) {
                  const mergedProfile = {
                    ...newProfile,
                    name: localProfile.name || newProfile.name,
                    birth_date: localProfile.birth_date,
                    birth_time: localProfile.birth_time,
                    mbti: localProfile.mbti,
                    onboarding_completed: localProfile.onboarding_completed || false,
                    updated_at: new Date().toISOString()
                  };
                  
                  await userProfileService.upsertProfile(mergedProfile);
                  saveUserProfile(mergedProfile);
                } else {
                  await userProfileService.upsertProfile(newProfile);
                  saveUserProfile(newProfile);
                }
              }
              
              router.replace('/onboarding');
            }
          } else {
            console.log('❌ No session found, redirecting to main page');
            router.replace('/');
          }
        }
      } catch (error) {
        console.error('🚨 Auth callback processing error:', error);
        setErrorMessage('인증 처리 중 예기치 않은 오류가 발생했습니다.');
        setIsProcessing(false);
        setTimeout(() => router.replace('/'), 3000);
      }
    };

    // 약간의 지연을 두어 DOM이 완전히 로드된 후 실행
    const timer = setTimeout(handleAuthCallback, 100);
    return () => clearTimeout(timer);
  }, [router, isClient]);

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 via-white to-pink-50">
      <div className="text-center max-w-md mx-auto p-6">
        {isProcessing ? (
          <>
            <div className="animate-spin h-8 w-8 border-4 border-purple-600 border-t-transparent rounded-full mx-auto mb-4"></div>
            <p className="text-lg text-gray-900 mb-2">구글 로그인 처리 중...</p>
            <p className="text-sm text-gray-600">
              인증 정보를 확인하고 있습니다...
            </p>
          </>
        ) : (
          <>
            <div className="text-red-500 text-6xl mb-4">⚠️</div>
            <p className="text-lg text-gray-900 mb-2">로그인 처리 중 문제가 발생했습니다</p>
            {errorMessage && (
              <p className="text-sm text-red-600 mb-4">{errorMessage}</p>
            )}
            <p className="text-sm text-gray-600">
              잠시 후 메인 페이지로 이동합니다...
            </p>
          </>
        )}
      </div>
    </div>
  );
} 