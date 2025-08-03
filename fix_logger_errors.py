#!/usr/bin/env python3
import re

# Read the file
with open('/Users/jacobmac/Desktop/Dev/fortune/lib/data/services/fortune_api_service.dart', 'r') as f:
    content = f.read()

# Fix patterns like Logger.error('message': e, stackTrace)
content = re.sub(r"Logger\.error\('([^']+)':\s*e,\s*stackTrace\)", r"Logger.error('\1', e, stackTrace)", content)

# Write the fixed content back
with open('/Users/jacobmac/Desktop/Dev/fortune/lib/data/services/fortune_api_service.dart', 'w') as f:
    f.write(content)

print("Fixed Logger.error colon syntax errors in fortune_api_service.dart")