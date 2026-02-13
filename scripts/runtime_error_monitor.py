#!/usr/bin/env python3
"""
Flutter Runtime Error Monitor - JIRA Auto Reporter
실시간으로 Flutter 앱의 런타임 에러를 감지하여 자동으로 JIRA에 등록합니다.

사용법:
  python3 scripts/runtime_error_monitor.py

백그라운드 실행:
  nohup python3 scripts/runtime_error_monitor.py > /tmp/error_monitor.log 2>&1 &
"""

import json
import os
import sys
import time
import subprocess
from datetime import datetime
from pathlib import Path

# JIRA 설정 (환경변수에서 로드)
JIRA_URL = os.getenv("JIRA_URL", "https://beyond-app.atlassian.net")
JIRA_EMAIL = os.getenv("JIRA_EMAIL", "")
JIRA_TOKEN = os.getenv("JIRA_API_TOKEN", "")
JIRA_PROJECT_KEY = os.getenv("JIRA_PROJECT_KEY", "KAN")

# 환경변수 검증
if not JIRA_EMAIL or not JIRA_TOKEN:
    print("❌ 오류: JIRA 환경변수가 설정되지 않았습니다.")
    print("   export JIRA_EMAIL='your-email'")
    print("   export JIRA_API_TOKEN='your-token'")
    sys.exit(1)

# 에러 로그 파일 경로
ERROR_LOG_PATH = "/tmp/fortune_runtime_errors.json"
PROCESSED_ERRORS_PATH = "/tmp/fortune_processed_errors.json"

# 모니터링 간격 (초)
MONITOR_INTERVAL = 5

