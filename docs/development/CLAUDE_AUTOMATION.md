# Ondo Project - Claude Automation Guide

## Core Automation System

### 1. JIRA Integration Workflows

#### Automatic JIRA Issue Creation
**Script**: `/Users/jacobmac/Desktop/Dev/fortune/scripts/parse_ux_request.sh`

**Auto-Detection Keywords**:
```yaml
Complaints: "문제야", "이상해", "버그", "안돼", "작동안해", "짜증", "불편"
Improvements: "~하면 좋겠어", "바꿔줘", "개선", "수정해줘"
UX_Issues: "사용하기 어려워", "터치하기 어려워", "보기 힘들어"
Design: "폰트", "색상", "크기", "간격", "레이아웃", "애니메이션"
```

**Category Auto-Classification**:
- **font**: 폰트, 글자, 텍스트, 타이포그래피 → 🔤
- **color**: 색상, 컬러, 테마, 배경색 → 🎨
- **animation**: 애니메이션, 트랜지션, 부드럽, 움직임 → ✨
- **layout**: 레이아웃, 배치, 간격, 여백 → 📐
- **accessibility**: 터치, 클릭, 누르기, 접근성 → ♿
- **navigation**: 네비게이션, 이동, 뒤로가기, 화면전환 → 🧭

**Priority Auto-Assignment**:
- **High**: "급해", "빨리", "중요" keywords OR accessibility issues
- **Medium**: Accessibility-related without urgency
- **Low**: Default priority for general improvements

**Usage Examples**:
```bash
# Manual trigger
./scripts/parse_ux_request.sh "네비게이션바에서 홈 누르면 로딩 화면이 보여서 불편해요"

# Returns: KAN-XX with auto-categorized labels
```

#### Git-JIRA Integration
**Script**: `/Users/jacobmac/Desktop/Dev/fortune/scripts/git_jira_commit.sh`

**One-Command Workflow**: Git commit + JIRA update + GitHub link

**Usage**:
```bash
# Complete task with JIRA done status
./scripts/git_jira_commit.sh "Fix navigation loading issue" "KAN-43" "done"

# Update progress
./scripts/git_jira_commit.sh "Investigating loading behavior" "KAN-43" "in-progress"

# Add comment only
./scripts/git_jira_commit.sh "Code refactoring complete" "KAN-43"
```

**Features**:
- Automatic GitHub commit link injection to JIRA
- JIRA status transition (To Do → In Progress → Done)
- Timestamp tracking
- Single-command execution

### 2. Mandatory Automation Rules

#### Rule 1: Auto-JIRA on User Complaints
**Trigger**: ANY user complaint, improvement request, or UX issue
**Action**: Immediately execute `parse_ux_request.sh`
**No Exceptions**: Cannot skip this step

**Detection Flow**:
```
User: "홈 화면이 너무 느려"
→ [AUTO-DETECT] Complaint keyword detected
→ [AUTO-RUN] parse_ux_request.sh
→ [RESULT] KAN-XX created
→ "JIRA 이슈 KAN-XX 생성 완료! 문제를 해결하겠습니다."
```

#### Rule 2: Auto-Complete on Resolution
**Trigger**: Code fix completed
**Action**: Execute `git_jira_commit.sh` with "done" status
**No Exceptions**: Must close JIRA loop

**Resolution Flow**:
```
[Code Fix Complete]
→ [AUTO-RUN] git_jira_commit.sh "해결내용" "KAN-XX" "done"
→ [RESULT] Git committed + JIRA → Done
→ "해결 완료! JIRA에서도 완료 처리했습니다. 🔗 KAN-XX"
```

### 3. Complete Workflow Examples

#### Example 1: Navigation Loading Issue
```
User: "네비게이션바에서 홈 누르면 로딩 화면 잠시 나오는데 그거 없애면 좋겠어"

Claude Execution:
1. [AUTO] ./scripts/parse_ux_request.sh "네비게이션바에서..."
   → ✅ KAN-43 created (navigation category, low priority)

2. [ANALYSIS] Review HomeNavigationBar, AdLoadingScreen logic

3. [FIX] Remove unnecessary loading state on home navigation

4. [AUTO] ./scripts/git_jira_commit.sh "홈 네비게이션 로딩 화면 제거" "KAN-43" "done"
   → ✅ Git committed + KAN-43 → Done

5. [RESPONSE] "해결 완료! 이제 홈으로 이동 시 로딩 화면이 나타나지 않습니다."
```

