# n8n-MCP Server Status Check Guide

## 1. Check MCP Server Status in Claude Code

### Primary Method: MCP Command
```bash
# Start Claude Code in your project directory
cd /c/Workspace/N8N_MCP  # or your project path
claude

# In Claude Code, check MCP server status
> /mcp
```

**Expected Output:**
```
⎿ MCP Server Status ⎿
⎿ 
⎿ • memory-dump: connected
⎿ • filesystem-target: connected  
⎿ • filesystem-current: connected
⎿ • n8n-mcp: connected          ← This should show if n8n-MCP is running
```

### Test n8n-MCP Functionality
```bash
# Test n8n-MCP specific commands
> "Show me available n8n nodes for HTTP requests"
> "List all n8n workflows"
> "Get n8n node documentation for the Manual Trigger"
```

## 2. Check n8n-MCP Configuration

### Verify .mcp.json Configuration
```bash
# Check if n8n-mcp is configured
cat .mcp.json | grep -A 10 "n8n-mcp"
```

**Expected Configuration:**
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "node",
      "args": ["./n8n-mcp/dist/mcp/index.js"],
      "env": {
        "N8N_CONFIG_FILE": "./n8n-mcp-config.json",
        "NODE_ENV": "production",
        "LOG_LEVEL": "error"
      }
    }
  }
}
```

### Check if n8n-MCP Files Exist
```bash
# Check if n8n-mcp directory exists
ls -la n8n-mcp/

# Check if the main server file exists
ls -la n8n-mcp/dist/mcp/index.js

# Check if configuration file exists
ls -la n8n-mcp-config.json
```

## 3. Check n8n Instance Status

### Verify n8n is Running
```bash
# Check if n8n is accessible
curl -s http://localhost:5678/rest/health

# Expected response: {"status":"ok"}

# Check if n8n API is accessible
curl -H "X-N8N-API-KEY: your_api_key_here" \
     http://localhost:5678/rest/workflows

# Should return workflow list (may be empty array [])
```

### Check n8n Process
```bash
# Check if n8n process is running
ps aux | grep n8n

# Or on Windows
tasklist | findstr n8n

# Check what's using port 5678
netstat -tulpn | grep 5678  # Linux/Mac
netstat -ano | findstr 5678  # Windows
```

## 4. Manual n8n-MCP Server Test

### Test n8n-MCP Server Directly
```bash
# Navigate to n8n-mcp directory (if it exists)
cd n8n-mcp

# Try to run the server manually
node dist/mcp/index.js

# Or if using the built version
npm start
```

### Test with Alternative Configuration
```bash
# Create a minimal test configuration
cat > test-n8n-mcp.json << 'EOF'
{
  "mcpServers": {
    "n8n-test": {
      "command": "npx",
      "args": ["-y", "@n8n/mcp-server"],
      "env": {
        "N8N_HOST": "http://localhost:5678",
        "N8N_API_KEY": "your_api_key_here"
      }
    }
  }
}
EOF
```

## 5. Troubleshooting Common Issues

### Issue 1: n8n-MCP Not in Configuration
```bash
# Add n8n-mcp to .mcp.json if missing
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "memory-dump": {
      "command": "node",
      "args": ["./mcp-servers/memory-dump-server.js"],
      "env": {
        "MEMORY_FILE": "./project-memory.json",
        "DUMP_DIR": "./memory-dumps"
      }
    },
    "filesystem-current": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"],
      "env": {}
    },
    "n8n-basic": {
      "command": "npx",
      "args": ["-y", "n8n-mcp-server"],
      "env": {
        "N8N_HOST": "http://localhost:5678",
        "N8N_API_KEY": "your_api_key_here"
      }
    }
  }
}
EOF
```

### Issue 2: n8n-MCP Package Not Installed
```bash
# Install n8n-MCP server globally
npm install -g n8n-mcp-server

# Or install locally
npm install n8n-mcp-server

# Or use the community version
git clone https://github.com/czlonkowski/n8n-mcp.git
cd n8n-mcp
npm install
npm run build
```

### Issue 3: n8n Instance Not Running
```bash
# Start n8n if not running
npm run start

# Or start n8n directly
n8n start

# Or with Docker
docker-compose up -d n8n
```

### Issue 4: API Key Issues
```bash
# Check your n8n API key in .env
grep N8N_API_KEY .env

# Test API key manually
curl -H "X-N8N-API-KEY: $(grep N8N_API_KEY .env | cut -d'=' -f2)" \
     http://localhost:5678/rest/workflows
