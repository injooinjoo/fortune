#!/bin/bash

# Script to find and download missing tarot cards with alternative URL patterns
# This script tries different naming conventions for Ace and Court cards

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BASE_URL="https://steve-p.org/cards/small/"
OUTPUT_DIR="../fortune_flutter/assets/images/tarot/decks"

echo -e "${BLUE}Attempting to download missing tarot cards with alternative patterns...${NC}\n"

# Track results
found=0
not_found=0

# Create a log for alternative URLs that work
> working_alternative_urls.txt

# Function to try multiple URL patterns
try_download() {
    local deck_name=$1
    local deck_code=$2
    local suit_code=$3
    local suit_name=$4
    local card_num=$5
    local card_name=$6
    local output_file=$7
    
    # Skip if file already exists
    if [ -f "$output_file" ]; then
        return 0
    fi
    
    echo -n "  Trying $card_name... "
    
    # Try different URL patterns
    patterns=(
        "${deck_code}-${suit_code}-${card_num}"      # Original pattern
        "${deck_code}${suit_code}${card_num}"         # No hyphens
        "${deck_code}_${suit_code}_${card_num}"       # Underscores
        "${deck_code}-${suit_code}${card_num}"        # Mixed
    )
    
    for pattern in "${patterns[@]}"; do
        url="${BASE_URL}sm_${pattern}.webp"
        temp_file="/tmp/test_card.webp"
        
        if curl -s -f -o "$temp_file" "$url"; then
            echo -e "${GREEN}✓ Found with pattern: $pattern${NC}"
            echo "$url -> $output_file" >> working_alternative_urls.txt
            
            # Convert and save
            if command -v magick &> /dev/null; then
                magick "$temp_file" -quality 85 "$output_file" 2>/dev/null
            elif command -v convert &> /dev/null; then
                convert "$temp_file" -quality 85 "$output_file" 2>/dev/null
            else
                cp "$temp_file" "${output_file%.jpg}.webp"
            fi
            
            rm -f "$temp_file"
            ((found++))
            return 0
        fi
    done
    
    echo -e "${RED}✗ Not found with any pattern${NC}"
    ((not_found++))
    return 1
}

# Test patterns for a specific deck
test_deck_patterns() {
    local deck_name=$1
    local deck_code=$2
    
    echo -e "${GREEN}Testing patterns for $deck_name ($deck_code)${NC}"
    
    # Test Ace cards
    for suit in "W:wands" "C:cups" "S:swords" "P:pentacles"; do
        suit_code="${suit%%:*}"
        suit_name="${suit##*:}"
        
        # Try Ace (01)
        output_file="$OUTPUT_DIR/$deck_name/${suit_name}/01_of_${suit_name}.jpg"
        try_download "$deck_name" "$deck_code" "$suit_code" "$suit_name" "01" "Ace of $suit_name" "$output_file"
    done
    
    # Test Court cards
    for suit in "W:wands" "C:cups" "S:swords" "P:pentacles"; do
        suit_code="${suit%%:*}"
        suit_name="${suit##*:}"
        
        # Page (11)
        output_file="$OUTPUT_DIR/$deck_name/${suit_name}/page_of_${suit_name}.jpg"
        try_download "$deck_name" "$deck_code" "$suit_code" "$suit_name" "11" "Page of $suit_name" "$output_file"
        
        # Knight (12)
        output_file="$OUTPUT_DIR/$deck_name/${suit_name}/knight_of_${suit_name}.jpg"
        try_download "$deck_name" "$deck_code" "$suit_code" "$suit_name" "12" "Knight of $suit_name" "$output_file"
        
        # Queen (13)
        output_file="$OUTPUT_DIR/$deck_name/${suit_name}/queen_of_${suit_name}.jpg"
        try_download "$deck_name" "$deck_code" "$suit_code" "$suit_name" "13" "Queen of $suit_name" "$output_file"
        
        # King (14)
        output_file="$OUTPUT_DIR/$deck_name/${suit_name}/king_of_${suit_name}.jpg"
        try_download "$deck_name" "$deck_code" "$suit_code" "$suit_name" "14" "King of $suit_name" "$output_file"
    done
    
    echo ""
}

# Test all decks
test_deck_patterns "rider_waite" "RWSa"
test_deck_patterns "thoth" "Thot"
test_deck_patterns "ancient_italian" "AncI"
test_deck_patterns "before_tarot" "BefT"
test_deck_patterns "after_tarot" "AftT"
test_deck_patterns "golden_dawn_cicero" "Cice"
test_deck_patterns "golden_dawn_wang" "GDaw"
test_deck_patterns "grand_etteilla" "GrEt"

# Summary
echo -e "\n${BLUE}=== Alternative Pattern Test Summary ===${NC}"
echo -e "${GREEN}Found with alternative patterns: $found${NC}"
echo -e "${RED}Still missing: $not_found${NC}"

if [ $found -gt 0 ]; then
    echo -e "${YELLOW}Working URLs saved to: working_alternative_urls.txt${NC}"
fi

# Check if cards might be in medium or large folders instead
echo -e "\n${BLUE}Checking if missing cards exist in other sizes...${NC}"

# Try medium size
test_url="${BASE_URL/small/medium}sm_RWSa-W-01.webp"
if curl -s -f -I "$test_url" > /dev/null 2>&1; then
    echo -e "${YELLOW}Note: Some cards might be available in medium size instead of small${NC}"
fi

# Try without 'sm_' prefix
test_url="${BASE_URL}RWSa-W-01.webp"
if curl -s -f -I "$test_url" > /dev/null 2>&1; then
    echo -e "${YELLOW}Note: Some cards might be available without 'sm_' prefix${NC}"
fi

echo -e "\n${GREEN}Alternative pattern test complete!${NC}"