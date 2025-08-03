#!/usr/bin/env python3
import re

# Read the file
with open('/Users/jacobmac/Desktop/Dev/fortune/lib/data/services/fortune_api_service.dart', 'r') as f:
    content = f.read()

# Fix patterns like getFortune(fortuneType: 'yearly': userId: userId)
content = re.sub(r"getFortune\(fortuneType: '([^']+)': userId: userId\)", r"getFortune(fortuneType: '\1', userId: userId)", content)

# Fix patterns like Logger.endTimer('API Call - daily': cacheStopwatch)
content = re.sub(r"Logger\.endTimer\('([^']+)': ([^)]+)\)", r"Logger.endTimer('\1', \2)", content)

# Fix patterns like Logger.info('message': {
content = re.sub(r"(Logger\.\w+\('([^']+))': \{", r"\1', {", content)

# Fix patterns like await _cacheService.getCachedFortune('daily': params)
content = re.sub(r"getCachedFortune\('([^']+)': ([^)]+)\)", r"getCachedFortune('\1', \2)", content)

# Fix patterns like .eq('user_id': userId)
content = re.sub(r"\.eq\('([^']+)': ([^)]+)\)", r".eq('\1', \2)", content)

# Fix patterns like .gte('created_at': startDate.toIso8601String())
content = re.sub(r"\.gte\('([^']+)': ([^)]+)\)", r".gte('\1', \2)", content)

# Fix patterns like .order('created_at': ascending: true)
content = re.sub(r"\.order\('([^']+)': ascending: ([^)]+)\)", r".order('\1', ascending: \2)", content)

# Fix patterns like ServerException(message: '서버 오류가 발생했습니다': statusCode: 500)
content = re.sub(r"ServerException\(message: '([^']+)': statusCode: (\d+)\)", r"ServerException(message: '\1', statusCode: \2)", content)

# Write the fixed content back
with open('/Users/jacobmac/Desktop/Dev/fortune/lib/data/services/fortune_api_service.dart', 'w') as f:
    f.write(content)

print("Fixed colon syntax errors in fortune_api_service.dart")