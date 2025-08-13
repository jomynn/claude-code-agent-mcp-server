#!/bin/bash

# Quick n8n-MCP Diagnostic Script
# Usage: ./quick-n8n-check.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔍 Quick n8n-MCP Status Check${NC}"
echo "================================"
echo ""

# 1. Check if we're in the right directory
echo -e "${BLUE}📁 Project Directory Check${NC}"
if [ -f ".mcp.json" ]; then
    echo -e "   ${GREEN}✅ Found .mcp.json${NC}"
else
    echo -e "   ${RED}❌ .mcp.json not found${NC}"
    echo -e "   ${YELLOW}⚠️  Run this script from your MCP project directory${NC}"
fi

if [ -f "package.json" ]; then
    echo -e "   ${GREEN}✅ Found package.json${NC}"
    PROJECT_NAME=$(grep '"name"' package.json | cut -d'"' -f4 2>/dev/null)
    echo -e "   ${BLUE}📦 Project: ${PROJECT_NAME:-Unknown}${NC}"
else
    echo -e "   ${YELLOW}⚠️  package.json not found${NC}"
fi

echo ""

# 2. Check n8n instance
echo -e "${BLUE}📡 n8n Instance Check${NC}"
if command -v curl >/dev/null 2>&1; then
    if curl -s --connect-timeout 5 http://localhost:5678/rest/health | grep -q "ok"; then
        echo -e "   ${GREEN}✅ n8n is running at localhost:5678${NC}"
        
        # Check API access
        API_KEY=$(grep "N8N_API_KEY" .env 2>/dev/null | cut -d'=' -f2)
        if [ -n "$API_KEY" ]; then
            if curl -s -H "X-N8N-API-KEY: $API_KEY" http://localhost:5678/rest/workflows >/dev/null 2>&1; then
                echo -e "   ${GREEN}✅ n8n API accessible with key${NC}"
            else
                echo -e "   ${YELLOW}⚠️  n8n API access issues${NC}"
            fi
        else
            echo -e "   ${YELLOW}⚠️  No API key found in .env${NC}"
        fi
    else
        echo -e "   ${RED}❌ n8n not accessible at localhost:5678${NC}"
        echo -e "   ${YELLOW}💡 Try: npm run start${NC}"
    fi
else
    echo -e "   ${YELLOW}⚠️  curl not available - cannot test n8n${NC}"
fi

echo ""

# 3. Check MCP configuration
echo -e "${BLUE}⚙️ MCP Configuration Check${NC}"
if [ -f ".mcp.json" ]; then
    # Check for n8n-mcp server
    if grep -q "n8n" .mcp.json; then
        echo -e "   ${GREEN}✅ n8n-related MCP server found in config${NC}"
        
        # Show n8n MCP servers
        echo -e "   ${BLUE}🔧 n8n MCP servers:${NC}"
        grep -o '"[^"]*n8n[^"]*"' .mcp.json | tr -d '"' | sed 's/^/     • /'
    else
        echo -e "   ${YELLOW}⚠️  No n8n MCP server in configuration${NC}"
    fi
    
    # Check total MCP servers
    SERVER_COUNT=$(grep -o '"[^"]*":.*{' .mcp.json | grep -v "mcpServers" | wc -l)
    echo -e "   ${BLUE}📊 Total MCP servers configured: ${SERVER_COUNT}${NC}"
else
    echo -e "   ${RED}❌ .mcp.json not found${NC}"
fi

echo ""

# 4. Check n8n-mcp files
echo -e "${BLUE}📁 n8n-MCP Files Check${NC}"
if [ -d "n8n-mcp" ]; then
    echo -e "   ${GREEN}✅ n8n-mcp directory exists${NC}"
    
    if [ -f "n8n-mcp/dist/mcp/index.js" ]; then
        echo -e "   ${GREEN}✅ n8n-MCP server file exists${NC}"
    elif [ -f "n8n-mcp/index.js" ]; then
        echo -e "   ${GREEN}✅ n8n-MCP server file exists (alternate location)${NC}"
    else
        echo -e "   ${YELLOW}⚠️  n8n-MCP server file not found${NC}"
        echo -e "   ${BLUE}💡 Try: cd n8n-mcp && npm run build${NC}"
    fi
else
    echo -e "   ${RED}❌ n8n-mcp directory not found${NC}"
    echo -e "   ${YELLOW}💡 n8n-MCP server not installed${NC}"
fi

echo ""

# 5. Check Node.js and npm
echo -e "${BLUE}🛠️ Environment Check${NC}"
if command -v node >/dev/null 2>&1; then
    NODE_VERSION=$(node --version)
    echo -e "   ${GREEN}✅ Node.js: ${NODE_VERSION}${NC}"
else
    echo -e "   ${RED}❌ Node.js not found${NC}"
fi

if command -v claude >/dev/null 2>&1; then
    echo -e "   ${GREEN}✅ Claude Code CLI available${NC}"
else
    echo -e "   ${YELLOW}⚠️  Claude Code CLI not found${NC}"
    echo -e "   ${BLUE}💡 Install: npm install -g @anthropic-ai/claude-code${NC}"
fi

echo ""

# 6. Quick test suggestions
echo -e "${BLUE}🧪 Quick Tests${NC}"
echo -e "   ${BLUE}1. Test MCP servers:${NC}"
echo -e "      claude \"/mcp\""
echo ""
echo -e "   ${BLUE}2. Test n8n access:${NC}"
echo -e "      claude \"Check if n8n is accessible and list workflows\""
echo ""
echo -e "   ${BLUE}3. Test basic functionality:${NC}"
echo -e "      claude \"Add todo: Test n8n-MCP integration\""
echo ""

# 7. Quick fixes
echo -e "${BLUE}🔧 Quick Fixes${NC}"

if ! curl -s --connect-timeout 3 http://localhost:5678/rest/health >/dev/null 2>&1; then
    echo -e "   ${YELLOW}📡 Start n8n:${NC}"
    echo -e "      npm run start"
    echo ""
fi

if ! grep -q "n8n" .mcp.json 2>/dev/null; then
    echo -e "   ${YELLOW}⚙️ Add basic n8n integration to .mcp.json:${NC}"
    echo -e '      Add: "n8n-basic": {"command": "npx", "args": ["-y", "n8n-mcp"], "env": {}}'
    echo ""
fi

if [ ! -d "n8n-mcp" ]; then
    echo -e "   ${YELLOW}📦 Install n8n-MCP:${NC}"
    echo -e "      git clone https://github.com/czlonkowski/n8n-mcp.git"
    echo -e "      cd n8n-mcp && npm install && npm run build"
    echo ""
fi

echo -e "${BLUE}📋 Summary${NC}"
echo "============"

# Overall status
ISSUES=0

if [ ! -f ".mcp.json" ]; then ((ISSUES++)); fi
if ! curl -s --connect-timeout 3 http://localhost:5678/rest/health >/dev/null 2>&1; then ((ISSUES++)); fi
if ! grep -q "n8n" .mcp.json 2>/dev/null; then ((ISSUES++)); fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✅ Setup looks good! Test with Claude Code.${NC}"
else
    echo -e "${YELLOW}⚠️  Found $ISSUES potential issues. See fixes above.${NC}"
fi

echo ""
echo -e "${BLUE}Next Step: claude \"/mcp\" to test MCP servers${NC}"