```

## 6. Alternative: Use Basic n8n Integration

### If n8n-MCP Not Available, Use HTTP Requests
```bash
# Update .mcp.json to use fetch server for n8n API calls
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "memory-dump": {
      "command": "node",
      "args": ["./mcp-servers/memory-dump-server.js"],
      "env": {
        "MEMORY_FILE": "./project-memory.json",
        "DUMP_DIR": "./memory-dumps"
      }
    },
    "filesystem-current": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"],
      "env": {}
    },
    "web-requests": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "env": {}
    }
  }
}
EOF
```

### Test n8n via HTTP Requests
```bash
# In Claude Code, make HTTP requests to n8n
> "Make an HTTP GET request to http://localhost:5678/rest/workflows to list n8n workflows"
> "Make an HTTP GET request to http://localhost:5678/rest/health to check n8n status"
```

## 7. Create n8n-MCP Status Check Script

### Automated Status Check Script
```bash
# Create status check script
cat > check-n8n-mcp.sh << 'EOF'
#!/bin/bash

echo "🔍 n8n-MCP Status Check"
echo "======================"

# Check n8n instance
echo "📡 Checking n8n instance..."
if curl -s http://localhost:5678/rest/health | grep -q "ok"; then
    echo "   ✅ n8n is running and accessible"
else
    echo "   ❌ n8n is not accessible at localhost:5678"
fi

# Check n8n API
echo ""
echo "🔑 Checking n8n API access..."
API_KEY=$(grep N8N_API_KEY .env 2>/dev/null | cut -d'=' -f2)
if [ -n "$API_KEY" ]; then
    if curl -s -H "X-N8N-API-KEY: $API_KEY" http://localhost:5678/rest/workflows >/dev/null; then
        echo "   ✅ n8n API is accessible with key"
    else
        echo "   ❌ n8n API access failed"
    fi
else
    echo "   ⚠️ No API key found in .env file"
fi

# Check n8n-mcp configuration
echo ""
echo "⚙️ Checking n8n-MCP configuration..."
if grep -q "n8n-mcp" .mcp.json 2>/dev/null; then
    echo "   ✅ n8n-MCP configured in .mcp.json"
else
    echo "   ❌ n8n-MCP not found in .mcp.json"
fi

# Check n8n-mcp files
echo ""
echo "📁 Checking n8n-MCP files..."
if [ -d "n8n-mcp" ]; then
    echo "   ✅ n8n-mcp directory exists"
    if [ -f "n8n-mcp/dist/mcp/index.js" ]; then
        echo "   ✅ n8n-MCP server file exists"
    else
        echo "   ❌ n8n-MCP server file missing"
    fi
else
    echo "   ❌ n8n-mcp directory not found"
fi

# Check MCP servers with Claude Code
echo ""
echo "🤖 Testing MCP connection..."
echo "   Run: claude '/mcp' to check MCP server status"
echo "   Test: claude 'List n8n workflows' to test functionality"

echo ""
echo "💡 Quick Fixes:"
echo "   • Start n8n: npm run start"
echo "   • Install n8n-MCP: git clone https://github.com/czlonkowski/n8n-mcp.git"
echo "   • Test MCP: claude '/mcp'"
EOF

chmod +x check-n8n-mcp.sh
```

### Run the Status Check
```bash
# Run the status check script
./check-n8n-mcp.sh
```

## 8. Working Configuration Examples

### Minimal Working n8n-MCP Setup
```json
{
  "mcpServers": {
    "memory-dump": {
      "command": "node",
      "args": ["./mcp-servers/memory-dump-server.js"],
      "env": {
        "MEMORY_FILE": "./project-memory.json",
        "DUMP_DIR": "./memory-dumps"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"],
      "env": {}
    }
  }
}
```

### If n8n-MCP Available
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["-y", "n8n-mcp-server"],
      "env": {
        "N8N_HOST": "http://localhost:5678",
        "N8N_API_KEY": "your_api_key_here"
      }
    }
  }
}
```

## 9. Expected Behavior When Working

### Successful n8n-MCP Connection
```bash
# In Claude Code
> /mcp
# Shows: • n8n-mcp: connected

> "Show me n8n node types"
# Returns: List of available n8n nodes

> "List my n8n workflows"
# Returns: Your workflows or empty list if none exist

> "Create a simple n8n workflow"
# Returns: Workflow creation guidance or JSON
```

### Failed Connection Indicators
```bash
# In Claude Code
> /mcp
# Missing: n8n-mcp server not listed

> "Show me n8n workflows"
# Error: "I don't have access to n8n" or similar

# Check logs
tail -f logs/project.log
# Look for MCP connection errors
```

## 10. Quick Recovery Steps

### If n8n-MCP is Not Working
1. **Verify n8n is running**: `curl http://localhost:5678/rest/health`
2. **Check API key**: Test with curl command above
3. **Remove n8n-mcp from .mcp.json temporarily**
4. **Restart Claude Code**: Exit and restart in project directory
5. **Use alternative HTTP-based approach**

### Minimal Working Setup
```bash
# Focus on core MCP servers first
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "memory-dump": {
      "command": "node",
      "args": ["./mcp-servers/memory-dump-server.js"],
      "env": {}
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"],
      "env": {}
    }
  }
}
EOF

# Test basic functionality
claude "/mcp"
claude "Add todo: Set up n8n-MCP integration"
```

The key is to ensure n8n is running first, then verify the MCP configuration, and finally test the connection through Claude Code.