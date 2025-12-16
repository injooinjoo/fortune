#!/usr/bin/env python3
"""
Fortune Icon Processor
- Trim transparent background
- Resize to 44x44
- Save to assets/icons/fortune/
"""

from PIL import Image
import os

# 경로 설정
RAW_DIR = "/Users/jacobmac/Desktop/Dev/fortune/assets/icons/raw"
OUTPUT_DIR = "/Users/jacobmac/Desktop/Dev/fortune/assets/icons/fortune"

# 이미지 매핑 (한글 파일명 → 영문 대상 파일명)
MAPPING = {
    "MBTI.png": "mbti.png",
    "가족.png": "family.png",
    "건강.png": "health.png",
    "관상.png": "face_reading.png",
    "궁합.png": "compatibility.png",
    "바이오리듬.png": "biorhythm.png",
    "반려동물.png": "pet.png",
    "부적.png": "talisman.png",
    "성격.png": "personality_dna.png",
    "소개팅.png": "blind_date.png",
    "소원.png": "wish.png",
    "스포츠.png": "sports_game.png",
    "시간별운세.png": "daily.png",
    "시험.png": "study.png",
    "연애운.png": "love.png",
    "운동.png": "exercise.png",
    "유명인운세.png": "celebrity.png",
    "이사운.png": "moving.png",
    "재능발견.png": "talent.png",
    "재물운.png": "investment.png",
    "재회운.png": "ex_lover.png",
    "전통운세.png": "traditional.png",
    "직업.png": "career.png",
    "타로.png": "tarot.png",
    "포춘쿠키.png": "fortune_cookie.png",
    "피해야하는사람.png": "avoid_people.png",
    "해몽.png": "dream.png",
    "행운아이템.png": "lucky_items.png",
}

def trim_transparent(img):
    """투명 배경 제거하고 콘텐츠에 맞게 crop"""
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    # 알파 채널 기준으로 bounding box 찾기
    bbox = img.getbbox()
    if bbox:
        img = img.crop(bbox)
    return img

def make_square(img):
    """이미지를 정사각형으로 만들기 (가운데 정렬, 투명 패딩)"""
    width, height = img.size
    max_dim = max(width, height)

    # 새 정사각형 캔버스 생성 (투명 배경)
    new_img = Image.new('RGBA', (max_dim, max_dim), (0, 0, 0, 0))

    # 가운데 정렬
    x = (max_dim - width) // 2
    y = (max_dim - height) // 2
    new_img.paste(img, (x, y), img if img.mode == 'RGBA' else None)

    return new_img

def process_image(input_path, output_path, size=44):
    """이미지 처리: trim → square → resize"""
    print(f"Processing: {os.path.basename(input_path)} → {os.path.basename(output_path)}")

    # 이미지 열기
    img = Image.open(input_path)

    # RGBA로 변환
    if img.mode != 'RGBA':
        img = img.convert('RGBA')

    # 1. 투명 배경 trim
    img = trim_transparent(img)

    # 2. 정사각형으로 만들기
    img = make_square(img)

    # 3. 44x44로 리사이징 (고품질)
    img = img.resize((size, size), Image.Resampling.LANCZOS)

    # 4. 저장
    img.save(output_path, 'PNG', optimize=True)
    print(f"  ✓ Saved: {output_path}")

def main():
    print("=" * 50)
    print("Fortune Icon Processor")
    print("=" * 50)

    # 출력 디렉토리 확인
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    processed = 0
    errors = []

    for src_name, dst_name in MAPPING.items():
        src_path = os.path.join(RAW_DIR, src_name)
        dst_path = os.path.join(OUTPUT_DIR, dst_name)

        if not os.path.exists(src_path):
            errors.append(f"Not found: {src_name}")
            continue

        try:
            process_image(src_path, dst_path)
            processed += 1
        except Exception as e:
            errors.append(f"Error processing {src_name}: {e}")

    print("\n" + "=" * 50)
    print(f"Processed: {processed}/{len(MAPPING)} images")

    if errors:
        print("\nErrors:")
        for err in errors:
            print(f"  ✗ {err}")

    print("=" * 50)

if __name__ == "__main__":
    main()
