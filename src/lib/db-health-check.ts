export interface LocalStorageHealthStatus {
  isAvailable: boolean;
  hasUserData: boolean;
  dataSize: number;
  dataCount: number;
  userProfile?: any;
  issues: string[];
  recommendations: string[];
  error?: string;
}

export const checkLocalStorageHealth = (): LocalStorageHealthStatus => {
  const issues: string[] = [];
  const recommendations: string[] = [];
  
  try {
    // 1. 로컬 스토리지 사용 가능 여부 확인
    const testKey = 'fortune_test_key';
    localStorage.setItem(testKey, 'test');
    localStorage.removeItem(testKey);

    // 2. 사용자 데이터 존재 여부 확인
    const userProfileStr = localStorage.getItem('userProfile');
    const hasUserData = !!userProfileStr;
    
    let userProfile = null;
    if (userProfileStr) {
      try {
        userProfile = JSON.parse(userProfileStr);
        
        // 프로필 데이터 검증
        if (!userProfile.id) issues.push('프로필 ID가 누락됨');
        if (!userProfile.name) issues.push('사용자 이름이 누락됨');
        if (!userProfile.onboarding_completed) issues.push('온보딩이 완료되지 않음');
        
        // 날짜 형식 검증
        if (userProfile.birth_date && !userProfile.birth_date.match(/^\d{4}-\d{2}-\d{2}$/)) {
          issues.push('생년월일 형식이 잘못됨');
          recommendations.push('생년월일을 YYYY-MM-DD 형식으로 수정하세요');
        }
      } catch (e) {
        issues.push('사용자 프로필 파싱 오류');
        recommendations.push('프로필 데이터를 초기화해야 할 수 있습니다');
      }
    }

    // 3. 저장된 데이터 크기 및 개수 계산
    let totalSize = 0;
    let dataCount = 0;
    const storageKeys = Object.keys(localStorage);
    
    for (let key of storageKeys) {
      const value = localStorage.getItem(key);
      if (value) {
        totalSize += value.length;
        dataCount++;
      }
    }
    
    // 4. 저장 공간 경고
    const sizeInKB = Math.round(totalSize / 1024);
    if (sizeInKB > 4096) { // 4MB 초과
      issues.push(`로컬 스토리지 사용량이 높음 (${sizeInKB}KB)`);
      recommendations.push('오래된 운세 기록을 정리하세요');
    }
    
    // 5. 오래된 데이터 검사
    const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
    let oldDataCount = 0;
    
    storageKeys.forEach(key => {
      if (key.startsWith('temp_')) {
        try {
          const data = JSON.parse(localStorage.getItem(key) || '{}');
          if (data.created_at && new Date(data.created_at).getTime() < thirtyDaysAgo) {
            oldDataCount++;
          }
        } catch {}
      }
    });
    
    if (oldDataCount > 0) {
      issues.push(`30일 이상 된 임시 데이터 ${oldDataCount}개 발견`);
      recommendations.push('오래된 임시 데이터를 정리하세요');
    }

    return {
      isAvailable: true,
      hasUserData,
      dataSize: totalSize,
      dataCount,
      userProfile,
      issues,
      recommendations
    };

  } catch (error) {
    return {
      isAvailable: false,
      hasUserData: false,
      dataSize: 0,
      dataCount: 0,
      issues: ['로컬 스토리지를 사용할 수 없습니다'],
      recommendations: ['브라우저 설정에서 로컬 스토리지를 활성화하세요'],
      error: `Local storage check failed: ${error instanceof Error ? error.message : 'Unknown error'}`
    };
  }
};

export const logLocalStorageStatus = (verbose: boolean = false): void => {
  if (typeof window === 'undefined') return;
  
  const status = checkLocalStorageHealth();
  
  // 간단한 요약만 출력 (기본)
  if (!verbose) {
    if (status.isAvailable && status.hasUserData) {
      console.log(`💾 Storage: ${Math.round(status.dataSize / 1024)}KB used, ${status.dataCount} items${status.issues.length > 0 ? `, ${status.issues.length} issues` : ''}`);
    } else if (!status.isAvailable) {
      console.error('❌ Local Storage unavailable');
    }
    return;
  }
  
  // 상세 로그 (verbose 모드)
  console.group('🏥 Local Storage Health Check');
  
  if (status.isAvailable) {
    console.log('✅ Status: Available');
    console.log(`📁 Total items: ${status.dataCount}`);
    console.log(`💾 Data size: ${Math.round(status.dataSize / 1024)} KB`);
    
    if (status.hasUserData) {
      console.log('✅ User data: Found');
      if (status.userProfile) {
        console.log(`👤 User: ${status.userProfile.name} (${status.userProfile.id})`);
        console.log(`📧 Email: ${status.userProfile.email || 'Guest user'}`);
      }
    } else {
      console.log('ℹ️  User data: Not found');
    }
    
    if (status.issues.length > 0) {
      console.group('⚠️  Issues found:');
      status.issues.forEach(issue => console.warn(`- ${issue}`));
      console.groupEnd();
    }
    
    if (status.recommendations.length > 0) {
      console.group('💡 Recommendations:');
      status.recommendations.forEach(rec => console.info(`- ${rec}`));
      console.groupEnd();
    }
  } else {
    console.error('❌ Status: Unavailable');
    console.error('🚨 Error:', status.error);
  }
  
  console.groupEnd();
};

/**
 * 로컬 스토리지 초기화 및 정리 함수
 */
export const cleanupLocalStorage = (): { cleaned: number; freedSpace: number } => {
  let cleaned = 0;
  let freedSpace = 0;
  
  try {
    const thirtyDaysAgo = Date.now() - (30 * 24 * 60 * 60 * 1000);
    const keysToRemove: string[] = [];
    
    Object.keys(localStorage).forEach(key => {
      // 임시 데이터나 오래된 데이터 정리
      if (key.startsWith('temp_') || key.startsWith('_tmp_')) {
        const value = localStorage.getItem(key);
        if (value) {
          freedSpace += value.length;
          keysToRemove.push(key);
        }
      }
      
    });
    
    // 안전하게 제거
    keysToRemove.forEach(key => {
      localStorage.removeItem(key);
      cleaned++;
    });
    
    return { cleaned, freedSpace };
  } catch (error) {
    console.error('로컬 스토리지 정리 중 오류:', error);
    return { cleaned: 0, freedSpace: 0 };
  }
};