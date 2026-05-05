// AdMob Server-Side Verification 서명 검증 (ECDSA P-256, SHA-256).
//
// AdMob 이 콜백을 보낼 때 query string 끝에 signature + key_id 를 붙여 보낸다.
// 검증 절차:
// 1. signature, key_id 파라미터 추출
// 2. 그 둘을 제외한 나머지 query string 을 raw bytes 로 보존 (인코딩 변경 X)
// 3. https://www.gstatic.com/admob/reward/verifier-keys.json 에서 key_id 매칭
//    공개키 (PEM) 조회
// 4. ECDSA P-256 / SHA-256 검증
//
// Reference: https://developers.google.com/admob/android/ssv

const VERIFIER_KEYS_URL =
  "https://www.gstatic.com/admob/reward/verifier-keys.json";

interface VerifierKeyEntry {
  keyId: number;
  pem: string;
  base64: string;
}

interface VerifierKeysResponse {
  keys: VerifierKeyEntry[];
}

let keyCache: { fetchedAt: number; keys: Map<number, string> } | null = null;
const KEY_CACHE_TTL_MS = 60 * 60 * 1000; // 1h

async function getPublicKeyPem(keyId: number): Promise<string | null> {
  const now = Date.now();
  if (keyCache && now - keyCache.fetchedAt < KEY_CACHE_TTL_MS) {
    return keyCache.keys.get(keyId) ?? null;
  }

  const res = await fetch(VERIFIER_KEYS_URL);
  if (!res.ok) {
    throw new Error(`AdMob verifier keys fetch failed: ${res.status}`);
  }
  const json = (await res.json()) as VerifierKeysResponse;
  const map = new Map<number, string>();
  for (const k of json.keys ?? []) {
    map.set(k.keyId, k.pem);
  }
  keyCache = { fetchedAt: now, keys: map };
  return map.get(keyId) ?? null;
}

function pemToCryptoKey(pem: string): Promise<CryptoKey> {
  const b64 = pem
    .replace(/-----BEGIN PUBLIC KEY-----/, "")
    .replace(/-----END PUBLIC KEY-----/, "")
    .replace(/\s+/g, "");
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  const buf = bytes.buffer.slice(0) as ArrayBuffer;
  return crypto.subtle.importKey(
    "spki",
    buf,
    { name: "ECDSA", namedCurve: "P-256" },
    false,
    ["verify"],
  );
}

// AdMob signature 는 base64url (RFC 4648 §5) 인코딩된 ASN.1 DER ECDSA 서명.
// WebCrypto verify 는 raw (r || s) 64 byte 형식을 요구하므로 변환 필요.
function base64UrlDecode(str: string): Uint8Array {
  const pad = str.length % 4;
  const b64 = (str + (pad ? "===".slice(pad - 1) : ""))
    .replace(/-/g, "+")
    .replace(/_/g, "/");
  const binary = atob(b64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
  return bytes;
}

function derToRaw(der: Uint8Array): Uint8Array {
  // Minimal DER ECDSA-Sig parser: SEQUENCE { INTEGER r, INTEGER s }
  if (der[0] !== 0x30) throw new Error("invalid DER signature");
  let i = 2; // skip SEQUENCE tag + length
  if (der[1] & 0x80) i = 2 + (der[1] & 0x7f); // long-form length
  if (der[i] !== 0x02) throw new Error("expected INTEGER for r");
  const rLen = der[i + 1];
  let r = der.subarray(i + 2, i + 2 + rLen);
  i += 2 + rLen;
  if (der[i] !== 0x02) throw new Error("expected INTEGER for s");
  const sLen = der[i + 1];
  let s = der.subarray(i + 2, i + 2 + sLen);
  // 0x00 leading byte stripping (DER positivity padding)
  if (r.length > 32 && r[0] === 0x00) r = r.subarray(1);
  if (s.length > 32 && s[0] === 0x00) s = s.subarray(1);
  // Left-pad to 32 bytes
  const raw = new Uint8Array(64);
  raw.set(r, 32 - r.length);
  raw.set(s, 64 - s.length);
  return raw;
}

export interface SsvVerifyResult {
  valid: boolean;
  reason?: string;
  /** AdMob 가 query string 으로 전달하는 사용자/거래 식별자. */
  params?: Record<string, string>;
}

/**
 * AdMob SSV GET 요청 URL 의 query string 에서 signature 검증.
 * 검증 통과 시 params (signature, key_id 제외) 반환.
 *
 * @param fullUrl Edge Function 진입점 req.url 그대로
 */
export async function verifyAdMobSsv(
  fullUrl: string,
): Promise<SsvVerifyResult> {
  const url = new URL(fullUrl);
  // signature 와 key_id 는 query string 끝에 위치한다고 AdMob 명세에 명시.
  // 안전하게 raw query string 에서 분리.
  const rawQuery = url.search.startsWith("?")
    ? url.search.slice(1)
    : url.search;

  // 패턴: <data>&signature=<sig>&key_id=<id>
  const sigMatch = rawQuery.match(/^(.*)&signature=([^&]+)&key_id=([^&]+)$/);
  if (!sigMatch) {
    return { valid: false, reason: "missing signature/key_id" };
  }
  const [, dataPart, signatureB64Url, keyIdStr] = sigMatch;
  const keyId = Number(keyIdStr);
  if (!Number.isFinite(keyId)) {
    return { valid: false, reason: "invalid key_id" };
  }

  const pem = await getPublicKeyPem(keyId);
  if (!pem) {
    return { valid: false, reason: `unknown key_id: ${keyId}` };
  }

  const cryptoKey = await pemToCryptoKey(pem);

  let signatureRaw: Uint8Array;
  try {
    const der = base64UrlDecode(signatureB64Url);
    signatureRaw = derToRaw(der);
  } catch (e) {
    return {
      valid: false,
      reason: `signature decode failed: ${
        e instanceof Error ? e.message : "unknown"
      }`,
    };
  }

  const dataBytes = new TextEncoder().encode(dataPart);

  // Deno 의 Uint8Array 는 ArrayBufferLike (SharedArrayBuffer 가능) 로 추론되지만
  // crypto.subtle.verify 는 ArrayBuffer 만 허용. .buffer 를 명시적으로 잘라 복사.
  const sigBuf = signatureRaw.buffer.slice(
    signatureRaw.byteOffset,
    signatureRaw.byteOffset + signatureRaw.byteLength,
  ) as ArrayBuffer;
  const dataBuf = dataBytes.buffer.slice(
    dataBytes.byteOffset,
    dataBytes.byteOffset + dataBytes.byteLength,
  ) as ArrayBuffer;

  const valid = await crypto.subtle.verify(
    { name: "ECDSA", hash: "SHA-256" },
    cryptoKey,
    sigBuf,
    dataBuf,
  );

  if (!valid) {
    return { valid: false, reason: "signature verify failed" };
  }

  const params: Record<string, string> = {};
  for (const pair of dataPart.split("&")) {
    const eq = pair.indexOf("=");
    if (eq < 0) continue;
    const k = decodeURIComponent(pair.slice(0, eq));
    const v = decodeURIComponent(pair.slice(eq + 1));
    params[k] = v;
  }

  return { valid: true, params };
}