#### Example 2: Duplicate Rendering Bug
```
User: "홈 랜딩페이지에서 결과가 두 번씩 나와요"

Claude Execution:
1. [AUTO] ./scripts/parse_ux_request.sh "홈 랜딩페이지에서 결과가 두 번씩 나와요"
   → ✅ KAN-44 created (bug, medium priority)

2. [DEBUG] Investigate LandingPage rendering logic

3. [FIX] Remove duplicate buildFortuneResult calls

4. [AUTO] ./scripts/git_jira_commit.sh "중복 렌더링 제거" "KAN-44" "done"
   → ✅ Git committed + KAN-44 → Done

5. [RESPONSE] "중복 렌더링 문제 해결! 이제 결과가 한 번만 표시됩니다."
```

### 4. Project-Specific Constraints

#### CRITICAL: Batch Modification Prohibition
**ABSOLUTE RULE**: Never use batch modification tools

**Prohibited Actions**:
```bash
# ❌ NEVER use Python batch scripts
for file in files:
    modify(file)  # FORBIDDEN

# ❌ NEVER use shell batch operations
sed -i 's/old/new/g' *.dart  # FORBIDDEN
for file in *.dart; do modify $file; done  # FORBIDDEN

# ❌ NEVER use regex mass replacement
grep -rl "pattern" | xargs sed -i 's/old/new/'  # FORBIDDEN
```

**Correct Method**:
```
✅ ONE FILE AT A TIME
1. Read file
2. Understand context
3. Make precise edit
4. Verify change
5. Move to next file
```

**Violation Consequences**:
- Project-wide build failures
- Cascading errors across modules
- Hours of recovery work
- Git history pollution

**Mantra**: "일괄수정안할거야. 하나씩해" (No batch modifications. One at a time.)

#### App Reinstall After Development
**MANDATORY**: Complete app reinstall after any code changes

**Reinstall Commands**:
```bash
# 1. Kill Flutter processes
pkill -f flutter

# 2. Clean build cache
flutter clean

# 3. Reinstall dependencies
flutter pub get

# 4. Uninstall from simulator
xcrun simctl uninstall 1B54EF52-7E41-4040-A236-C169898F5527 com.beyond.ondo

# 5. Fresh install and run
flutter run -d 1B54EF52-7E41-4040-A236-C169898F5527
```

**Why**: Hot Reload/Restart may not reflect all changes properly

### 5. Script Locations

```
/Users/jacobmac/Desktop/Dev/fortune/scripts/
├── parse_ux_request.sh          # NL → JIRA issue creation
├── git_jira_commit.sh           # Git commit + JIRA integration
└── create_ux_request.sh         # Manual UX request (legacy)
```

### 6. Automation Effectiveness

**Before Automation**:
1. User complaint → Manual JIRA creation (5-10 min)
2. Manual category/priority assignment
3. Code fix
4. Manual Git commit
5. Manual JIRA status update
6. Manual link copy/paste

**Total Time**: 10-15 minutes per issue

**After Automation**:
1. User complaint → Auto JIRA creation (0 min)
2. Code fix
3. Auto Git commit + JIRA done (0 min)

**Total Time**: 0 minutes overhead (100% automated)

**Benefits**:
- 100% issue tracking coverage
- Zero manual errors
- Complete Git-JIRA traceability
- Immediate user feedback

### 7. Integration with CLAUDE.md

These automation rules are permanently embedded in `/Users/jacobmac/Desktop/Dev/fortune/CLAUDE.md` and automatically enforced by Claude Code for this project.

**Priority Order**:
1. Auto-JIRA on complaints (highest priority)
2. Auto-complete on resolution
3. NO batch modifications (absolute rule)
4. Complete app reinstall verification
