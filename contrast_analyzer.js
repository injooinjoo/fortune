// Fortune 앱 다크모드 컨트라스트 및 가독성 검증 도구
// WCAG 2.1 AA 기준 (4.5:1) 및 AAA 기준 (7:1) 준수 검증

const fs = require('fs');
const path = require('path');

// WCAG 컨트라스트 계산 함수
function calculateContrast(color1, color2) {
    const luminance1 = getLuminance(color1);
    const luminance2 = getLuminance(color2);

    const lighter = Math.max(luminance1, luminance2);
    const darker = Math.min(luminance1, luminance2);

    return (lighter + 0.05) / (darker + 0.05);
}

// 상대 휘도 계산
function getLuminance(color) {
    const { r, g, b } = parseColor(color);

    const [rs, gs, bs] = [r, g, b].map(c => {
        c = c / 255;
        return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
    });

    return 0.2126 * rs + 0.7152 * gs + 0.0722 * bs;
}

// 색상 파싱 (RGB, HEX, named colors 지원)
function parseColor(color) {
    // 색상이 문자열이 아닌 경우 처리
    if (typeof color !== 'string') {
        console.warn(`Invalid color type: ${typeof color}, value: ${color}`);
        return { r: 0, g: 0, b: 0 };
    }

    // 빈 문자열 처리
    if (!color || color.trim() === '') {
        return { r: 0, g: 0, b: 0 };
    }

    // RGB 형식 파싱
    const rgbMatch = color.match(/rgb\((\d+),\s*(\d+),\s*(\d+)\)/);
    if (rgbMatch) {
        return {
            r: parseInt(rgbMatch[1]),
            g: parseInt(rgbMatch[2]),
            b: parseInt(rgbMatch[3])
        };
    }

    // RGBA 형식 파싱
    const rgbaMatch = color.match(/rgba\((\d+),\s*(\d+),\s*(\d+),\s*[\d.]+\)/);
    if (rgbaMatch) {
        return {
            r: parseInt(rgbaMatch[1]),
            g: parseInt(rgbaMatch[2]),
            b: parseInt(rgbaMatch[3])
        };
    }

    // HEX 형식 파싱
    const hexMatch = color.match(/^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i);
    if (hexMatch) {
        return {
            r: parseInt(hexMatch[1], 16),
            g: parseInt(hexMatch[2], 16),
            b: parseInt(hexMatch[3], 16)
        };
    }

    // Named colors
    const namedColors = {
        'white': { r: 255, g: 255, b: 255 },
        'black': { r: 0, g: 0, b: 0 },
        'transparent': { r: 0, g: 0, b: 0 }, // 투명은 검정으로 처리
    };

    return namedColors[color.toLowerCase()] || { r: 0, g: 0, b: 0 };
}

// WCAG 준수 등급 확인
function getAccessibilityGrade(contrast, isLargeText = false) {
    const normalTextAA = 4.5;
    const normalTextAAA = 7.0;
    const largeTextAA = 3.0;
    const largeTextAAA = 4.5;

    if (isLargeText) {
        if (contrast >= largeTextAAA) return 'AAA';
        if (contrast >= largeTextAA) return 'AA';
        return 'FAIL';
    } else {
        if (contrast >= normalTextAAA) return 'AAA';
        if (contrast >= normalTextAA) return 'AA';
        return 'FAIL';
    }
}

// 디자인 시스템 색상 정의 (DSColors - ChatGPT 스타일)
const tossColors = {
    // 라이트모드 색상
    light: {
        gray900: { r: 25, g: 31, b: 40 },      // #191F28 - 주 텍스트
        gray800: { r: 51, g: 61, b: 75 },      // #333D4B
        gray700: { r: 78, g: 89, b: 104 },     // #4E5968
        gray600: { r: 107, g: 118, b: 132 },   // #6B7684
        gray500: { r: 139, g: 149, b: 161 },   // #8B95A1
        gray400: { r: 176, g: 184, b: 193 },   // #B0B8C1
        gray300: { r: 209, g: 214, b: 219 },   // #D1D6DB
        gray200: { r: 229, g: 232, b: 235 },   // #E5E8EB
        gray100: { r: 242, g: 244, b: 246 },   // #F2F4F6
        gray50: { r: 249, g: 250, b: 251 },    // #F9FAFB
        white: { r: 255, g: 255, b: 255 },     // #FFFFFF
        tossBlue: { r: 49, g: 130, b: 246 },   // #3182F6
    },

    // 다크모드 색상
    dark: {
        grayDark50: { r: 23, g: 23, b: 28 },    // #17171C - 다크모드 배경
        grayDark100: { r: 38, g: 38, b: 46 },   // #26262E - 다크모드 카드
        grayDark200: { r: 58, g: 58, b: 66 },   // #3A3A42 - 다크모드 표면
        grayDark300: { r: 64, g: 64, b: 72 },   // #404048 - 다크모드 테두리
        grayDark400: { r: 107, g: 114, b: 128 }, // #6B7280 - 다크모드 보조 텍스트
        grayDark500: { r: 156, g: 163, b: 175 }, // #9CA3AF - 다크모드 힌트
        grayDark900: { r: 255, g: 255, b: 255 }, // #FFFFFF - 다크모드 주 텍스트
        tossBlueDark: { r: 30, g: 94, b: 219 },  // #1E5EDB
    }
};