class RuntimeErrorMonitor:
    def __init__(self):
        self.processed_error_hashes = self._load_processed_errors()
        self.session_start_time = datetime.now()
        self.total_errors_detected = 0
        self.total_jira_created = 0

    def _load_processed_errors(self):
        """이미 처리된 에러 해시 로드"""
        try:
            if os.path.exists(PROCESSED_ERRORS_PATH):
                with open(PROCESSED_ERRORS_PATH, 'r') as f:
                    data = json.load(f)
                    return set(data.get('processed_hashes', []))
        except Exception as e:
            print(f"⚠️  Failed to load processed errors: {e}")
        return set()

    def _save_processed_error(self, error_hash):
        """처리된 에러 해시 저장"""
        try:
            self.processed_error_hashes.add(error_hash)

            with open(PROCESSED_ERRORS_PATH, 'w') as f:
                json.dump({
                    'processed_hashes': list(self.processed_error_hashes),
                    'last_updated': datetime.now().isoformat()
                }, f, indent=2)
        except Exception as e:
            print(f"⚠️  Failed to save processed error: {e}")

    def _classify_error_priority(self, error):
        """에러 우선순위 자동 판단"""
        error_type = error.get('error_type', '').lower()
        error_message = error.get('error_message', '').lower()
        occurrence_count = error.get('occurrence_count', 1)

        # Critical: 네트워크, Null Pointer, Assertion (또는 10회 이상 발생)
        if occurrence_count >= 10:
            return 'critical', 'Highest'
        elif 'network' in error_type or 'nullpointer' in error_type or 'assertion' in error_type:
            return 'critical', 'Highest'

        # High: UI 렌더 에러, Exception (또는 5회 이상 발생)
        elif occurrence_count >= 5:
            return 'high', 'High'
        elif 'uirender' in error_type or 'exception' in error_type:
            return 'high', 'High'

        # Medium: Timeout, Error
        elif 'timeout' in error_type or 'error' in error_type:
            return 'medium', 'Medium'

        # Low: 기타
        else:
            return 'low', 'Low'

    def _classify_issue_type(self, error):
        """이슈 타입 분류"""
        error_type = error.get('error_type', '').lower()

        if 'network' in error_type or 'timeout' in error_type:
            return 'Bug', ['auto-error', 'runtime', 'network', 'backend']
        elif 'uirender' in error_type or 'overflow' in error_type:
            return 'Bug', ['auto-error', 'runtime', 'ui', 'rendering']
        elif 'nullpointer' in error_type or 'assertion' in error_type:
            return 'Bug', ['auto-error', 'runtime', 'crash', 'critical']
        else:
            return 'Bug', ['auto-error', 'runtime', 'general']

    def _create_jira_issue(self, error):
        """JIRA 이슈 생성"""
        error_hash = error.get('error_hash')

        # 중복 체크
        if error_hash in self.processed_error_hashes:
            return None

        # 우선순위 판단
        priority_label, priority_name = self._classify_error_priority(error)
        issue_type, labels = self._classify_issue_type(error)

        # 우선순위 라벨 추가
        labels.append(f'{priority_label}-priority')

        # 제목 생성 (50자 제한)
        error_type = error.get('error_type', 'Unknown')
        error_message = error.get('error_message', '')
        title = f"[자동등록] [{error_type}] {error_message[:50]}"

        # 설명 생성
        timestamp = error.get('timestamp', 'Unknown')
        stack_trace = error.get('stack_trace', 'No stack trace')
        context = error.get('context', 'N/A')
        build_mode = error.get('build_mode', 'Unknown')
        platform = error.get('platform', 'Unknown')
        occurrence_count = error.get('occurrence_count', 1)
        last_occurrence = error.get('last_occurrence', timestamp)

        description = f"""h2. 🚨 자동 에러 리포트

h3. 에러 정보
| *항목* | *내용* |
| 에러 타입 | {error_type} |
| 우선순위 | {priority_name} ({priority_label}) |
| 발생 횟수 | {occurrence_count}회 |
| 최초 발생 | {timestamp} |
| 최근 발생 | {last_occurrence} |
| 빌드 모드 | {build_mode} |
| 플랫폼 | {platform} |

h3. 에러 메시지
{{code}}
{error_message}
{{code}}

h3. Stack Trace (처음 10줄)
{{code}}
{stack_trace}
{{code}}

h3. Context
{{code}}
{context}
{{code}}

h3. 자동 분류 결과
- *이슈 타입*: {issue_type}
- *우선순위*: {priority_name}
- *카테고리*: {', '.join(labels)}

---

h3. 대응 가이드
1. Stack trace를 통해 에러 발생 위치 확인
2. 빌드 모드({build_mode})에서 재현 테스트
3. 근본 원인 파악 및 수정
4. 테스트 후 완료 처리

🤖 이 이슈는 실시간 에러 모니터링 시스템에 의해 자동으로 생성되었습니다.
📅 생성 일시: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
"""

        # JIRA API 호출
        issue_data = {
            "fields": {
                "project": {"key": JIRA_PROJECT_KEY},
                "summary": title,
                "description": description,
                "issuetype": {"name": issue_type},
                "labels": labels,
                # priority는 프로젝트 설정에 따라 다를 수 있으므로 생략
            }
        }

        try:
            # curl 명령어 사용 (requests 라이브러리 없이)
            import base64
            auth_string = f"{JIRA_EMAIL}:{JIRA_TOKEN}"
            auth_bytes = auth_string.encode('ascii')
            auth_b64 = base64.b64encode(auth_bytes).decode('ascii')

            curl_command = [
                'curl', '-s', '-X', 'POST',
                f"{JIRA_URL}/rest/api/2/issue",
                '-H', f'Authorization: Basic {auth_b64}',
                '-H', 'Accept: application/json',
                '-H', 'Content-Type: application/json',
                '-d', json.dumps(issue_data)
            ]

            result = subprocess.run(
                curl_command,
                capture_output=True,
                text=True,
                timeout=30
            )

            if result.returncode == 0:
                response = json.loads(result.stdout)
                issue_key = response.get('key')

                if issue_key:
                    print(f"✅ JIRA 이슈 생성 완료: {issue_key}")
                    print(f"   🔗 {JIRA_URL}/browse/{issue_key}")
                    print(f"   📝 타입: {error_type} | 우선순위: {priority_name}")
                    print(f"   🔢 발생 횟수: {occurrence_count}회")

                    # 처리 완료 기록
                    self._save_processed_error(error_hash)
                    self.total_jira_created += 1

                    return issue_key
                else:
                    print(f"❌ JIRA 이슈 생성 실패: {result.stdout}")
                    return None
            else:
                print(f"❌ curl 명령 실패: {result.stderr}")
                return None

        except Exception as e:
            print(f"❌ JIRA 이슈 생성 중 에러: {e}")
            return None

    def _process_error_log(self):
        """에러 로그 파일 읽고 처리"""
        if not os.path.exists(ERROR_LOG_PATH):
            return

        try:
            with open(ERROR_LOG_PATH, 'r') as f:
                content = f.read().strip()

                if not content:
                    return

                errors = json.loads(content)

                if not isinstance(errors, list):
                    print(f"⚠️  Invalid error log format")
                    return

                # 새 에러만 처리
                new_errors = [
                    error for error in errors
                    if error.get('error_hash') not in self.processed_error_hashes
                ]

                if new_errors:
                    print(f"\n🔍 {len(new_errors)}개의 새 에러 감지됨")
                    print("=" * 60)

                    for error in new_errors:
                        self.total_errors_detected += 1
                        print(f"\n🚨 에러 #{self.total_errors_detected}")
                        print(f"   타입: {error.get('error_type')}")
                        print(f"   메시지: {error.get('error_message', '')[:80]}...")
                        print(f"   발생 횟수: {error.get('occurrence_count', 1)}회")

                        # JIRA 이슈 생성
                        issue_key = self._create_jira_issue(error)

                        print("-" * 60)

        except json.JSONDecodeError as e:
            print(f"⚠️  Failed to parse error log: {e}")
        except Exception as e:
            print(f"⚠️  Error processing log: {e}")

    def run(self):
        """모니터링 시작"""
        print("=" * 60)
        print("🤖 Flutter Runtime Error Monitor")
        print("=" * 60)
        print(f"📝 에러 로그: {ERROR_LOG_PATH}")
        print(f"🎯 JIRA 프로젝트: {JIRA_PROJECT_KEY}")
        print(f"⏰ 모니터링 간격: {MONITOR_INTERVAL}초")
        print(f"🚀 시작 시간: {self.session_start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print("=" * 60)
        print("\n✅ 모니터링 시작됨 (Ctrl+C로 종료)\n")

        try:
            while True:
                self._process_error_log()
                time.sleep(MONITOR_INTERVAL)

        except KeyboardInterrupt:
            print("\n\n⏹️  모니터링 종료")
            self._print_summary()

    def _print_summary(self):
        """세션 요약 출력"""
        uptime = datetime.now() - self.session_start_time
        uptime_str = str(uptime).split('.')[0]  # 초 단위까지만

        print("=" * 60)
        print("📊 모니터링 세션 요약")
        print("=" * 60)
        print(f"⏱️  실행 시간: {uptime_str}")
        print(f"🚨 감지된 에러: {self.total_errors_detected}개")
        print(f"📝 생성된 JIRA: {self.total_jira_created}개")
        print(f"🔗 JIRA 프로젝트: {JIRA_URL}/browse/{JIRA_PROJECT_KEY}")
        print("=" * 60)

def main():
    """메인 함수"""
    monitor = RuntimeErrorMonitor()
    monitor.run()

if __name__ == "__main__":
    main()
