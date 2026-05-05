#!/usr/bin/env python3
"""
Apple Sign In client_secret (JWT) 생성기.

⚠️ 보안: 이전 버전은 PRIVATE_KEY 가 하드코딩돼 있었음 → /ultrareview P0 로
플래그됨 → 사용자가 Apple Developer console 에서 KEY_ID `3A6YZN2YW8` 폐기
+ 새 키 발급 + 환경변수로 주입하는 형태로 전환.

사용법:
  export APPLE_TEAM_ID=5F7CN7Y54D
  export APPLE_SERVICE_ID=com.beyond.fortune.service
  export APPLE_KEY_ID=<신규 KEY_ID>
  export APPLE_PRIVATE_KEY="$(cat ./AuthKey_<KEY_ID>.p8)"
  python3 scripts/generate_apple_secret.py

또는 .env 파일 사용:
  pip3 install python-dotenv pyjwt[crypto]
  # .env 에 위 4개 변수 작성 (gitignore 확인 후)
  python3 scripts/generate_apple_secret.py

생성된 client_secret 은 Supabase Dashboard
Authentication → Providers → Apple → Secret Key (for OAuth) 에 입력.
6개월 만료. 만료 전 재생성 필요.
"""
import os
import sys
from datetime import datetime, timedelta

try:
    import jwt
except ImportError:
    print("PyJWT 미설치: pip3 install 'pyjwt[crypto]'", file=sys.stderr)
    sys.exit(1)

# .env 자동 로드 (선택)
try:
    from dotenv import load_dotenv  # type: ignore
    load_dotenv()
except ImportError:
    pass


def required_env(key: str) -> str:
    value = os.environ.get(key, "").strip()
    if not value:
        print(f"환경변수 {key} 누락. 위 docstring 참고.", file=sys.stderr)
        sys.exit(2)
    return value


def generate_client_secret() -> str:
    team_id = required_env("APPLE_TEAM_ID")
    service_id = required_env("APPLE_SERVICE_ID")
    key_id = required_env("APPLE_KEY_ID")
    private_key = required_env("APPLE_PRIVATE_KEY")

    # PEM body 가 BEGIN/END 줄 없이 들어왔으면 wrap.
    if "BEGIN PRIVATE KEY" not in private_key:
        private_key = (
            "-----BEGIN PRIVATE KEY-----\n"
            f"{private_key.strip()}\n"
            "-----END PRIVATE KEY-----"
        )

    now = datetime.utcnow()
    expiry = now + timedelta(days=180)  # 6개월

    claims = {
        "iss": team_id,
        "iat": int(now.timestamp()),
        "exp": int(expiry.timestamp()),
        "aud": "https://appleid.apple.com",
        "sub": service_id,
    }

    headers = {"kid": key_id, "alg": "ES256"}

    return jwt.encode(claims, private_key, algorithm="ES256", headers=headers)


if __name__ == "__main__":
    try:
        secret = generate_client_secret()
        expiry_label = (datetime.utcnow() + timedelta(days=180)).strftime("%Y-%m-%d")
        print("=" * 60)
        print("Apple Sign In Client Secret (JWT)")
        print("=" * 60)
        print(
            "\nSupabase Dashboard → Authentication → Providers → Apple → "
            "Secret Key (for OAuth) 에 붙여넣으세요:\n"
        )
        print("-" * 60)
        print(secret)
        print("-" * 60)
        print(f"\n만료일: {expiry_label} (6개월 후 재생성 필요)")
        print("=" * 60)
    except SystemExit:
        raise
    except Exception as e:
        print(f"Error generating secret: {e}", file=sys.stderr)
        sys.exit(3)
