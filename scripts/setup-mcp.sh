#!/bin/bash

# MCP (Model Context Protocol) Server Setup Script
# This script helps set up MCP servers for Claude Desktop and Cursor

echo "🚀 Fortune App MCP Server Setup"
echo "==============================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "\n${YELLOW}Checking prerequisites...${NC}"

if ! command_exists node; then
    echo -e "${RED}❌ Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}❌ npm is not installed. Please install npm first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites satisfied${NC}"

# Install MCP packages
echo -e "\n${YELLOW}Installing MCP packages...${NC}"

# Install Playwright MCP
echo "Installing @playwright/mcp..."
npm install --save-dev @playwright/mcp@latest --legacy-peer-deps

# Create Claude Desktop configuration directory
CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
echo -e "\n${YELLOW}Setting up Claude Desktop configuration...${NC}"

if [ ! -d "$CLAUDE_CONFIG_DIR" ]; then
    mkdir -p "$CLAUDE_CONFIG_DIR"
    echo -e "${GREEN}✅ Created Claude Desktop config directory${NC}"
fi

# Check if .env.local exists
if [ ! -f ".env.local" ]; then
    echo -e "${RED}❌ .env.local file not found!${NC}"
    echo -e "${YELLOW}Please copy .env.local.example to .env.local and add your credentials.${NC}"
    exit 1
fi

# Extract Supabase credentials from .env.local
SUPABASE_URL=$(grep "NEXT_PUBLIC_SUPABASE_URL=" .env.local | cut -d '=' -f2)
SUPABASE_ANON_KEY=$(grep "NEXT_PUBLIC_SUPABASE_ANON_KEY=" .env.local | cut -d '=' -f2)

if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo -e "${RED}❌ Supabase credentials not found in .env.local${NC}"
    echo "Please ensure NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY are set."
    exit 1
fi

# Extract project ref from URL
SUPABASE_PROJECT_REF=$(echo $SUPABASE_URL | sed -n 's|https://\([^.]*\)\.supabase\.co.*|\1|p')

# Create Claude Desktop config
cat > "$CLAUDE_CONFIG_DIR/claude_desktop_config.json" << EOF
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": [
        "-y",
        "@playwright/mcp@latest"
      ],
      "env": {
        "PLAYWRIGHT_BROWSERS_PATH": "0",
        "DEBUG": "pw:api"
      }
    },
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-postgrest@latest",
        "--apiUrl",
        "${SUPABASE_URL}/rest/v1",
        "--apiKey",
        "${SUPABASE_ANON_KEY}",
        "--schema",
        "public"
      ],
      "env": {}
    },
    "figma": {
      "url": "http://127.0.0.1:3845/sse"
    }
  }
}
EOF

echo -e "${GREEN}✅ Claude Desktop MCP configuration created${NC}"

# Setup instructions
echo -e "\n${GREEN}🎉 MCP Setup Complete!${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Restart Claude Desktop to load the new MCP configuration"
echo "2. For Figma MCP, ensure the Figma desktop app is running"
echo "3. Add your GitHub Personal Access Token to .env.local if needed"
echo ""
echo -e "${YELLOW}Testing MCP Servers:${NC}"
echo "- In Claude Desktop, you can now use tools like:"
echo "  - Playwright: Browser automation and testing"
echo "  - Supabase: Database queries and management"
echo "  - Figma: Design system integration"
echo ""
echo -e "${YELLOW}For more information:${NC}"
echo "- See docs/mcp-setup-guide.md for detailed documentation"
echo "- Run 'npm test tests/mcp-integration.spec.ts' to test MCP integration"