#!/bin/bash

# Tarot Card Image Downloader Script
# Downloads tarot card images from steve-p.org for 8 different decks
# Updated to use correct URL pattern: /cards/small/sm_[deck]-[type]-[num].webp

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

# Deck configurations
declare -A DECKS=(
    ["rider_waite"]="RWSa"
    ["thoth"]="Thot"
    ["ancient_italian"]="AncI"
    ["before_tarot"]="BefT"
    ["after_tarot"]="AftT"
    ["golden_dawn_cicero"]="Cice"
    ["golden_dawn_wang"]="GDaw"
    ["grand_etteilla"]="GrEt"
)

# Card types and their counts
declare -A CARD_TYPES=(
    ["T"]="22"  # Trumps/Major Arcana (00-21)
    ["W"]="14"  # Wands (01-14)
    ["C"]="14"  # Cups (01-14)
    ["S"]="14"  # Swords (01-14)
    ["P"]="14"  # Pentacles/Coins (01-14)
)

# Card names for Major Arcana
MAJOR_ARCANA_NAMES=(
    "00_fool"
    "01_magician"
    "02_high_priestess"
    "03_empress"
    "04_emperor"
    "05_hierophant"
    "06_lovers"
    "07_chariot"
    "08_strength"
    "09_hermit"
    "10_wheel_of_fortune"
    "11_justice"
    "12_hanged_man"
    "13_death"
    "14_temperance"
    "15_devil"
    "16_tower"
    "17_star"
    "18_moon"
    "19_sun"
    "20_judgement"
    "21_world"
)

# Minor Arcana suits
declare -A SUIT_NAMES=(
    ["W"]="wands"
    ["C"]="cups"
    ["S"]="swords"
    ["P"]="pentacles"
)

# Function to download and convert image
download_image() {
    local url=$1
    local output_path=$2
    local temp_path="${output_path%.jpg}.webp"
    
    # Download WebP image
    if curl -s -f -o "$temp_path" "$url"; then
        # Convert WebP to JPG using ImageMagick or keep as WebP
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

# Function to get card name
get_card_name() {
    local type=$1
    local number=$2
    
    if [ "$type" == "T" ]; then
        echo "${MAJOR_ARCANA_NAMES[$number]}"
    else
        local suit_name="${SUIT_NAMES[$type]}"
        if [ "$number" -le 10 ]; then
            printf "%02d_of_%s" "$number" "$suit_name"
        else
            case $number in
                11) echo "page_of_$suit_name" ;;
                12) echo "knight_of_$suit_name" ;;
                13) echo "queen_of_$suit_name" ;;
                14) echo "king_of_$suit_name" ;;
            esac
        fi
    fi
}

# Progress tracking
total_cards=$((8 * 78))
downloaded=0
failed=0

echo -e "${BLUE}Starting download of $total_cards tarot card images...${NC}"
echo -e "${BLUE}This may take a while. Please be patient.${NC}\n"

# Create failed downloads log
> failed_downloads.txt

# Download images for each deck
for deck_name in "${!DECKS[@]}"; do
    deck_code="${DECKS[$deck_name]}"
    echo -e "${GREEN}Downloading deck: $deck_name (Code: $deck_code)${NC}"
    
    # Create deck directory
    deck_dir="$OUTPUT_DIR/$deck_name"
    mkdir -p "$deck_dir"
    
    # Download each card type
    for card_type in "${!CARD_TYPES[@]}"; do
        card_count="${CARD_TYPES[$card_type]}"
        
        # Create subdirectory for card type
        if [ "$card_type" == "T" ]; then
            type_dir="$deck_dir/major"
        else
            type_dir="$deck_dir/${SUIT_NAMES[$card_type]}"
        fi
        mkdir -p "$type_dir"
        
        # Determine starting number (00 for Major Arcana, 01 for others)
        if [ "$card_type" == "T" ]; then
            start=0
            end=21
        else
            start=1
            end=14
        fi
        
        # Download each card
        for ((i=start; i<=end; i++)); do
            # Format card number with leading zero
            card_num=$(printf "%02d" $i)
            
            # Construct URL
            url="${BASE_URL}sm_${deck_code}-${card_type}-${card_num}.webp"
            
            # Get card name
            card_name=$(get_card_name "$card_type" "$i")
            
            # Output file path
            output_file="$type_dir/${card_name}.jpg"
            
            # Download and convert
            echo -n "  Downloading ${card_name}... "
            if download_image "$url" "$output_file"; then
                echo -e "${GREEN}✓${NC}"
                ((downloaded++))
            else
                echo -e "${RED}✗${NC}"
                ((failed++))
                echo "$url -> $output_file" >> failed_downloads.txt
            fi
            
            # Progress indicator
            progress=$((downloaded + failed))
            percentage=$((progress * 100 / total_cards))
            printf "\r${BLUE}Progress: $progress/$total_cards ($percentage%%)${NC}"
        done
    done
    
    echo -e "\n${GREEN}Completed deck: $deck_name${NC}\n"
done

# Summary
echo -e "\n${BLUE}=== Download Summary ===${NC}"
echo -e "${GREEN}Successfully downloaded: $downloaded images${NC}"
echo -e "${RED}Failed: $failed images${NC}"

if [ $failed -gt 0 ]; then
    echo -e "${YELLOW}Failed URLs saved to: failed_downloads.txt${NC}"
fi

# Check if ImageMagick is installed
if ! command -v magick &> /dev/null && ! command -v convert &> /dev/null; then
    echo -e "\n${YELLOW}Warning: ImageMagick not installed!${NC}"
    echo -e "${YELLOW}Install ImageMagick to convert WebP images to JPG:${NC}"
    echo -e "${YELLOW}  macOS: brew install imagemagick${NC}"
    echo -e "${YELLOW}  Ubuntu: sudo apt-get install imagemagick${NC}"
fi

echo -e "\n${GREEN}Download complete!${NC}"