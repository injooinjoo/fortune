-- 유명인 사주 데이터 확인 쿼리

-- 1. 전체 유명인 수 확인
SELECT COUNT(*) as total_celebrities 
FROM public.celebrities;

-- 2. 사주 데이터가 있는 유명인 목록
SELECT 
    name,
    real_name,
    birth_date,
    birth_place,
    saju_string,
    dominant_element,
    CASE 
        WHEN hour_pillar IS NOT NULL AND hour_pillar != '' THEN '시주 있음'
        ELSE '시주 없음'
    END as hour_info
FROM public.celebrities
WHERE saju_string IS NOT NULL
ORDER BY name;

-- 3. 오행별 통계
SELECT 
    dominant_element as "지배 오행",
    COUNT(*) as "인원수"
FROM public.celebrities
WHERE dominant_element IS NOT NULL
GROUP BY dominant_element
ORDER BY COUNT(*) DESC;

-- 4. 카테고리별 유명인 수
SELECT 
    category as "카테고리",
    COUNT(*) as "인원수"
FROM public.celebrities
WHERE saju_string IS NOT NULL
GROUP BY category
ORDER BY COUNT(*) DESC;

-- 5. 상세 사주 정보 샘플 (IU)
SELECT 
    name,
    real_name,
    birth_date,
    birth_place,
    year_pillar || ' ' || month_pillar || ' ' || day_pillar || ' ' || COALESCE(hour_pillar, '') as "사주팔자",
    '목:' || wood_count || ' 화:' || fire_count || ' 토:' || earth_count || ' 금:' || metal_count || ' 수:' || water_count as "오행 분포",
    dominant_element as "지배 오행"
FROM public.celebrities
WHERE name = 'IU';

-- 6. 오행 균형이 좋은 유명인 (각 오행이 1개 이상)
SELECT 
    name,
    saju_string,
    '목:' || wood_count || ' 화:' || fire_count || ' 토:' || earth_count || ' 금:' || metal_count || ' 수:' || water_count as "오행 분포"
FROM public.celebrities
WHERE wood_count > 0 
  AND fire_count > 0 
  AND earth_count > 0 
  AND metal_count > 0 
  AND water_count > 0;

-- 7. 특정 오행이 강한 유명인 (수가 3개 이상)
SELECT 
    name,
    saju_string,
    water_count as "수 개수"
FROM public.celebrities
WHERE water_count >= 3
ORDER BY water_count DESC;