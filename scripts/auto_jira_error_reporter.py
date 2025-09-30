#!/usr/bin/env python3
"""
Flutter 릴리즈 빌드 에러를 자동으로 JIRA에 등록하는 스크립트
실행: python3 scripts/auto_jira_error_reporter.py
"""

import subprocess
import re
import json
import os
import sys
from datetime import datetime

# JIRA 설정
JIRA_URL = "https://beyond-app.atlassian.net"
JIRA_EMAIL = os.getenv("JIRA_EMAIL", "your-email@example.com")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN", "")
JIRA_PROJECT_KEY = "KAN"

# 로그 파일 경로
LOG_FILE = "/tmp/flutter_release_logs.txt"

# 에러 패턴 정의
ERROR_PATTERNS = [
    # Flutter 빌드 에러
    (r"Error:.*", "build_error"),
    (r"Exception:.*", "exception"),
    (r"FAILURE:.*", "build_failure"),

    # Runtime 에러
    (r"flutter:.*\[ERROR\].*", "runtime_error"),
    (r"flutter:.*Exception.*", "flutter_exception"),

    # Dart 에러
    (r"Unhandled Exception:.*", "unhandled_exception"),
    (r"Failed assertion:.*", "assertion_failed"),

    # UI 에러
    (r"RenderBox.*", "render_error"),
    (r"overflow.*pixels", "ui_overflow"),

    # 네트워크 에러
    (r"SocketException.*", "network_error"),
    (r"TimeoutException.*", "timeout_error"),
]

class JiraErrorReporter:
    def __init__(self):
        self.reported_errors = set()
        self.error_count = 0

    def extract_error_info(self, log_line):
        """로그 라인에서 에러 정보 추출"""
        for pattern, error_type in ERROR_PATTERNS:
            match = re.search(pattern, log_line, re.IGNORECASE)
            if match:
                return {
                    "type": error_type,
                    "message": match.group(0),
                    "full_line": log_line,
                    "timestamp": datetime.now().isoformat()
                }
        return None

    def create_jira_issue(self, error_info):
        """JIRA 이슈 생성"""
        if not JIRA_API_TOKEN:
            print(f"⚠️  JIRA API 토큰이 설정되지 않았습니다. 에러 기록만 수행합니다.")
            return None

        # 에러 메시지 해시로 중복 체크
        error_hash = hash(error_info["message"])
        if error_hash in self.reported_errors:
            print(f"ℹ️  중복 에러 스킵: {error_info['type']}")
            return None

        self.reported_errors.add(error_hash)

        # JIRA 이슈 생성
        summary = f"[자동등록] {error_info['type']}: {error_info['message'][:80]}"
        description = f"""
h3. 에러 정보

*에러 타입:* {error_info['type']}
*발생 시간:* {error_info['timestamp']}

h3. 에러 메시지
{{code}}
{error_info['message']}
{{code}}

h3. 전체 로그 라인
{{code}}
{error_info['full_line']}
{{code}}

h3. 자동 수집 정보
- Flutter 릴리즈 빌드 중 발생
- 버튼 UI 통일 작업 진행 중
- 자동 에러 리포터에 의해 생성됨

🤖 이 이슈는 자동으로 생성되었습니다.
"""

        issue_data = {
            "fields": {
                "project": {"key": JIRA_PROJECT_KEY},
                "summary": summary,
                "description": description,
                "issuetype": {"name": "Bug"},
                "labels": ["auto-reported", "flutter-error", error_info['type']]
            }
        }

        try:
            import requests
            from requests.auth import HTTPBasicAuth

            headers = {
                "Accept": "application/json",
                "Content-Type": "application/json"
            }

            response = requests.post(
                f"{JIRA_URL}/rest/api/3/issue",
                auth=HTTPBasicAuth(JIRA_EMAIL, JIRA_API_TOKEN),
                headers=headers,
                data=json.dumps(issue_data)
            )

            if response.status_code == 201:
                issue_key = response.json()["key"]
                print(f"✅ JIRA 이슈 생성 완료: {issue_key}")
                print(f"   {JIRA_URL}/browse/{issue_key}")
                return issue_key
            else:
                print(f"❌ JIRA 이슈 생성 실패: {response.status_code}")
                print(f"   {response.text}")
                return None

        except ImportError:
            print("⚠️  requests 라이브러리가 필요합니다: pip3 install requests")
            return None
        except Exception as e:
            print(f"❌ JIRA 이슈 생성 중 에러: {e}")
            return None

    def monitor_logs(self):
        """로그 파일 모니터링"""
        print("🔍 Flutter 릴리즈 빌드 에러 모니터링 시작...")
        print(f"📝 로그 파일: {LOG_FILE}")
        print(f"🎯 JIRA 프로젝트: {JIRA_PROJECT_KEY}")
        print("-" * 60)

        try:
            # tail -f 방식으로 로그 모니터링
            with subprocess.Popen(
                ['tail', '-f', LOG_FILE],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                universal_newlines=True
            ) as proc:
                for line in proc.stdout:
                    line = line.strip()
                    if not line:
                        continue

                    # 에러 체크
                    error_info = self.extract_error_info(line)
                    if error_info:
                        self.error_count += 1
                        print(f"\n🚨 에러 감지 #{self.error_count}")
                        print(f"   타입: {error_info['type']}")
                        print(f"   메시지: {error_info['message'][:100]}...")

                        # JIRA 이슈 생성
                        issue_key = self.create_jira_issue(error_info)
                        if issue_key:
                            print(f"   JIRA: {issue_key}")
                        print("-" * 60)
                    else:
                        # 일반 로그는 간단히 표시
                        if "flutter:" in line.lower() or "error" in line.lower():
                            print(f"📋 {line[:100]}...")

        except KeyboardInterrupt:
            print("\n\n⏹️  모니터링 종료")
            print(f"📊 총 {self.error_count}개 에러 감지됨")
            print(f"📝 {len(self.reported_errors)}개 JIRA 이슈 생성됨")
        except FileNotFoundError:
            print(f"❌ 로그 파일을 찾을 수 없습니다: {LOG_FILE}")
            print("   먼저 Flutter 릴리즈 빌드를 실행하세요:")
            print(f"   flutter run --release -d 00008140-00120304260B001C 2>&1 | tee {LOG_FILE}")

def main():
    """메인 함수"""
    print("=" * 60)
    print("🤖 Flutter 자동 JIRA 에러 리포터")
    print("=" * 60)
    print()

    # 환경 변수 체크
    if not JIRA_API_TOKEN:
        print("⚠️  JIRA_API_TOKEN 환경 변수가 설정되지 않았습니다.")
        print("   에러 감지만 수행하고 JIRA 등록은 스킵됩니다.")
        print()
        print("설정 방법:")
        print("  export JIRA_EMAIL='your-email@example.com'")
        print("  export JIRA_API_TOKEN='your-api-token'")
        print()

    reporter = JiraErrorReporter()
    reporter.monitor_logs()

if __name__ == "__main__":
    main()