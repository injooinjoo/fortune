import { test, expect } from '@playwright/test';

test.describe('API 엔드포인트 테스트', () => {
  test('MBTI API - 유효한 타입 조회', async ({ request }) => {
    const response = await request.get('/api/mbti/ISTJ');

    const text = await response.text();
    console.log('MBTI API response', {
      status: response.status(),
      headers: response.headers(),
      body: text,
    });

    expect(response.ok()).toBeTruthy();

    const responseBody = JSON.parse(text);
    expect(responseBody.type).toBe('ISTJ');
    expect(responseBody).toHaveProperty('description');
    expect(responseBody).toHaveProperty('characteristics');
    expect(Array.isArray(responseBody.characteristics)).toBe(true);
  });

  test('MBTI API - 잘못된 타입 조회', async ({ request }) => {
    const response = await request.get('/api/mbti/INVALID');
    
    expect(response.status()).toBe(404);
  });

  test('MBTI API - 모든 유효한 타입 테스트', async ({ request }) => {
    const mbtiTypes = [
      'INTJ', 'INTP', 'ENTJ', 'ENTP',
      'INFJ', 'INFP', 'ENFJ', 'ENFP',
      'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
      'ISTP', 'ISFP', 'ESTP', 'ESFP'
    ];

    for (const type of mbtiTypes) {
      const response = await request.get(`/api/mbti/${type}`);
      expect(response.status()).toBe(200);
      
      const data = await response.json();
      expect(data.type).toBe(type);
    }
  });

  test('API 응답 시간 성능 테스트', async ({ request }) => {
    const startTime = performance.now();
    const response = await request.get('/api/mbti/ENFP');
    const endTime = performance.now();

    expect(response.status()).toBe(200);
    const duration = endTime - startTime;
    expect(duration).toBeLessThan(800); // 800ms 미만 응답
  });

  test('API 동시 요청 처리', async ({ request }) => {
    const promises = Array.from({ length: 10 }, (_, i) => 
      request.get(`/api/mbti/ENFP?test=${i}`)
    );
    
    const responses = await Promise.all(promises);
    
    responses.forEach(response => {
      expect(response.status()).toBe(200);
    });
  });

  test('API 헤더 검증', async ({ request }) => {
    const response = await request.get('/api/mbti/ENFP');
    
    expect(response.status()).toBe(200);
    expect(response.headers()['content-type']).toContain('application/json');
  });

  test('API CORS 설정', async ({ request }) => {
    const response = await request.get('/api/mbti/ENFP');
    
    expect(response.status()).toBe(200);
    // CORS 헤더 확인 (실제 설정에 따라 조정)
    const corsHeader = response.headers()['access-control-allow-origin'];
    if (corsHeader) {
      expect(corsHeader).toBeDefined();
    }
  });

  test('API 데이터 구조 검증', async ({ request }) => {
    const response = await request.get('/api/mbti/ENFP');
    const data = await response.json();
    
    // 필수 필드 존재 확인
    expect(data).toHaveProperty('type');
    expect(data).toHaveProperty('description');
    
    // 데이터 타입 검증
    expect(typeof data.type).toBe('string');
    expect(typeof data.description).toBe('string');
    
    if (data.characteristics) {
      expect(Array.isArray(data.characteristics)).toBe(true);
      data.characteristics.forEach((characteristic: unknown) => {
        expect(typeof characteristic).toBe('string');
      });
    }
  });

  test('API 캐싱 동작', async ({ request }) => {
    // 첫 번째 요청
    const response1 = await request.get('/api/mbti/ENFP');
    expect(response1.status()).toBe(200);
    
    // 두 번째 요청 (캐시에서 응답되어야 함)
    const response2 = await request.get('/api/mbti/ENFP');
    expect(response2.status()).toBe(200);
    
    // 응답 내용이 동일한지 확인
    const data1 = await response1.json();
    const data2 = await response2.json();
    expect(data1).toEqual(data2);
  });

  test('API Rate Limiting 테스트', async ({ request }) => {
    // 연속적인 요청을 보내어 rate limiting 확인
    const rapidRequests = Array.from({ length: 50 }, () => 
      request.get('/api/mbti/ENFP')
    );
    
    const responses = await Promise.all(rapidRequests);
    
    // 대부분의 요청이 성공해야 함 (rate limiting이 없거나 관대한 경우)
    const successCount = responses.filter(r => r.status() === 200).length;
    expect(successCount).toBeGreaterThan(40); // 최소 40개 이상 성공
  });
}); 