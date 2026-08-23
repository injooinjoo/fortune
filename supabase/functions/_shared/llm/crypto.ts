// BYOK 자격증명 봉인/해제 (AES-GCM 256).
//
// user_llm_keys 에 들어가는 사용자 API 키는 서드파티 자격증명이다. 평문으로 DB 에
// 두면 DB 덤프 = 사용자 결제 계정 유출이므로, Edge Function 안에서 봉인한
// ciphertext + 레코드별 IV 만 저장한다. 복호화 키는 DB 가 아니라 함수 런타임
// env 에만 존재한다.
//
// 마스터 키: Deno.env 의 BYOK_ENCRYPTION_KEY (base64, 정확히 32바이트로 디코딩).
// 생성 방법:
//
//   openssl rand -base64 32
//
// 출력 문자열을 그대로 `supabase secrets set BYOK_ENCRYPTION_KEY=...` 에 넣는다.
//
// 설계 제약:
//  - 자체 암호 구현 금지. Web Crypto (crypto.subtle) 만 사용한다.
//  - IV 는 레코드마다 새로 뽑는다 (12바이트 random). GCM 에서 IV 재사용은
//    같은 키에 대해 평문 복원을 가능하게 하는 치명적 실수다.
//  - pgsodium / Vault 에 의존하지 않는다 (확장 가용성 미검증).
//  - ⚠️ 이 모듈의 평문 입출력은 자격증명이다. 어떤 로그에도 남기지 말 것.
//    아래 에러 메시지에도 평문/암호문/키 재료를 절대 넣지 않는다.

const ENV_VAR = "BYOK_ENCRYPTION_KEY";
const KEY_BYTES = 32; // AES-256
const IV_BYTES = 12; // GCM 표준 nonce 길이

export interface SealedSecret {
  /** base64 AES-GCM 암호문 (인증 태그 포함) */
  ciphertext: string;
  /** base64 12바이트 IV */
  iv: string;
}

// importKey 는 매 요청 반복할 이유가 없다. extractable=false 라 유출 위험 없음.
let cachedKey: CryptoKey | null = null;

// ArrayBuffer 를 명시적으로 만들어 반환한다 — `new Uint8Array(len)` 의 추론 타입
// (ArrayBufferLike)은 Web Crypto 의 BufferSource 에 그대로 못 넣는다.
function decodeBase64(value: string, label: string) {
  let binary: string;
  try {
    binary = atob(value);
  } catch {
    throw new Error(`${label}: base64 형식이 아닙니다`);
  }
  const bytes = new Uint8Array(new ArrayBuffer(binary.length));
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}

function encodeBase64(bytes: Uint8Array): string {
  let binary = "";
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

/**
 * env 의 마스터 키를 AES-GCM CryptoKey 로 로드한다.
 * 미설정/길이 불일치는 조용히 넘어가면 "암호화 없이 저장" 으로 이어질 수 있으므로
 * 반드시 던진다.
 */
async function getEncryptionKey(): Promise<CryptoKey> {
  if (cachedKey) return cachedKey;

  const raw = Deno.env.get(ENV_VAR)?.trim();
  if (!raw) {
    throw new Error(
      `${ENV_VAR} 미설정 — BYOK 암호화 불가. 'openssl rand -base64 32' 로 생성해 등록할 것.`,
    );
  }

  const material = decodeBase64(raw, ENV_VAR);
  if (material.length !== KEY_BYTES) {
    // 길이만 노출한다 (키 재료는 노출하지 않는다).
    throw new Error(
      `${ENV_VAR} 길이 오류 — ${KEY_BYTES}바이트여야 하는데 ${material.length}바이트. 'openssl rand -base64 32' 출력을 그대로 쓸 것.`,
    );
  }

  cachedKey = await crypto.subtle.importKey(
    "raw",
    material,
    { name: "AES-GCM" },
    false, // extractable=false — 로드된 키를 다시 뽑아낼 수 없다
    ["encrypt", "decrypt"],
  );
  return cachedKey;
}

/** Web Crypto 의 BufferSource 와 맞는 뷰 타입 (decodeBase64 주석 참고). */
export type RecordAad = Uint8Array<ArrayBuffer>;

/**
 * 봉인문을 소유 행 `(user_id, provider)` 에 묶는 AAD.
 *
 * AES-GCM 의 additionalData 는 암호화되지는 않지만 인증 태그 계산에 들어간다.
 * 즉 A 사용자 행의 ciphertext/iv 를 B 사용자 행으로 복사해 붙여도 복호화가
 * 인증 실패로 떨어진다. (DB 쓰기 권한이 필요한 공격이라 심층 방어에 해당하지만,
 * 두 줄로 "A 의 키로 B 의 트래픽을 청구" 경로를 닫을 수 있다.)
 */
export function buildRecordAad(userId: string, provider: string): RecordAad {
  const bytes = new TextEncoder().encode(`${userId}:${provider}`);
  // TextEncoder 결과를 그대로 넘기면 ArrayBufferLike 추론이 BufferSource 와
  // 어긋나는 경우가 있어 명시적 ArrayBuffer 뷰로 복사한다 (decodeBase64 와 동일 이유).
  const copy = new Uint8Array(new ArrayBuffer(bytes.length));
  copy.set(bytes);
  return copy;
}

/**
 * 평문 자격증명을 봉인한다.
 * @param plain ⚠️ 사용자 API 키 평문. 호출부에서 로깅 금지.
 * @param aad   `buildRecordAad(userId, provider)`. 복호화 때 같은 값을 줘야 한다.
 */
export async function encryptSecret(
  plain: string,
  aad: RecordAad,
): Promise<SealedSecret> {
  if (!plain) {
    throw new Error("encryptSecret: 빈 평문은 봉인할 수 없습니다");
  }

  const key = await getEncryptionKey();
  const iv = crypto.getRandomValues(new Uint8Array(IV_BYTES));
  const sealed = await crypto.subtle.encrypt(
    { name: "AES-GCM", iv, additionalData: aad },
    key,
    new TextEncoder().encode(plain),
  );

  return {
    ciphertext: encodeBase64(new Uint8Array(sealed)),
    iv: encodeBase64(iv),
  };
}

/**
 * 봉인된 자격증명을 복원한다.
 * @returns ⚠️ 평문 API 키. 로그/응답/에러 메시지에 넣지 말 것.
 *
 * 마스터 키가 교체됐거나 row 가 변조되면 GCM 인증 태그 검증이 실패한다.
 * 그 경우 원인 문자열에 암호문을 싣지 않고 일반화된 에러를 던진다.
 */
export async function decryptSecret(
  ciphertext: string,
  iv: string,
  aad: RecordAad,
): Promise<string> {
  const key = await getEncryptionKey();
  const ivBytes = decodeBase64(iv, "iv");
  if (ivBytes.length !== IV_BYTES) {
    throw new Error(
      `복호화 실패 — IV 길이 오류 (${IV_BYTES}바이트 기대, ${ivBytes.length}바이트)`,
    );
  }

  let plainBuffer: ArrayBuffer;
  try {
    plainBuffer = await crypto.subtle.decrypt(
      { name: "AES-GCM", iv: ivBytes, additionalData: aad },
      key,
      decodeBase64(ciphertext, "ciphertext"),
    );
  } catch {
    // 인증 태그 불일치 = 마스터 키 교체, 데이터 변조, 또는 AAD(소유 행) 불일치.
    throw new Error(
      `복호화 실패 — 인증 태그 불일치 (${ENV_VAR} 교체 또는 데이터 변조)`,
    );
  }

  return new TextDecoder().decode(plainBuffer);
}
