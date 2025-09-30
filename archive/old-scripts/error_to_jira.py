#!/usr/bin/env python3
"""
Flutter Release Mode Error Monitor & JIRA Auto-Reporter
실시간으로 Flutter 에러를 모니터링하고 자동으로 JIRA 이슈를 생성합니다.
"""

import re
import json
import time
import hashlib
import requests
import subprocess
from datetime import datetime
from typing import List, Dict, Set
import base64

class JiraErrorReporter:
    def __init__(self):
        self.jira_host = "https://beyond-app.atlassian.net"
        self.username = "injooinjoo@gmail.com"
        self.api_token = "ATATT3xFfGF0e3diiy0TFqT7AyCmZDVHQ5o_7ysG2ioH9bu0uIf6Ai1n0mGLgSIvtzGXzNqAxchMeCR3hyH1WTb1b7zqpz6vVbDwXfn1i9N28V3etR2bMZVRGm3xsxL9vRi89EU9z2uzH3XoRwBRVAW5yWUo1AS3PGaETYHJPEPtFqh8ft82RRE=CAF65568"
        self.project_key = "KAN"

        # 이미 처리된 에러의 해시값들 (중복 방지)
        self.processed_errors: Set[str] = set()

        # JIRA 인증 헤더 생성
        auth_string = f"{self.username}:{self.api_token}"
        auth_bytes = auth_string.encode('ascii')
        auth_b64 = base64.b64encode(auth_bytes).decode('ascii')
        self.headers = {
            "Authorization": f"Basic {auth_b64}",
            "Content-Type": "application/json"
        }

        print(f"🚀 JIRA Error Reporter initialized")
        print(f"📊 Monitoring: Flutter Release Mode")
        print(f"🎯 Target: {self.jira_host}/projects/{self.project_key}")

    def extract_errors_from_log(self, log_content: str) -> List[Dict]:
        """로그에서 에러를 추출하고 분류합니다."""
        errors = []

        # 다양한 에러 패턴들
        error_patterns = [
            # Flutter/Dart 에러
            {
                'type': 'Flutter Runtime Error',
                'pattern': r'(ERROR:flutter/.*?)\n(.*?)(?=\n\s*$|\nflutter:|\n\[)',
                'severity': 'Critical'
            },
            # Exception 에러
            {
                'type': 'Dart Exception',
                'pattern': r'(Unhandled Exception:.*?)\n(.*?)(?=\n#|\nFlutter:|$)',
                'severity': 'High'
            },
            # 네트워크 에러
            {
                'type': 'Network Error',
                'pattern': r'(SocketException|NetworkException|HttpException|TimeoutException):(.*?)(?=\n|$)',
                'severity': 'High'
            },
            # Platform 에러
            {
                'type': 'Platform Error',
                'pattern': r'(PlatformException):(.*?)(?=\n|$)',
                'severity': 'Medium'
            },
            # API 에러
            {
                'type': 'API Error',
                'pattern': r'(\[ERROR\].*?API.*?)\n(.*?)(?=\n\[|\nflutter:|$)',
                'severity': 'High'
            },
            # 일반 에러
            {
                'type': 'General Error',
                'pattern': r'(\[ERROR\].*?)\n(.*?)(?=\n\[|\nflutter:|$)',
                'severity': 'Medium'
            }
        ]

        for error_def in error_patterns:
            matches = re.finditer(error_def['pattern'], log_content, re.MULTILINE | re.DOTALL)
            for match in matches:
                error_text = match.group(0).strip()

                # 에러 해시 생성 (중복 방지용)
                error_hash = hashlib.md5(error_text.encode()).hexdigest()

                if error_hash not in self.processed_errors:
                    errors.append({
                        'type': error_def['type'],
                        'severity': error_def['severity'],
                        'content': error_text,
                        'hash': error_hash,
                        'timestamp': datetime.now().isoformat()
                    })
                    self.processed_errors.add(error_hash)

        return errors

    def create_jira_issue(self, error: Dict) -> str:
        """JIRA 이슈를 생성합니다."""

        # 이슈 제목 생성
        summary = f"[{error['severity'].upper()}] {error['type']} - {datetime.now().strftime('%Y-%m-%d %H:%M')}"

        # 이슈 설명 생성
        description = f"""**Error Type:** {error['type']}
**Severity:** {error['severity']}
**Detected:** {error['timestamp']}
**Build Mode:** Release
**Platform:** iOS (Real Device)

**Error Details:**
```
{error['content']}
```

**Environment:**
- Flutter: Release Mode
- Device: iPhone 16 Pro (Real Device)
- Detected by: Automated Error Monitor
- Error Hash: {error['hash']}

**Next Steps:**
1. Reproduce the error
2. Identify root cause
3. Implement fix
4. Test in release mode
5. Verify resolution

---
*This issue was automatically created by the Error Monitoring System.*"""

        # 심각도에 따른 우선순위 매핑
        priority_map = {
            'Critical': 'Highest',
            'High': 'High',
            'Medium': 'Medium',
            'Low': 'Low'
        }

        issue_data = {
            "fields": {
                "project": {"key": self.project_key},
                "summary": summary,
                "description": description,
                "issuetype": {"id": "10001"},  # Task
                "assignee": {"emailAddress": self.username},
                "labels": [
                    "automated-detection",
                    "release-mode",
                    "error-monitoring",
                    error['type'].lower().replace(' ', '-')
                ]
            }
        }

        try:
            response = requests.post(
                f"{self.jira_host}/rest/api/2/issue",
                headers=self.headers,
                json=issue_data,
                timeout=30
            )

            if response.status_code == 201:
                issue_info = response.json()
                issue_key = issue_info['key']
                issue_url = f"{self.jira_host}/browse/{issue_key}"

                print(f"✅ JIRA Issue Created: {issue_key}")
                print(f"🔗 URL: {issue_url}")
                print(f"📝 Summary: {summary}")

                return issue_key
            else:
                print(f"❌ Failed to create JIRA issue: {response.status_code}")
                print(f"Response: {response.text}")
                return None

        except Exception as e:
            print(f"❌ Error creating JIRA issue: {str(e)}")
            return None

    def monitor_log_file(self, log_file_path: str):
        """로그 파일을 실시간으로 모니터링합니다."""
        print(f"📁 Monitoring log file: {log_file_path}")

        # 초기 파일 크기 기록
        try:
            with open(log_file_path, 'r') as f:
                f.seek(0, 2)  # 파일 끝으로 이동
                last_position = f.tell()
        except FileNotFoundError:
            last_position = 0
            print(f"⚠️ Log file not found yet, waiting...")

        while True:
            try:
                with open(log_file_path, 'r') as f:
                    f.seek(last_position)
                    new_content = f.read()

                    if new_content:
                        print(f"📊 New log content detected ({len(new_content)} chars)")

                        # 에러 추출
                        errors = self.extract_errors_from_log(new_content)

                        if errors:
                            print(f"🚨 Found {len(errors)} new error(s)!")

                            for error in errors:
                                print(f"🔍 Processing: {error['type']} ({error['severity']})")
                                issue_key = self.create_jira_issue(error)

                                if issue_key:
                                    print(f"✅ Error processed successfully: {issue_key}")
                                else:
                                    print(f"❌ Failed to process error")

                                # API 호출 간격 조절
                                time.sleep(2)

                        last_position = f.tell()

                time.sleep(5)  # 5초마다 체크

            except FileNotFoundError:
                time.sleep(5)
                continue
            except KeyboardInterrupt:
                print("🛑 Monitoring stopped by user")
                break
            except Exception as e:
                print(f"❌ Monitoring error: {str(e)}")
                time.sleep(10)

    def process_existing_log(self, log_file_path: str):
        """기존 로그 파일의 모든 에러를 처리합니다."""
        try:
            with open(log_file_path, 'r') as f:
                content = f.read()

            print(f"📁 Processing existing log file: {log_file_path}")
            errors = self.extract_errors_from_log(content)

            if errors:
                print(f"🚨 Found {len(errors)} error(s) in existing log!")

                for i, error in enumerate(errors, 1):
                    print(f"🔍 Processing error {i}/{len(errors)}: {error['type']}")
                    issue_key = self.create_jira_issue(error)

                    if issue_key:
                        print(f"✅ Error {i} processed: {issue_key}")
                    else:
                        print(f"❌ Failed to process error {i}")

                    # API 호출 간격 조절
                    time.sleep(2)
            else:
                print("✅ No errors found in existing log")

        except FileNotFoundError:
            print(f"⚠️ Log file not found: {log_file_path}")
        except Exception as e:
            print(f"❌ Error processing log: {str(e)}")

if __name__ == "__main__":
    reporter = JiraErrorReporter()
    log_file = "/tmp/flutter_release_logs.txt"

    print("🔄 Choose mode:")
    print("1. Process existing log file")
    print("2. Monitor log file in real-time")
    print("3. Both (process existing + monitor)")

    choice = input("Enter choice (1/2/3): ").strip()

    if choice == "1":
        reporter.process_existing_log(log_file)
    elif choice == "2":
        reporter.monitor_log_file(log_file)
    elif choice == "3":
        reporter.process_existing_log(log_file)
        print("\n🔄 Switching to real-time monitoring...")
        reporter.monitor_log_file(log_file)
    else:
        print("❌ Invalid choice")