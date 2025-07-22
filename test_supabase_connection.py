#!/usr/bin/env python3
"""
Supabase 연결 테스트 스크립트
Flutter 앱을 실행하기 전에 Supabase 연결을 테스트합니다.
"""

import requests
import json
import sys
from datetime import datetime

# .env 파일에서 설정 읽기
def read_env_file(filepath):
    env_vars = {}
    try:
        with open(filepath, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    except FileNotFoundError:
        print(f"❌ .env 파일을 찾을 수 없습니다: {filepath}")
        sys.exit(1)
    return env_vars

def test_supabase_connection():
    print("🔍 Supabase 연결 테스트 시작...\n")
    
    # .env 파일 읽기
    env_vars = read_env_file('fortune_flutter/.env')
    
    supabase_url = env_vars.get('SUPABASE_URL')
    anon_key = env_vars.get('SUPABASE_ANON_KEY')
    
    if not supabase_url or not anon_key:
        print("❌ SUPABASE_URL 또는 SUPABASE_ANON_KEY가 .env 파일에 없습니다.")
        return False
    
    print(f"📍 Supabase URL: {supabase_url}")
    print(f"🔑 API Key 길이: {len(anon_key)} 문자")
    print(f"🔑 API Key 시작: {anon_key[:50]}...")
    print()
    
    # 1. 기본 연결 테스트
    print("1️⃣ 기본 연결 테스트...")
    try:
        response = requests.get(f"{supabase_url}/rest/v1/", 
                              headers={'apikey': anon_key})
        print(f"   상태 코드: {response.status_code}")
        
        if response.status_code == 401:
            print("   ❌ Invalid API key - API 키가 올바르지 않습니다!")
            print("   💡 Supabase 대시보드에서 올바른 anon key를 복사하세요.")
            return False
        elif response.status_code == 200:
            print("   ✅ API 키가 유효합니다!")
        else:
            print(f"   ⚠️  예상치 못한 응답: {response.status_code}")
            print(f"   응답: {response.text[:200]}...")
    except Exception as e:
        print(f"   ❌ 연결 실패: {e}")
        return False
    
    # 2. Auth 엔드포인트 테스트
    print("\n2️⃣ Auth 엔드포인트 테스트...")
    try:
        response = requests.get(f"{supabase_url}/auth/v1/settings",
                              headers={'apikey': anon_key})
        print(f"   상태 코드: {response.status_code}")
        
        if response.status_code == 200:
            settings = response.json()
            print("   ✅ Auth 설정을 가져왔습니다!")
            if 'external' in settings:
                providers = list(settings['external'].keys())
                print(f"   활성화된 OAuth 제공자: {', '.join(providers)}")
        else:
            print(f"   ⚠️  Auth 설정을 가져올 수 없습니다: {response.status_code}")
    except Exception as e:
        print(f"   ❌ Auth 테스트 실패: {e}")
    
    # 3. 프로젝트 상태 확인
    print("\n3️⃣ 프로젝트 상태 확인...")
    try:
        # OpenAPI 스펙 확인으로 프로젝트 활성 상태 간접 확인
        response = requests.get(f"{supabase_url}/rest/v1/",
                              headers={'apikey': anon_key, 'Accept': 'application/openapi+json'})
        if response.status_code == 200:
            print("   ✅ 프로젝트가 활성 상태입니다!")
        else:
            print("   ⚠️  프로젝트 상태를 확인할 수 없습니다.")
    except Exception as e:
        print(f"   ❌ 상태 확인 실패: {e}")
    
    print("\n" + "="*50)
    print("📋 테스트 요약:")
    
    if response.status_code == 401:
        print("❌ API 키가 유효하지 않습니다.")
        print("\n🔧 해결 방법:")
        print("1. https://supabase.com/dashboard 접속")
        print("2. 프로젝트 선택 > Settings > API")
        print("3. 'anon' 'public' 키 복사")
        print("4. .env 파일의 SUPABASE_ANON_KEY 업데이트")
        return False
    else:
        print("✅ Supabase 연결이 정상적으로 작동합니다!")
        return True

if __name__ == "__main__":
    success = test_supabase_connection()
    sys.exit(0 if success else 1)