/**
 * 유니코드 처리 유틸리티
 * 한글 인코딩 문제 해결을 위한 헬퍼 함수들
 */

/**
 * 문자열을 안전한 유니코드로 정규화
 */
export function normalizeUnicode(str: string): string {
  try {
    // NFC (Canonical Decomposition, followed by Canonical Composition) 정규화
    // 한글의 경우 조합형으로 정규화
    return str.normalize('NFC');
  } catch (error) {
    console.error('Unicode normalization failed:', error);
    return str;
  }
}

/**
 * 이모지와 특수문자를 안전하게 처리
 */
export function sanitizeForAI(text: string): string {
  // 유니코드 정규화
  let normalized = normalizeUnicode(text);
  
  // 제어 문자 제거 (탭, 줄바꿈 제외)
  normalized = normalized.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '');
  
  // 연속된 공백을 하나로
  normalized = normalized.replace(/\s+/g, ' ');
  
  // 앞뒤 공백 제거
  return normalized.trim();
}

/**
 * JSON 문자열의 한글 인코딩 문제 해결
 */
export function safeJsonStringify(obj: any): string {
  try {
    // ensure_ascii=false와 유사한 효과
    return JSON.stringify(obj, (key, value) => {
      if (typeof value === 'string') {
        return normalizeUnicode(value);
      }
      return value;
    });
  } catch (error) {
    console.error('JSON stringify failed:', error);
    return '{}';
  }
}

/**
 * 프롬프트 텍스트 전처리
 */
export function preprocessPrompt(prompt: string): string {
  // 유니코드 정규화
  let processed = normalizeUnicode(prompt);
  
  // 특수 문자 이스케이프
  processed = processed.replace(/\\/g, '\\\\');
  processed = processed.replace(/"/g, '\\"');
  
  // 줄바꿈을 명시적으로 처리
  processed = processed.replace(/\n/g, '\\n');
  processed = processed.replace(/\r/g, '\\r');
  
  return processed;
}

/**
 * AI 응답 텍스트 후처리
 */
export function postprocessAIResponse(response: string): string {
  try {
    // 잘못된 이스케이프 문자 복원
    let processed = response.replace(/\\n/g, '\n');
    processed = processed.replace(/\\r/g, '\r');
    processed = processed.replace(/\\t/g, '\t');
    
    // 유니코드 정규화
    processed = normalizeUnicode(processed);
    
    // HTML 엔티티 디코딩 (필요한 경우)
    processed = processed.replace(/&quot;/g, '"');
    processed = processed.replace(/&apos;/g, "'");
    processed = processed.replace(/&lt;/g, '<');
    processed = processed.replace(/&gt;/g, '>');
    processed = processed.replace(/&amp;/g, '&');
    
    return processed;
  } catch (error) {
    console.error('Response postprocessing failed:', error);
    return response;
  }
}

/**
 * 한글 여부 확인
 */
export function containsKorean(text: string): boolean {
  // 한글 유니코드 범위: AC00-D7AF (한글 음절)
  // 1100-11FF (한글 자모)
  // 3130-318F (한글 호환 자모)
  return /[\uAC00-\uD7AF\u1100-\u11FF\u3130-\u318F]/g.test(text);
}

/**
 * 바이트 길이 계산 (UTF-8 기준)
 */
export function getByteLength(str: string): number {
  return new TextEncoder().encode(str).length;
}

/**
 * 최대 바이트 길이로 문자열 자르기
 */
export function truncateByBytes(str: string, maxBytes: number): string {
  const encoder = new TextEncoder();
  const decoder = new TextDecoder('utf-8');
  
  const encoded = encoder.encode(str);
  if (encoded.length <= maxBytes) {
    return str;
  }
  
  // 바이트 단위로 자르되, 문자가 깨지지 않도록 처리
  let truncated = encoded.slice(0, maxBytes);
  
  // UTF-8 문자 경계 확인 및 조정
  while (truncated.length > 0) {
    try {
      return decoder.decode(truncated);
    } catch {
      // 마지막 바이트를 제거하고 다시 시도
      truncated = truncated.slice(0, -1);
    }
  }
  
  return '';
}