// 주요 UI 조합 검증
function analyzeColorCombinations() {
    const results = [];

    // 라이트모드 조합 검증
    const lightCombinations = [
        { name: '주 텍스트 / 배경 (라이트)', text: tossColors.light.gray900, bg: tossColors.light.white },
        { name: '보조 텍스트 / 배경 (라이트)', text: tossColors.light.gray600, bg: tossColors.light.white },
        { name: '버튼 텍스트 / 토스 블루 (라이트)', text: tossColors.light.white, bg: tossColors.light.tossBlue },
        { name: '카드 텍스트 / 카드 배경 (라이트)', text: tossColors.light.gray900, bg: tossColors.light.gray50 },
        { name: '힌트 텍스트 / 배경 (라이트)', text: tossColors.light.gray500, bg: tossColors.light.white },
    ];

    // 다크모드 조합 검증
    const darkCombinations = [
        { name: '주 텍스트 / 배경 (다크)', text: tossColors.dark.grayDark900, bg: tossColors.dark.grayDark50 },
        { name: '보조 텍스트 / 배경 (다크)', text: tossColors.dark.grayDark400, bg: tossColors.dark.grayDark50 },
        { name: '버튼 텍스트 / 토스 블루 (다크)', text: tossColors.dark.grayDark900, bg: tossColors.dark.tossBlueDark },
        { name: '카드 텍스트 / 카드 배경 (다크)', text: tossColors.dark.grayDark900, bg: tossColors.dark.grayDark100 },
        { name: '힌트 텍스트 / 배경 (다크)', text: tossColors.dark.grayDark500, bg: tossColors.dark.grayDark50 },
    ];

    [...lightCombinations, ...darkCombinations].forEach(combo => {
        const contrast = calculateContrast(combo.text, combo.bg);
        const grade = getAccessibilityGrade(contrast);
        const gradeSmall = getAccessibilityGrade(contrast, false);
        const gradeLarge = getAccessibilityGrade(contrast, true);

        results.push({
            combination: combo.name,
            contrast: contrast.toFixed(2),
            grade: grade,
            gradeSmall: gradeSmall,
            gradeLarge: gradeLarge,
            status: grade === 'FAIL' ? '❌ 실패' : grade === 'AA' ? '✅ 통과' : '🌟 우수',
            textColor: `rgb(${combo.text.r}, ${combo.text.g}, ${combo.text.b})`,
            backgroundColor: `rgb(${combo.bg.r}, ${combo.bg.g}, ${combo.bg.b})`
        });
    });

    return results;
}

// 색상 추천 도구
function recommendColors(targetContrast = 4.5) {
    const recommendations = [];

    // 다크모드 개선 추천
    const darkBg = tossColors.dark.grayDark50;

    // 권장 텍스트 색상 계산
    for (let lightness = 50; lightness <= 100; lightness += 10) {
        const grayValue = Math.round((lightness / 100) * 255);
        const testColor = { r: grayValue, g: grayValue, b: grayValue };
        const contrast = calculateContrast(testColor, darkBg);

        if (contrast >= targetContrast) {
            recommendations.push({
                description: `다크모드 텍스트 (밝기 ${lightness}%)`,
                color: `rgb(${grayValue}, ${grayValue}, ${grayValue})`,
                hex: `#${grayValue.toString(16).padStart(2, '0').repeat(3)}`,
                contrast: contrast.toFixed(2),
                grade: getAccessibilityGrade(contrast)
            });
        }
    }

    return recommendations;
}

