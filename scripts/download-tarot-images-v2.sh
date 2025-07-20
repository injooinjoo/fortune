#!/bin/bash

# Tarot Card Image Downloader Script v2
# Downloads tarot card images from steve-p.org for 8 different decks
# Compatible with older bash versions

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base URL and directories
BASE_URL="https://steve-p.org/cards/small/"
OUTPUT_DIR="../fortune_flutter/assets/images/tarot/decks"

# Create main directory
mkdir -p "$OUTPUT_DIR"

# Progress tracking
total_cards=624  # 8 decks * 78 cards
downloaded=0
failed=0

echo -e "${BLUE}Starting download of $total_cards tarot card images...${NC}"
echo -e "${BLUE}This may take a while. Please be patient.${NC}\n"

# Create failed downloads log
> failed_downloads.txt

# Function to download and convert image
download_image() {
    local url=$1
    local output_path=$2
    local temp_path="${output_path%.jpg}.webp"
    
    # Download WebP image
    if curl -s -f -o "$temp_path" "$url"; then
        # Convert WebP to JPG using ImageMagick
        if command -v magick &> /dev/null; then
            magick "$temp_path" -quality 85 "$output_path" 2>/dev/null && rm -f "$temp_path"
        elif command -v convert &> /dev/null; then
            convert "$temp_path" -quality 85 "$output_path" 2>/dev/null && rm -f "$temp_path"
        else
            # If no ImageMagick, keep as WebP
            mv "$temp_path" "${output_path%.jpg}.webp"
        fi
        return 0
    else
        return 1
    fi
}

# Function to download a deck
download_deck() {
    local deck_name=$1
    local deck_code=$2
    
    echo -e "${GREEN}Downloading deck: $deck_name (Code: $deck_code)${NC}"
    
    # Create deck directory
    deck_dir="$OUTPUT_DIR/$deck_name"
    mkdir -p "$deck_dir/major"
    mkdir -p "$deck_dir/wands"
    mkdir -p "$deck_dir/cups"
    mkdir -p "$deck_dir/swords"
    mkdir -p "$deck_dir/pentacles"
    
    # Download Major Arcana (00-21)
    echo "  Downloading Major Arcana..."
    for i in $(seq -f "%02g" 0 21); do
        url="${BASE_URL}sm_${deck_code}-T-${i}.webp"
        
        # Card names
        case $i in
            00) card_name="00_fool" ;;
            01) card_name="01_magician" ;;
            02) card_name="02_high_priestess" ;;
            03) card_name="03_empress" ;;
            04) card_name="04_emperor" ;;
            05) card_name="05_hierophant" ;;
            06) card_name="06_lovers" ;;
            07) card_name="07_chariot" ;;
            08) card_name="08_strength" ;;
            09) card_name="09_hermit" ;;
            10) card_name="10_wheel_of_fortune" ;;
            11) card_name="11_justice" ;;
            12) card_name="12_hanged_man" ;;
            13) card_name="13_death" ;;
            14) card_name="14_temperance" ;;
            15) card_name="15_devil" ;;
            16) card_name="16_tower" ;;
            17) card_name="17_star" ;;
            18) card_name="18_moon" ;;
            19) card_name="19_sun" ;;
            20) card_name="20_judgement" ;;
            21) card_name="21_world" ;;
        esac
        
        output_file="$deck_dir/major/${card_name}.jpg"
        
        echo -n "    ${card_name}... "
        if download_image "$url" "$output_file"; then
            echo -e "${GREEN}✓${NC}"
            ((downloaded++))
        else
            echo -e "${RED}✗${NC}"
            ((failed++))
            echo "$url -> $output_file" >> failed_downloads.txt
        fi
    done
    
    # Download Minor Arcana
    for suit in "W:wands" "C:cups" "S:swords" "P:pentacles"; do
        suit_code="${suit%%:*}"
        suit_name="${suit##*:}"
        
        echo "  Downloading ${suit_name}..."
        for i in $(seq -f "%02g" 1 14); do
            url="${BASE_URL}sm_${deck_code}-${suit_code}-${i}.webp"
            
            # Card names
            if [ "$i" -le "10" ]; then
                card_name="${i}_of_${suit_name}"
            else
                case $i in
                    11) card_name="page_of_${suit_name}" ;;
                    12) card_name="knight_of_${suit_name}" ;;
                    13) card_name="queen_of_${suit_name}" ;;
                    14) card_name="king_of_${suit_name}" ;;
                esac
            fi
            
            output_file="$deck_dir/${suit_name}/${card_name}.jpg"
            
            echo -n "    ${card_name}... "
            if download_image "$url" "$output_file"; then
                echo -e "${GREEN}✓${NC}"
                ((downloaded++))
            else
                echo -e "${RED}✗${NC}"
                ((failed++))
                echo "$url -> $output_file" >> failed_downloads.txt
            fi
        done
    done
    
    echo -e "${GREEN}Completed deck: $deck_name${NC}\n"
}

# Download all 8 decks
download_deck "rider_waite" "RWSa"
download_deck "thoth" "Thot"
download_deck "ancient_italian" "AncI"
download_deck "before_tarot" "BefT"
download_deck "after_tarot" "AftT"
download_deck "golden_dawn_cicero" "Cice"
download_deck "golden_dawn_wang" "GDaw"
download_deck "grand_etteilla" "GrEt"

# Summary
echo -e "\n${BLUE}=== Download Summary ===${NC}"
echo -e "${GREEN}Successfully downloaded: $downloaded images${NC}"
echo -e "${RED}Failed: $failed images${NC}"

if [ $failed -gt 0 ]; then
    echo -e "${YELLOW}Failed URLs saved to: failed_downloads.txt${NC}"
fi

echo -e "\n${GREEN}Download complete!${NC}"