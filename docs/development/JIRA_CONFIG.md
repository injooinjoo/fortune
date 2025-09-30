# JIRA Project Configuration

## Project Information
- **JIRA URL**: https://beyond-app.atlassian.net
- **Project Key**: KAN
- **Project Board**: https://beyond-app.atlassian.net/jira/software/projects/KAN/boards/1
- **Project Type**: Software Development

## Issue Management Guidelines

### Bug Report Template
```
Title: [BUG] {Brief description}
Type: Bug
Priority: {Critical/High/Medium/Low}
Component: {Frontend/Backend/Database/API}

Description:
- Summary:
- Steps to Reproduce:
- Expected Result:
- Actual Result:
- Error Log:
- Environment: iOS/Android/Web

Labels: fortune-app, flutter
```

### Issue Types
- **Bug**: 앱 오류 및 버그
- **Task**: 개발 작업
- **Story**: 새로운 기능
- **Epic**: 대규모 기능 그룹

## Current Issues (2025-09-27)

### ✅ Resolved Issues
1. **KAN-1: API Network Error** ✅ **RESOLVED**
   - Fortune API returns NetworkException
   - Supabase Edge Functions URL configuration issue
   - **Fix**: Updated Environment.apiBaseUrl to return `${supabaseUrl}/functions/v1`
   - Status: **CLOSED**

2. **KAN-2: Widget Lifecycle Error** ✅ **RESOLVED**
   - PersonalityDNAPage dispose() error
   - "Cannot use ref after widget disposed"
   - **Fix**: Added `mounted` check before ref usage in dispose()
   - Status: **CLOSED**

3. **KAN-3: Toast Null Safety Error** ✅ **RESOLVED**
   - Overlay.of(context) returns null
   - Causes app crash on error display
   - **Fix**: Changed to `Overlay.maybeOf(context)` with null check
   - Status: **CLOSED**

4. **KAN-4: Database Schema Issue** ✅ **RESOLVED**
   - korean_holidays table missing
   - PostgrestException: relation does not exist
   - **Fix**: Already handled with try-catch and fallback data in HolidayService
   - Status: **CLOSED**

### 🟢 Low Priority
5. **Ad Loading Issues**
   - Interstitial ads not ready
   - Callback executed immediately
   - Status: Open (Low Priority)

## API Integration (Future MCP)
```bash
# Create issue via JIRA REST API
curl -X POST https://beyond-app.atlassian.net/rest/api/2/issue \
  -H "Authorization: Bearer {API_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": {
      "project": {"key": "KAN"},
      "summary": "Issue title",
      "issuetype": {"name": "Bug"},
      "description": "Issue description"
    }
  }'
```

## Bug Management Process

### 1. Automated Error Detection
```bash
# Run Flutter app in release mode with error monitoring
flutter run --release -d 00008140-00120304260B001C 2>&1 | tee /tmp/flutter_release_logs.txt

# Run error monitoring script
python3 error_to_jira.py
```

### 2. Error Classification
- **Critical**: App crashes, major functionality broken
- **High**: API errors, network failures, core features affected
- **Medium**: UI/UX issues, minor functionality problems
- **Low**: Warnings, performance optimizations

### 3. JIRA Integration Status
✅ **MCP Server**: Configured and tested
✅ **API Connection**: Working with REST API
✅ **Project Access**: KAN project accessible
✅ **Auto-creation**: Python script ready

### 4. Process Workflow
1. **Detection**: Automated monitoring of release mode logs
2. **Classification**: Error pattern matching and severity assignment
3. **Creation**: Automatic JIRA issue creation with detailed context
4. **Assignment**: Auto-assign to injooinjoo@gmail.com
5. **Tracking**: Label-based categorization and progress monitoring

### 5. Recent Issues Created
- **KAN-1**: ✅ API Base URL Configuration Issue (RESOLVED)
- **KAN-2**: Widget Lifecycle Error (RESOLVED)
- **KAN-3**: Toast Null Safety Error (RESOLVED)
- **KAN-4**: Database Schema Issue (RESOLVED)

### 6. Current Release Mode Issues
- **ServerException**: 404 Function not found (Detected 2025-09-27)
- **Remote Config Error**: Firebase initialization failure

## MCP Integration Details

### JIRA MCP Server Configuration
```json
{
  "mcpServers": {
    "jira-mcp": {
      "command": "node",
      "args": ["/Users/jacobmac/jira-mcp/build/index.js"],
      "env": {
        "JIRA_HOST": "beyond-app.atlassian.net",
        "JIRA_USERNAME": "injooinjoo@gmail.com",
        "JIRA_API_TOKEN": "[CONFIGURED]",
        "JIRA_PROJECT_KEY": "KAN",
        "AUTO_CREATE_TEST_TICKETS": "false"
      }
    }
  }
}
```

### Available MCP Commands
- `create-ticket`: Create new JIRA tickets
- `get-ticket`: Retrieve ticket information
- `search-tickets`: Search existing tickets
- `update-ticket`: Update ticket status/description
- `link-tickets`: Link related tickets

## Error Monitoring Script

### Features
- Real-time log monitoring
- Pattern-based error detection
- Automatic JIRA issue creation
- Duplicate prevention (hash-based)
- Severity classification
- Rich error context

### Usage
```bash
# Process existing logs
python3 error_to_jira.py

# Choose monitoring mode:
# 1. Process existing log file
# 2. Monitor log file in real-time
# 3. Both (recommended)
```

## Notes
- ✅ JIRA MCP integration active
- ✅ Automated error detection working
- ✅ Issue creation tested and functional
- 🔄 Real-time monitoring ready for deployment