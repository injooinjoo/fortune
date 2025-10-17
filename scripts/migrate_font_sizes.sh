#!/bin/bash

# 폰트 크기 자동 마이그레이션 스크립트
# Usage: ./scripts/migrate_font_sizes.sh [file_path]

set -e

FILE_PATH="$1"

if [ -z "$FILE_PATH" ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
  echo "Error: File not found: $FILE_PATH"
  exit 1
fi

echo "🔄 Migrating font sizes in: $FILE_PATH"

# Backup
cp "$FILE_PATH" "${FILE_PATH}.bak"

# TypographyUnified import 추가 (없는 경우에만)
if ! grep -q "import 'package:fortune/core/theme/typography_unified.dart'" "$FILE_PATH"; then
  # material.dart import 다음에 추가
  if grep -q "import 'package:flutter/material.dart'" "$FILE_PATH"; then
    sed -i '' "/import 'package:flutter\/material.dart'/a\\
import 'package:fortune/core/theme/typography_unified.dart';
" "$FILE_PATH"
    echo "✅ Added TypographyUnified import"
  fi
fi

# 간단한 패턴 변환 (fontSize만 있는 경우)
# 48pt → TypographyUnified.displayLarge
sed -i '' 's/TextStyle(fontSize: 48,/TypographyUnified.displayLarge.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 48,/fontSize: FontSizeSystem.displayLargeScaled,/g' "$FILE_PATH"

# 40pt → TypographyUnified.displayMedium
sed -i '' 's/TextStyle(fontSize: 40,/TypographyUnified.displayMedium.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 40,/fontSize: FontSizeSystem.displayMediumScaled,/g' "$FILE_PATH"

# 32pt → TypographyUnified.displaySmall
sed -i '' 's/TextStyle(fontSize: 32,/TypographyUnified.displaySmall.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 32,/fontSize: FontSizeSystem.displaySmallScaled,/g' "$FILE_PATH"

# 28pt → TypographyUnified.heading1
sed -i '' 's/TextStyle(fontSize: 28,/TypographyUnified.heading1.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 28,/fontSize: FontSizeSystem.heading1Scaled,/g' "$FILE_PATH"

# 24pt → TypographyUnified.heading2
sed -i '' 's/TextStyle(fontSize: 24,/TypographyUnified.heading2.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 24,/fontSize: FontSizeSystem.heading2Scaled,/g' "$FILE_PATH"

# 20pt → TypographyUnified.heading3
sed -i '' 's/TextStyle(fontSize: 20,/TypographyUnified.heading3.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 20,/fontSize: FontSizeSystem.heading3Scaled,/g' "$FILE_PATH"

# 18pt → TypographyUnified.heading4
sed -i '' 's/TextStyle(fontSize: 18,/TypographyUnified.heading4.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 18,/fontSize: FontSizeSystem.heading4Scaled,/g' "$FILE_PATH"

# 17pt → TypographyUnified.bodyLarge
sed -i '' 's/TextStyle(fontSize: 17,/TypographyUnified.bodyLarge.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 17,/fontSize: FontSizeSystem.bodyLargeScaled,/g' "$FILE_PATH"

# 16pt → TypographyUnified.buttonMedium (가장 많이 사용됨, 버튼/중요 텍스트)
sed -i '' 's/TextStyle(fontSize: 16,/TypographyUnified.buttonMedium.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 16,/fontSize: FontSizeSystem.buttonMediumScaled,/g' "$FILE_PATH"

# 15pt → TypographyUnified.bodyMedium
sed -i '' 's/TextStyle(fontSize: 15,/TypographyUnified.bodyMedium.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 15,/fontSize: FontSizeSystem.bodyMediumScaled,/g' "$FILE_PATH"

# 14pt → TypographyUnified.bodySmall (가장 많이 사용됨, 기본 본문)
sed -i '' 's/TextStyle(fontSize: 14,/TypographyUnified.bodySmall.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 14,/fontSize: FontSizeSystem.bodySmallScaled,/g' "$FILE_PATH"

# 13pt → TypographyUnified.labelLarge
sed -i '' 's/TextStyle(fontSize: 13,/TypographyUnified.labelLarge.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 13,/fontSize: FontSizeSystem.labelLargeScaled,/g' "$FILE_PATH"

# 12pt → TypographyUnified.labelMedium
sed -i '' 's/TextStyle(fontSize: 12,/TypographyUnified.labelMedium.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 12,/fontSize: FontSizeSystem.labelMediumScaled,/g' "$FILE_PATH"

# 11pt → TypographyUnified.labelSmall
sed -i '' 's/TextStyle(fontSize: 11,/TypographyUnified.labelSmall.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 11,/fontSize: FontSizeSystem.labelSmallScaled,/g' "$FILE_PATH"

# 10pt → TypographyUnified.labelTiny
sed -i '' 's/TextStyle(fontSize: 10,/TypographyUnified.labelTiny.copyWith(/g' "$FILE_PATH"
sed -i '' 's/fontSize: 10,/fontSize: FontSizeSystem.labelTinyScaled,/g' "$FILE_PATH"

echo "✅ Migration completed"
echo "⚠️  Please review the changes manually, especially:"
echo "   - Complex TextStyle with multiple properties"
echo "   - Context-dependent font sizes"
echo "   - Dark mode color handling"
echo ""
echo "📁 Backup saved at: ${FILE_PATH}.bak"
