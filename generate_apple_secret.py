#!/usr/bin/env python3
import jwt
import time
from datetime import datetime, timedelta

# Apple Developer 정보
TEAM_ID = "5F7CN7Y54D"
SERVICE_ID = "com.beyond.fortune.service"
KEY_ID = "3A6YZN2YW8"

# Private Key (다운로드한 .p8 파일 내용)
PRIVATE_KEY = """-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQgZaY2sjEAy8XLsZhX
p/WwGbHxok8YL9w3R0DQoQD1oy+gCgYIKoZIzj0DAQehRANCAAQmeyu45QI7L7yC
kDJuGTVVIqnE5E6VNKyPPbHBD0jeUg4zNo2z8XX1sjJ6zO3U6pe4VlAFO1yYJ1nY
yO+JdSlh
-----END PRIVATE KEY-----"""

def generate_client_secret():
    # 현재 시간과 6개월 후 만료 시간
    now = datetime.utcnow()
    expiry = now + timedelta(days=180)  # 6개월
    
    # JWT Claims
    claims = {
        "iss": TEAM_ID,  # Issuer (Team ID)
        "iat": int(now.timestamp()),  # Issued at
        "exp": int(expiry.timestamp()),  # Expiry (6개월)
        "aud": "https://appleid.apple.com",  # Audience
        "sub": SERVICE_ID,  # Subject (Service ID)
    }
    
    # JWT Header
    headers = {
        "kid": KEY_ID,  # Key ID
        "alg": "ES256"  # Algorithm
    }
    
    # Generate JWT
    client_secret = jwt.encode(
        claims,
        PRIVATE_KEY,
        algorithm="ES256",
        headers=headers
    )
    
    return client_secret

if __name__ == "__main__":
    try:
        secret = generate_client_secret()
        print("=" * 60)
        print("Apple Sign In Secret Key (JWT)")
        print("=" * 60)
        print("\n이 Secret Key를 Supabase Dashboard의")
        print("Apple Provider 설정에서 'Secret Key (for OAuth)' 필드에")
        print("복사해서 붙여넣으세요:\n")
        print("-" * 60)
        print(secret)
        print("-" * 60)
        print(f"\n만료일: {(datetime.utcnow() + timedelta(days=180)).strftime('%Y-%m-%d')}")
        print("(6개월 후 재생성 필요)")
        print("=" * 60)
    except Exception as e:
        print(f"Error generating secret: {e}")
        print("\nPyJWT 설치가 필요합니다:")
        print("pip3 install pyjwt[crypto]")