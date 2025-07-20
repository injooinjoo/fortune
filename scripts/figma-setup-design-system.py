#!/usr/bin/env python3
import requests
import json
import time

# Figma API configuration
FIGMA_TOKEN = "figd_bR2cafXDSpDf6bhXpQJ0eoRZGrCkRM0W60YOpbdF"
FILE_KEY = "yt2n13qKKng8fK9NTo7BfZ"
HEADERS = {
    "X-Figma-Token": FIGMA_TOKEN,
    "Content-Type": "application/json"
}

# Load design tokens
with open('docs/figma-design-tokens.json', 'r') as f:
    design_tokens = json.load(f)

def get_file_info():
    """Get file information"""
    response = requests.get(
        f"https://api.figma.com/v1/files/{FILE_KEY}",
        headers=HEADERS
    )
    return response.json()

def create_page(name):
    """Create a new page in the Figma file"""
    # Note: Figma API doesn't support creating pages directly
    # We'll need to use the existing page or rename it
    print(f"Note: Please create a page named '{name}' in Figma manually")
    return None

def create_color_frame():
    """Create frames for organizing colors"""
    # Get current file structure
    file_data = get_file_info()
    canvas_id = file_data['document']['children'][0]['id']
    
    # Create color organization frames
    frames_data = {
        "Core Colors": {"x": 0, "y": 0},
        "Category Gradients": {"x": 600, "y": 0},
        "Social Brand Colors": {"x": 1200, "y": 0}
    }
    
    frames = {}
    for frame_name, position in frames_data.items():
        frame_data = {
            "type": "FRAME",
            "name": frame_name,
            "x": position["x"],
            "y": position["y"],
            "width": 500,
            "height": 800,
            "fills": [{
                "type": "SOLID",
                "color": {"r": 0.98, "g": 0.98, "b": 0.98, "a": 1}
            }]
        }
        frames[frame_name] = frame_data
    
    return frames

def create_color_rectangles():
    """Create color swatches with proper organization"""
    colors_data = []
    
    # Core Colors
    y_offset = 50
    x_offset = 50
    
    # Primary Colors
    for i, (name, color) in enumerate([
        ("Primary/Default", "#000000"),
        ("Primary/Light", "#333333"),
        ("Primary/Dark", "#1A1A1A")
    ]):
        colors_data.append({
            "name": name,
            "color": color,
            "x": x_offset,
            "y": y_offset + (i * 120),
            "type": "solid"
        })
    
    # Secondary Colors
    x_offset = 200
    for i, (name, color) in enumerate([
        ("Secondary/Default", "#F56040"),
        ("Secondary/Light", "#FD1D1D"),
        ("Secondary/Dark", "#E1306C")
    ]):
        colors_data.append({
            "name": name,
            "color": color,
            "x": x_offset,
            "y": y_offset + (i * 120),
            "type": "solid"
        })
    
    # Neutral Colors
    x_offset = 350
    for i, (name, color) in enumerate([
        ("Neutral/Background", "#FAFAFA"),
        ("Neutral/Surface", "#FFFFFF"),
        ("Neutral/Text Primary", "#262626"),
        ("Neutral/Text Secondary", "#8E8E8E"),
        ("Neutral/Divider", "#E9ECEF")
    ]):
        colors_data.append({
            "name": name,
            "color": color,
            "x": x_offset,
            "y": y_offset + (i * 120),
            "type": "solid"
        })
    
    # Category Gradients
    gradient_x = 650
    gradient_y = 50
    gradient_count = 0
    
    for category, items in design_tokens['colors']['categories'].items():
        for item_name, item_data in items.items():
            if 'gradient' in item_data:
                gradient = item_data['gradient']
                colors_data.append({
                    "name": f"Category/{category.title()}/{item_name.title()}",
                    "gradient": {
                        "start": gradient['start'],
                        "end": gradient['end'],
                        "angle": gradient['angle']
                    },
                    "x": gradient_x + (gradient_count % 3) * 150,
                    "y": gradient_y + (gradient_count // 3) * 120,
                    "type": "gradient"
                })
                gradient_count += 1
    
    # Social Brand Colors
    social_x = 1250
    social_y = 50
    
    for i, (brand, colors) in enumerate(design_tokens['colors']['social'].items()):
        colors_data.append({
            "name": f"Social/{brand.title()}/Background",
            "color": colors['background'],
            "x": social_x,
            "y": social_y + (i * 120),
            "type": "solid"
        })
        if 'border' in colors:
            colors_data.append({
                "name": f"Social/{brand.title()}/Border",
                "color": colors['border'],
                "x": social_x + 120,
                "y": social_y + (i * 120),
                "type": "solid"
            })
    
    return colors_data

def hex_to_rgb(hex_color):
    """Convert hex color to RGB values (0-1 range)"""
    hex_color = hex_color.lstrip('#')
    return {
        "r": int(hex_color[0:2], 16) / 255,
        "g": int(hex_color[2:4], 16) / 255,
        "b": int(hex_color[4:6], 16) / 255,
        "a": 1
    }

def create_typography_styles():
    """Create typography text styles"""
    typography_data = []
    
    for category, sizes in design_tokens['typography'].items():
        for size, props in sizes.items():
            typography_data.append({
                "name": f"Typography/{category.title()}/{size.title()}",
                "fontSize": props['fontSize'],
                "lineHeight": props['lineHeight'],
                "fontWeight": props['fontWeight']
            })
    
    return typography_data

def main():
    print("🎨 Setting up Fortune App Design System in Figma")
    print(f"📄 File ID: {FILE_KEY}")
    
    # Step 1: Get file info
    print("\n1. Getting file information...")
    file_info = get_file_info()
    print(f"   ✓ File name: {file_info['name']}")
    
    # Step 2: Create color data
    print("\n2. Preparing color styles...")
    colors = create_color_rectangles()
    print(f"   ✓ Created {len(colors)} color definitions")
    
    # Step 3: Create typography data
    print("\n3. Preparing typography styles...")
    typography = create_typography_styles()
    print(f"   ✓ Created {len(typography)} typography definitions")
    
    # Step 4: Save configuration for manual setup
    print("\n4. Saving configuration...")
    config = {
        "colors": colors,
        "typography": typography,
        "spacing": design_tokens['spacing'],
        "borderRadius": design_tokens['borderRadius']
    }
    
    with open('figma-design-system-config.json', 'w') as f:
        json.dump(config, f, indent=2)
    
    print("\n✅ Design system configuration created!")
    print("\n📋 Next steps:")
    print("1. Open the Figma file")
    print("2. Create pages: 'Design System', 'Components', 'Screens'")
    print("3. In 'Design System' page, create color swatches using the configuration")
    print("4. Create text styles for typography")
    print("5. Build components in the 'Components' page")
    
    # Output sample color creation instructions
    print("\n🎨 Sample color creation:")
    print("- Create 100x100px rectangles for solid colors")
    print("- Create 200x100px rectangles for gradients")
    print("- Apply fills and create styles (right-click → Create Style)")
    
    return config

if __name__ == "__main__":
    main()