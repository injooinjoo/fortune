// 개발용 메모리 저장소 (실제로는 DB 사용)
// 작성일: 2024-12-19

// 글로벌 객체를 사용하여 핫 리로드 시에도 데이터 유지
declare global {
  var __MOCK_STORAGE__: {
    userProfiles: { [userId: string]: any };
    fortuneData: { [key: string]: any };
  } | undefined;
}

// 글로벌 저장소 초기화
if (!global.__MOCK_STORAGE__) {
  global.__MOCK_STORAGE__ = {
    userProfiles: {},
    fortuneData: {}
  };
}

// 사용자 프로필 저장소
export const userProfiles = global.__MOCK_STORAGE__.userProfiles;

// 운세 데이터 저장소
export const fortuneData = global.__MOCK_STORAGE__.fortuneData;

// 프로필 저장
export function saveUserProfile(userId: string, profile: any) {
  userProfiles[userId] = profile;
  console.log('🔵 프로필 저장됨:', { userId, profile });
  console.log('🔵 저장 후 전체 프로필들:', userProfiles);
  console.log('🔵 글로벌 저장소 상태:', global.__MOCK_STORAGE__);
}

// 프로필 조회
export function getUserProfile(userId: string) {
  console.log('🔍 프로필 조회 시작:', { userId });
  console.log('🔍 현재 전체 프로필들:', userProfiles);
  console.log('🔍 글로벌 저장소 상태:', global.__MOCK_STORAGE__);
  
  const profile = userProfiles[userId];
  console.log('🔍 프로필 조회 결과:', { userId, found: !!profile, profile });
  return profile;
}

// 모든 프로필 조회 (디버깅용)
export function getAllProfiles() {
  console.log('📋 전체 프로필 조회:', userProfiles);
  console.log('📋 글로벌 저장소:', global.__MOCK_STORAGE__);
  return userProfiles;
} 