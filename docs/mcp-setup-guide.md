# MCP (Model Context Protocol) Setup Guide for Fortune App

## Overview

This guide provides detailed instructions for setting up MCP servers with Claude Desktop and Cursor for the Fortune app. MCP enables AI assistants to interact with external tools and services in a standardized way.

## Prerequisites

- Node.js 18+ and npm installed
- Claude Desktop application
- Cursor editor (optional)
- Supabase project credentials
- Figma desktop app (for Figma MCP)

## Quick Setup

Run the automated setup script:

```bash
./scripts/setup-mcp.sh
```

This script will:
- Install required MCP packages
- Configure Claude Desktop with MCP servers
- Set up Playwright, Supabase, and Figma integrations

## Manual Setup

### 1. Install MCP Packages

```bash
# Install Playwright MCP
npm install --save-dev @playwright/mcp@latest --legacy-peer-deps
```

### 2. Configure Claude Desktop

Create the configuration file at `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
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
        "YOUR_SUPABASE_URL/rest/v1",
        "--apiKey",
        "YOUR_SUPABASE_ANON_KEY",
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
```

### 3. Configure Cursor (Optional)

Update `~/.cursor/mcp.json` with the same configuration.

## MCP Server Capabilities

### Playwright MCP Server

The Playwright MCP provides browser automation capabilities:

- **Launch browsers**: Chrome, Firefox, Safari, Edge
- **Run tests**: Execute Playwright test suites
- **Take screenshots**: Capture page screenshots
- **Interact with pages**: Click, type, navigate
- **Debug tests**: Step through test execution

Example usage in Claude:
```
"Run the Playwright tests for the onboarding flow"
"Take a screenshot of the fortune result page"
"Debug why the MBTI modal test is failing"
```

### Supabase MCP Server

The Supabase MCP enables database operations:

- **Query tables**: Select, filter, and join data
- **Insert records**: Add new entries to tables
- **Update data**: Modify existing records
- **Delete records**: Remove data from tables
- **View schema**: Inspect table structures

Example usage in Claude:
```
"Show me all users who signed up this week"
"Query the daily_fortunes table for today's entries"
"Update the user profile for test@example.com"
```

### Figma MCP Server

The Figma MCP allows design system integration:

- **Access components**: View and reference design components
- **Export assets**: Get images and icons from Figma
- **Check styles**: Review color palettes and typography
- **Sync designs**: Keep code aligned with designs

Note: Requires Figma desktop app running with the MCP plugin.

## Environment Variables

Add these to your `.env.local`:

```bash
# Supabase (required)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# Optional MCP credentials
FIGMA_ACCESS_TOKEN=your-figma-token
GITHUB_PERSONAL_ACCESS_TOKEN=your-github-token
```

## Testing MCP Integration

### 1. Verify MCP Servers are Running

In Claude Desktop, you should see the MCP servers listed in the tools panel.

### 2. Run Integration Tests

```bash
npm test tests/mcp-integration.spec.ts
```

### 3. Test Individual Servers

#### Test Playwright:
```bash
# In Claude, ask:
"Use Playwright to navigate to localhost:3000 and take a screenshot"
```

#### Test Supabase:
```bash
# In Claude, ask:
"Query the users table in Supabase and show me the schema"
```

#### Test Figma:
```bash
# In Claude, ask:
"Connect to Figma and list available design files"
```

## Troubleshooting

### MCP Server Not Appearing in Claude

1. Restart Claude Desktop after configuration
2. Check the config file location is correct
3. Verify JSON syntax in the config file
4. Check Claude Desktop logs for errors

### Supabase Connection Issues

1. Verify credentials in `.env.local`
2. Check Supabase project is active
3. Ensure API URL includes `/rest/v1`
4. Test with curl: `curl YOUR_SUPABASE_URL/rest/v1/`

### Playwright Browser Issues

1. Install browsers: `npx playwright install`
2. Check browser permissions
3. Verify no conflicting Playwright instances

### Figma Connection Failed

1. Ensure Figma desktop app is running
2. Install Figma MCP plugin from Figma community
3. Check port 3845 is not blocked
4. Restart Figma app

## Security Best Practices

1. **Never commit credentials**: Keep `.env.local` in `.gitignore`
2. **Use read-only access**: When possible, use read-only API keys
3. **Rotate tokens regularly**: Update access tokens periodically
4. **Limit permissions**: Grant minimal required permissions
5. **Monitor usage**: Check API usage in respective dashboards

## Advanced Configuration

### Custom MCP Server

Create a custom MCP server for project-specific tools:

```javascript
// mcp-servers/fortune-mcp.js
import { Server } from '@modelcontextprotocol/sdk';

const server = new Server({
  name: 'fortune-mcp',
  version: '1.0.0',
});

// Add custom tools here
server.addTool({
  name: 'generate-fortune',
  description: 'Generate a fortune using AI',
  parameters: {
    type: 'object',
    properties: {
      category: { type: 'string' },
      userInfo: { type: 'object' }
    }
  },
  handler: async (params) => {
    // Implementation
  }
});

server.start();
```

### Debugging MCP Servers

Enable debug logging:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"],
      "env": {
        "DEBUG": "*",
        "LOG_LEVEL": "debug"
      }
    }
  }
}
```

## Resources

- [MCP Documentation](https://modelcontextprotocol.io)
- [Claude Desktop Docs](https://docs.anthropic.com/claude/docs/claude-desktop)
- [Playwright MCP](https://github.com/playwright/mcp)
- [Supabase MCP](https://github.com/supabase/mcp-server-supabase)

## Support

For issues specific to:
- **Fortune App**: Create an issue in the project repository
- **MCP Servers**: Check respective GitHub repositories
- **Claude Desktop**: Contact Anthropic support