// 리포트 생성
function generateReport() {
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
    const results = analyzeColorCombinations();
    const recommendations = recommendColors();

    let report = `# Fortune 앱 다크모드 컨트라스트 분석 리포트\n\n`;
    report += `생성일시: ${new Date().toLocaleString('ko-KR')}\n\n`;

    // 요약
    const totalTests = results.length;
    const passedTests = results.filter(r => r.grade !== 'FAIL').length;
    const failedTests = totalTests - passedTests;

    report += `## 📊 테스트 요약\n\n`;
    report += `- 총 테스트: ${totalTests}개\n`;
    report += `- ✅ 통과: ${passedTests}개 (${((passedTests/totalTests)*100).toFixed(1)}%)\n`;
    report += `- ❌ 실패: ${failedTests}개 (${((failedTests/totalTests)*100).toFixed(1)}%)\n\n`;

    // 상세 결과
    report += `## 🔍 상세 분석 결과\n\n`;
    report += `| 조합 | 컨트라스트 비율 | 일반 텍스트 | 큰 텍스트 | 상태 |\n`;
    report += `|------|----------------|------------|-----------|------|\n`;

    results.forEach(result => {
        report += `| ${result.combination} | ${result.contrast}:1 | ${result.gradeSmall} | ${result.gradeLarge} | ${result.status} |\n`;
    });

    // 실패한 테스트 상세
    const failedResults = results.filter(r => r.grade === 'FAIL');
    if (failedResults.length > 0) {
        report += `\n## ⚠️  개선 필요 항목\n\n`;
        failedResults.forEach(result => {
            report += `### ${result.combination}\n`;
            report += `- **컨트라스트 비율**: ${result.contrast}:1 (최소 4.5:1 필요)\n`;
            report += `- **텍스트 색상**: ${result.textColor}\n`;
            report += `- **배경 색상**: ${result.backgroundColor}\n`;
            report += `- **권장사항**: 텍스트를 더 밝게 하거나 배경을 더 어둡게 조정 필요\n\n`;
        });
    }

    // 색상 추천
    if (recommendations.length > 0) {
        report += `## 💡 색상 개선 추천\n\n`;
        report += `WCAG AA 기준(4.5:1)을 만족하는 다크모드 텍스트 색상:\n\n`;
        recommendations.forEach(rec => {
            report += `- **${rec.description}**: \`${rec.hex}\` (${rec.color}) - 컨트라스트 ${rec.contrast}:1 (${rec.grade})\n`;
        });
        report += `\n`;
    }

    // WCAG 기준 설명
    report += `## 📋 WCAG 접근성 기준\n\n`;
    report += `- **AA 기준**: 일반 텍스트 4.5:1, 큰 텍스트 3:1\n`;
    report += `- **AAA 기준**: 일반 텍스트 7:1, 큰 텍스트 4.5:1\n`;
    report += `- **큰 텍스트**: 18pt 이상 또는 14pt 굵은 글씨\n\n`;

    // 토스 디자인 시스템 색상표
    report += `## 🎨 토스 디자인 시스템 색상\n\n`;
    report += `### 라이트모드\n`;
    Object.entries(tossColors.light).forEach(([name, color]) => {
        const hex = `#${color.r.toString(16).padStart(2, '0')}${color.g.toString(16).padStart(2, '0')}${color.b.toString(16).padStart(2, '0')}`;
        report += `- **${name}**: ${hex} rgb(${color.r}, ${color.g}, ${color.b})\n`;
    });

    report += `\n### 다크모드\n`;
    Object.entries(tossColors.dark).forEach(([name, color]) => {
        const hex = `#${color.r.toString(16).padStart(2, '0')}${color.g.toString(16).padStart(2, '0')}${color.b.toString(16).padStart(2, '0')}`;
        report += `- **${name}**: ${hex} rgb(${color.r}, ${color.g}, ${color.b})\n`;
    });

    // 파일 저장
    const filename = `contrast_analysis_${timestamp}.md`;
    fs.writeFileSync(filename, report);

    console.log('🎨 Fortune 다크모드 컨트라스트 분석 완료!');
    console.log(`📊 분석 결과: ${passedTests}/${totalTests} 테스트 통과 (${((passedTests/totalTests)*100).toFixed(1)}%)`);
    console.log(`📄 상세 리포트: ${filename}`);

    if (failedTests > 0) {
        console.log('⚠️  개선 필요한 색상 조합이 발견되었습니다.');
        failedResults.forEach(result => {
            console.log(`   - ${result.combination}: ${result.contrast}:1 (최소 4.5:1 필요)`);
        });
    } else {
        console.log('✅ 모든 색상 조합이 WCAG 기준을 만족합니다!');
    }

    return {
        totalTests,
        passedTests,
        failedTests,
        results,
        recommendations,
        reportFile: filename
    };
}

// 실시간 컨트라스트 체커
function checkContrast(textColor, backgroundColor) {
    const contrast = calculateContrast(parseColor(textColor), parseColor(backgroundColor));
    const grade = getAccessibilityGrade(contrast);

    return {
        contrast: contrast.toFixed(2),
        grade,
        isAccessible: grade !== 'FAIL',
        recommendation: grade === 'FAIL' ?
            '컨트라스트 비율을 높이기 위해 텍스트를 더 밝게 하거나 배경을 더 어둡게 조정하세요.' :
            'WCAG 접근성 기준을 만족합니다.'
    };
}

// CLI에서 직접 실행할 때
if (require.main === module) {
    // 명령행 인자 확인
    const args = process.argv.slice(2);

    if (args.length === 2) {
        // 개별 색상 조합 검사
        const [textColor, bgColor] = args;
        console.log(`🔍 컨트라스트 검사: "${textColor}" on "${bgColor}"`);
        const result = checkContrast(textColor, bgColor);
        console.log(`📊 컨트라스트 비율: ${result.contrast}:1`);
        console.log(`🏆 WCAG 등급: ${result.grade}`);
        console.log(`${result.isAccessible ? '✅' : '❌'} ${result.recommendation}`);
    } else {
        // 전체 분석 실행
        generateReport();
    }
}

module.exports = {
    calculateContrast,
    checkContrast,
    generateReport,
    analyzeColorCombinations,
    recommendColors
};