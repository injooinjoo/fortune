#!/usr/bin/env python3
"""
한국 전통 수묵화 스타일 운세 아이콘 분할 스크립트
5x5 그리드 이미지를 25개의 개별 PNG 파일로 분할

Usage:
    python3 scripts/split_fortune_icons.py <input_image_path>

Example:
    python3 scripts/split_fortune_icons.py ~/Downloads/fortune_icons.png
"""

import sys
import os
from PIL import Image

# 아이콘 이름 매핑 (5x5 그리드 순서)
# Row 1 (1-5): 시간별, 전통사주, 토정비결, 살풀이, 오복
# Row 2 (6-10): 관상, 손금, 궁합, 연애, 결혼
# Row 3 (11-15): 직업, 재물, 건강, 이사, MBTI
# Row 4 (16-20): 성격DNA, 꿈해몽, 타로, 소원, 행운아이템
# Row 5 (21-25): 바이오리듬, 운동, 스포츠, 반려동물, 가족
ICON_NAMES = [
    # Row 1
    "daily",           # 시간별 운세
    "traditional",     # 전통 사주
    "tojeong",         # 토정비결
    "salpuli",         # 살풀이
    "obok",            # 오복
    # Row 2
    "face_reading",    # 관상
    "palmistry",       # 손금
    "compatibility",   # 궁합
    "love",            # 연애운
    "marriage",        # 결혼운
    # Row 3
    "career",          # 직업운
    "investment",      # 재물운/투자
    "health",          # 건강운
    "moving",          # 이사 운세
    "mbti",            # MBTI 운세
    # Row 4
    "personality_dna", # 성격 DNA
    "dream",           # 꿈해몽
    "tarot",           # 타로
    "wish",            # 소원성취
    "lucky_items",     # 행운 아이템
    # Row 5
    "biorhythm",       # 바이오리듬
    "exercise",        # 운동운세
    "sports_game",     # 스포츠경기
    "pet",             # 반려동물
    "family",          # 가족 운세
]

def split_icons(input_path: str, output_dir: str, grid_size: int = 5):
    """
    그리드 이미지를 개별 아이콘으로 분할

    Args:
        input_path: 입력 이미지 경로
        output_dir: 출력 디렉토리 경로
        grid_size: 그리드 크기 (기본값 5x5)
    """
    # 이미지 로드
    img = Image.open(input_path)
    width, height = img.size

    # 각 아이콘 크기 계산
    icon_width = width // grid_size
    icon_height = height // grid_size

    print(f"입력 이미지: {width}x{height}")
    print(f"아이콘 크기: {icon_width}x{icon_height}")
    print(f"그리드: {grid_size}x{grid_size} = {grid_size * grid_size}개")
    print()

    # 출력 디렉토리 생성
    os.makedirs(output_dir, exist_ok=True)

    # 각 아이콘 추출 및 저장
    for idx in range(grid_size * grid_size):
        row = idx // grid_size
        col = idx % grid_size

        # 크롭 영역 계산
        left = col * icon_width
        top = row * icon_height
        right = left + icon_width
        bottom = top + icon_height

        # 아이콘 추출
        icon = img.crop((left, top, right, bottom))

        # 파일명 결정
        if idx < len(ICON_NAMES):
            filename = f"{ICON_NAMES[idx]}.png"
        else:
            filename = f"icon_{idx + 1:02d}.png"

        # 저장
        output_path = os.path.join(output_dir, filename)
        icon.save(output_path, "PNG")
        print(f"  [{idx + 1:2d}] {filename} - ({left}, {top}) -> ({right}, {bottom})")

    print()
    print(f"완료! {grid_size * grid_size}개 아이콘이 {output_dir}에 저장되었습니다.")

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        print("Error: 입력 이미지 경로를 지정해주세요.")
        sys.exit(1)

    input_path = sys.argv[1]

    if not os.path.exists(input_path):
        print(f"Error: 파일을 찾을 수 없습니다: {input_path}")
        sys.exit(1)

    # 프로젝트 루트 기준 출력 디렉토리
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    output_dir = os.path.join(project_root, "assets", "icons", "fortune")

    print("=" * 60)
    print("한국 전통 수묵화 운세 아이콘 분할")
    print("=" * 60)
    print()

    split_icons(input_path, output_dir)

if __name__ == "__main__":
    main()
