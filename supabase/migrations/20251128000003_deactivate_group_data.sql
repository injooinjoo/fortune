-- 잘못된 그룹 데이터 비활성화
-- 그룹명으로 저장되어 birth_date가 데뷔일인 데이터들

-- 그룹 가수 데이터 비활성화 (멤버별 데이터로 대체 예정)
UPDATE public.celebrities
SET
    is_active = false,
    additional_info = additional_info || '{"deprecated_reason": "group_data_replaced_by_members", "deprecated_date": "2025-11-28"}'::jsonb
WHERE name IN (
    -- 보이그룹
    'BTS', '방탄소년단',
    'EXO', '엑소',
    'SEVENTEEN', '세븐틴',
    'NCT', '엔시티', 'NCT 127', 'NCT DREAM', 'WayV',
    'Stray Kids', '스트레이키즈', '스트레이 키즈',
    'ENHYPEN', '엔하이픈',
    'TXT', '투모로우바이투게더', 'TOMORROW X TOGETHER',
    'BIGBANG', '빅뱅',
    'SHINee', '샤이니',
    'Super Junior', '슈퍼주니어',
    'TVXQ', '동방신기',
    'GOT7', '갓세븐',
    'MONSTA X', '몬스타엑스',
    'iKON', '아이콘',
    'WINNER', '위너',
    'ATEEZ', '에이티즈',
    'THE BOYZ', '더보이즈',
    'TREASURE', '트레저',
    'RIIZE', '라이즈',
    'BOYNEXTDOOR', '보이넥스트도어',
    'ZB1', 'ZEROBASEONE', '제로베이스원',

    -- 걸그룹
    'BLACKPINK', '블랙핑크',
    'NewJeans', '뉴진스',
    'aespa', '에스파',
    'IVE', '아이브',
    'LE SSERAFIM', '르세라핌',
    'TWICE', '트와이스',
    'Red Velvet', '레드벨벳',
    'Girls'' Generation', '소녀시대', 'SNSD',
    'ITZY', '있지',
    'NMIXX', '엔믹스',
    '(G)I-DLE', '여자아이들', '아이들',
    'STAYC', '스테이씨',
    'IZ*ONE', '아이즈원',
    'fromis_9', '프로미스나인',
    'Kep1er', '케플러',
    'MAMAMOO', '마마무',
    'GFRIEND', '여자친구',
    'OH MY GIRL', '오마이걸',
    'LOONA', '이달의 소녀',
    'SISTAR', '씨스타',
    '2NE1', '투애니원',
    'EVERGLOW', '에버글로우',
    'Weeekly', '위클리',
    'Billlie', '빌리',
    'tripleS', '트리플에스',
    'BABYMONSTER', '베이비몬스터',
    'ILLIT', '아일릿',
    'KISS OF LIFE', '키스오브라이프'
)
AND is_active = true
AND category IN ('singer', 'idol_member');

-- 비활성화 결과 확인용 쿼리 (실행 로그)
DO $$
DECLARE
    deactivated_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO deactivated_count
    FROM celebrities
    WHERE additional_info->>'deprecated_reason' = 'group_data_replaced_by_members';

    RAISE NOTICE 'Deactivated % group records', deactivated_count;
END $$;
