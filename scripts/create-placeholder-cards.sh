#!/bin/bash

# Script to create placeholder images for missing tarot cards
# Uses ImageMagick to generate placeholder cards with text

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

OUTPUT_DIR="fortune_flutter/assets/images/tarot/decks"

echo -e "${BLUE}Creating placeholder images for missing tarot cards...${NC}\n"

# Function to create a placeholder card
create_placeholder() {
    local deck_name=$1
    local deck_display=$2
    local suit_name=$3
    local card_name=$4
    local output_file=$5
    local color=$6
    
    # Skip if file already exists
    if [ -f "$output_file" ]; then
        return 0
    fi
    
    echo -n "  Creating placeholder for $card_name... "
    
    # Create card with ImageMagick
    if command -v magick &> /dev/null; then
        magick -size 300x450 xc:"$color" \
            -font Arial -pointsize 24 -fill white \
            -gravity North -annotate +0+30 "$deck_display" \
            -font Arial -pointsize 36 -fill white \
            -gravity Center -annotate +0+0 "$card_name" \
            -font Arial -pointsize 20 -fill white \
            -gravity South -annotate +0+30 "Placeholder" \
            -quality 85 "$output_file"
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ ImageMagick not found${NC}"
        return 1
    fi
}

# Create placeholders for each deck
create_deck_placeholders() {
    local deck_name=$1
    local deck_display=$2
    local deck_color=$3
    
    echo -e "${GREEN}Creating placeholders for $deck_display${NC}"
    
    # Ace cards
    for suit in "wands:#8B4513" "cups:#1E90FF" "swords:#C0C0C0" "pentacles:#FFD700"; do
        suit_name="${suit%%:*}"
        suit_color="${suit##*:}"
        
        output_file="$OUTPUT_DIR/$deck_name/$suit_name/01_of_${suit_name}.jpg"
        # Capitalize first letter manually for compatibility
        case $suit_name in
            wands) card_title="Ace of Wands" ;;
            cups) card_title="Ace of Cups" ;;
            swords) card_title="Ace of Swords" ;;
            pentacles) card_title="Ace of Pentacles" ;;
        esac
        create_placeholder "$deck_name" "$deck_display" "$suit_name" "$card_title" "$output_file" "$deck_color"
    done
    
    # Court cards
    for suit in "wands" "cups" "swords" "pentacles"; do
        # Capitalize suit name manually
        case $suit in
            wands) suit_title="Wands" ;;
            cups) suit_title="Cups" ;;
            swords) suit_title="Swords" ;;
            pentacles) suit_title="Pentacles" ;;
        esac
        
        # Page
        output_file="$OUTPUT_DIR/$deck_name/$suit/page_of_${suit}.jpg"
        create_placeholder "$deck_name" "$deck_display" "$suit" "Page of $suit_title" "$output_file" "$deck_color"
        
        # Knight
        output_file="$OUTPUT_DIR/$deck_name/$suit/knight_of_${suit}.jpg"
        create_placeholder "$deck_name" "$deck_display" "$suit" "Knight of $suit_title" "$output_file" "$deck_color"
        
        # Queen
        output_file="$OUTPUT_DIR/$deck_name/$suit/queen_of_${suit}.jpg"
        create_placeholder "$deck_name" "$deck_display" "$suit" "Queen of $suit_title" "$output_file" "$deck_color"
        
        # King
        output_file="$OUTPUT_DIR/$deck_name/$suit/king_of_${suit}.jpg"
        create_placeholder "$deck_name" "$deck_display" "$suit" "King of $suit_title" "$output_file" "$deck_color"
    done
    
    echo ""
}

# Create placeholders for all decks
create_deck_placeholders "rider_waite" "Rider-Waite" "#4A5568"
create_deck_placeholders "thoth" "Thoth" "#553C9A"
create_deck_placeholders "ancient_italian" "Ancient Italian" "#975A16"
create_deck_placeholders "before_tarot" "Before Tarot" "#065F46"
create_deck_placeholders "after_tarot" "After Tarot" "#1E3A8A"
create_deck_placeholders "golden_dawn_cicero" "Golden Dawn (Cicero)" "#7C3AED"
create_deck_placeholders "golden_dawn_wang" "Golden Dawn (Wang)" "#B91C1C"
create_deck_placeholders "grand_etteilla" "Grand Etteilla" "#92400E"

echo -e "${GREEN}Placeholder creation complete!${NC}"

# Count total images now
total_images=$(find "$OUTPUT_DIR" -name "*.jpg" | wc -l)
echo -e "\n${BLUE}Total card images (including placeholders): $total_images${NC}"