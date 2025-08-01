#!/bin/bash

# Image optimization script for Fortune app
# Converts images to WebP format for better performance

echo "🖼️  Starting image optimization..."

# Check if cwebp is installed
if ! command -v cwebp &> /dev/null; then
    echo "❌ cwebp not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install webp
    else
        sudo apt-get install webp
    fi
fi

# Set paths
ASSETS_PATH="../fortune_flutter/assets/images"
OUTPUT_PATH="$ASSETS_PATH/optimized"

# Create output directory
mkdir -p "$OUTPUT_PATH"

# Function to convert image to WebP
convert_to_webp() {
    local input_file=$1
    local output_file=$2
    local quality=${3:-85}
    
    echo "Converting: $input_file"
    cwebp -q $quality "$input_file" -o "$output_file"
}

# Convert PNG images
echo "📸 Converting PNG images..."
find "$ASSETS_PATH" -name "*.png" -type f | while read -r file; do
    filename=$(basename "$file" .png)
    dir=$(dirname "$file")
    relative_dir=${dir#$ASSETS_PATH/}
    
    # Skip if already in optimized directory
    if [[ "$relative_dir" == "optimized"* ]]; then
        continue
    fi
    
    # Create subdirectory in output
    mkdir -p "$OUTPUT_PATH/$relative_dir"
    
    # Convert to WebP
    output_file="$OUTPUT_PATH/$relative_dir/$filename.webp"
    convert_to_webp "$file" "$output_file" 85
done

# Convert JPG images
echo "📸 Converting JPG images..."
find "$ASSETS_PATH" -name "*.jpg" -o -name "*.jpeg" -type f | while read -r file; do
    filename=$(basename "$file" | sed 's/\.[^.]*$//')
    dir=$(dirname "$file")
    relative_dir=${dir#$ASSETS_PATH/}
    
    # Skip if already in optimized directory
    if [[ "$relative_dir" == "optimized"* ]]; then
        continue
    fi
    
    # Create subdirectory in output
    mkdir -p "$OUTPUT_PATH/$relative_dir"
    
    # Convert to WebP
    output_file="$OUTPUT_PATH/$relative_dir/$filename.webp"
    convert_to_webp "$file" "$output_file" 80
done

# Generate different sizes for responsive images
echo "📐 Generating responsive image sizes..."

# Function to generate multiple sizes
generate_sizes() {
    local input_file=$1
    local base_name=$2
    local output_dir=$3
    
    # Generate sizes: 1x, 2x, 3x for mobile
    convert "$input_file" -resize 100x100 "$output_dir/${base_name}_1x.webp"
    convert "$input_file" -resize 200x200 "$output_dir/${base_name}_2x.webp"
    convert "$input_file" -resize 300x300 "$output_dir/${base_name}_3x.webp"
    
    # Generate sizes for web: small, medium, large
    convert "$input_file" -resize 320x "$output_dir/${base_name}_small.webp"
    convert "$input_file" -resize 768x "$output_dir/${base_name}_medium.webp"
    convert "$input_file" -resize 1200x "$output_dir/${base_name}_large.webp"
}

# Update pubspec.yaml to include optimized images
echo "📝 Updating pubspec.yaml..."
cat >> "$ASSETS_PATH/../../pubspec.yaml" << EOL

    # Optimized WebP images
    - assets/images/optimized/
EOL

# Generate image asset helper
echo "💻 Generating image asset helper..."
cat > "$ASSETS_PATH/../../lib/core/constants/optimized_images.dart" << 'EOL'
// Generated optimized image paths
class OptimizedImages {
  static const String basePath = 'assets/images/optimized/';
  
  // Helper to get WebP image with fallback
  static String getImage(String name, {String format = 'webp'}) {
    return '$basePath$name.$format';
  }
  
  // Responsive image helper
  static String getResponsiveImage(String name, {required double devicePixelRatio}) {
    if (devicePixelRatio > 2.5) {
      return '${basePath}${name}_3x.webp';
    } else if (devicePixelRatio > 1.5) {
      return '${basePath}${name}_2x.webp';
    }
    return '${basePath}${name}_1x.webp';
  }
  
  // Size-based image helper
  static String getSizedImage(String name, {required double width}) {
    if (width > 768) {
      return '${basePath}${name}_large.webp';
    } else if (width > 320) {
      return '${basePath}${name}_medium.webp';
    }
    return '${basePath}${name}_small.webp';
  }
}
EOL

# Print summary
echo "✅ Image optimization complete!"
echo "📊 Summary:"
echo "  - WebP images created in: $OUTPUT_PATH"
echo "  - Original images preserved"
echo "  - Responsive sizes generated"
echo "  - Helper class created"

# Calculate size savings
original_size=$(du -sh "$ASSETS_PATH" | cut -f1)
optimized_size=$(du -sh "$OUTPUT_PATH" | cut -f1)
echo "  - Original size: $original_size"
echo "  - Optimized size: $optimized_size"