# Directory Target Configuration for Code Generation

## 1. Claude Code Directory Configuration

### Setting Working Directory
```bash
# Method 1: Start Claude Code in specific directory
cd /path/to/your/target/project
claude

# Method 2: Use --add-dir to include additional directories
claude --add-dir /path/to/target/directory

# Method 3: Add multiple directories
claude --add-dir /path/to/frontend --add-dir /path/to/backend
```

### Mid-Session Directory Management
```bash
# Inside Claude Code session, add new directories
> /add-dir /path/to/new/target/directory

# List current accessible directories
> /dirs

# Change working context
> /cd /path/to/target/directory
```

## 2. MCP Filesystem Server Configuration

### Configure Target Directories in .mcp.json
```json
{
  "mcpServers": {
    "filesystem-main": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/main/project"],
      "env": {}
    },
    "filesystem-frontend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/frontend"],
      "env": {}
    },
    "filesystem-backend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/backend"],
      "env": {}
    }
  }
}
```

### Multiple Project Access
```json
{
  "mcpServers": {
    "filesystem-workspace": {
      "command": "npx",
      "args": [
        "-y", 
        "@modelcontextprotocol/server-filesystem", 
        "/workspace/project1",
        "/workspace/project2",
        "/workspace/shared-libs"
      ],
      "env": {}
    }
  }
}
```

## 3. Environment-Based Directory Configuration

### Using Environment Variables
```bash
# Set in your .env file
TARGET_PROJECT_DIR=/path/to/your/project
FRONTEND_DIR=/path/to/frontend
BACKEND_DIR=/path/to/backend
SHARED_LIBS_DIR=/path/to/shared/libraries

# Export for current session
export TARGET_PROJECT_DIR="/c/Workspace/MyProject"
export FRONTEND_DIR="/c/Workspace/MyProject/frontend"
export BACKEND_DIR="/c/Workspace/MyProject/backend"
```

### Update .mcp.json to use environment variables
```json
{
  "mcpServers": {
    "filesystem-target": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${TARGET_PROJECT_DIR}"],
      "env": {
        "TARGET_PROJECT_DIR": "/c/Workspace/MyProject"
      }
    },
    "filesystem-frontend": {
      "command": "npx", 
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${FRONTEND_DIR}"],
      "env": {
        "FRONTEND_DIR": "/c/Workspace/MyProject/frontend"
      }
    }
  }
}
```

## 4. Windows-Specific Directory Configuration

### Windows Path Format
```json
{
  "mcpServers": {
    "filesystem-windows": {
      "command": "npx",
      "args": [
        "-y", 
        "@modelcontextprotocol/server-filesystem", 
        "C:\\Workspace\\MyProject",
        "C:\\Workspace\\Libraries"
      ],
      "env": {}
    }
  }
}
```

### MINGW64/Git Bash Compatible Paths
```json
{
  "mcpServers": {
    "filesystem-mingw": {
      "command": "npx",
      "args": [
        "-y", 
        "@modelcontextprotocol/server-filesystem", 
        "/c/Workspace/MyProject",
        "/c/Workspace/Libraries"
      ],
      "env": {}
    }
  }
}
```

## 5. Project-Specific Target Configuration

### Create Project Target Config Script
```bash
#!/bin/bash
# setup-project-targets.sh

PROJECT_ROOT="/c/Workspace/MyProject"
FRONTEND_DIR="$PROJECT_ROOT/frontend"
BACKEND_DIR="$PROJECT_ROOT/backend"
SHARED_DIR="$PROJECT_ROOT/shared"

# Create directories if they don't exist
mkdir -p "$FRONTEND_DIR" "$BACKEND_DIR" "$SHARED_DIR"

# Update MCP configuration
cat > .mcp.json << EOF
{
  "mcpServers": {
    "memory-dump": {
      "command": "node",
      "args": ["./mcp-servers/memory-dump-server.js"],
      "env": {
        "MEMORY_FILE": "./project-memory.json",
        "DUMP_DIR": "./memory-dumps",
        "AUTO_DUMP": "true"
      }
    },
    "filesystem-main": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$PROJECT_ROOT"],
      "env": {}
    },
    "filesystem-frontend": {
      "command": "npx", 
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$FRONTEND_DIR"],
      "env": {}
    },
    "filesystem-backend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$BACKEND_DIR"],
      "env": {}
    }
  }
}
EOF

echo "✅ Project targets configured:"
echo "   Main: $PROJECT_ROOT"
echo "   Frontend: $FRONTEND_DIR" 
echo "   Backend: $BACKEND_DIR"
echo "   Shared: $SHARED_DIR"
```

## 6. Dynamic Directory Selection

### Interactive Directory Setup
```bash
#!/bin/bash
# interactive-setup.sh

echo "🎯 Setting up target directories for code generation"
echo ""

# Get project root
read -p "Enter main project directory: " PROJECT_ROOT
PROJECT_ROOT=${PROJECT_ROOT:-"/c/Workspace/MyProject"}

# Get sub-directories
read -p "Enter frontend directory [$PROJECT_ROOT/frontend]: " FRONTEND_DIR
FRONTEND_DIR=${FRONTEND_DIR:-"$PROJECT_ROOT/frontend"}

read -p "Enter backend directory [$PROJECT_ROOT/backend]: " BACKEND_DIR  
BACKEND_DIR=${BACKEND_DIR:-"$PROJECT_ROOT/backend"}

# Create directories
mkdir -p "$PROJECT_ROOT" "$FRONTEND_DIR" "$BACKEND_DIR"

# Generate MCP config
cat > .mcp.json << EOF
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
    "filesystem-main": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$PROJECT_ROOT"],
      "env": {}
    },
    "filesystem-frontend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$FRONTEND_DIR"],
      "env": {}
    },
    "filesystem-backend": {
      "command": "npx", 
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$BACKEND_DIR"],
      "env": {}
    }
  }
}
EOF

echo "✅ Configuration complete!"
echo "Target directories:"
echo "  📁 Main: $PROJECT_ROOT"
echo "  📁 Frontend: $FRONTEND_DIR"
echo "  📁 Backend: $BACKEND_DIR"
```

## 7. Usage Examples

### Basic Code Generation with Target Directory
```bash
# Start Claude Code in your MCP project
cd /c/Workspace/N8N_MCP
claude

# Generate code in specific target directory
> "Create a React component called UserProfile in the frontend directory with props for name, email, and avatar"

> "Generate a Node.js Express API in the backend directory with endpoints for user CRUD operations"

> "Create a shared utility library in the shared directory for API response formatting"
```

### Advanced Multi-Directory Generation
```bash
# Complex project generation
> "Create a full-stack application with:
   - React frontend in /c/Workspace/MyProject/frontend
   - Node.js backend in /c/Workspace/MyProject/backend  
   - Shared types in /c/Workspace/MyProject/shared
   - Database models in /c/Workspace/MyProject/backend/models
   Include authentication, user management, and dashboard"
```

### Memory-Driven Directory Management
```bash
# Record target directories in memory
> "Remember that my main project is at /c/Workspace/MyProject with frontend, backend, and shared subdirectories"

> "Add todo: Set up project structure with proper target directories"

> "Update project status: configured target directories for code generation"
```

## 8. Troubleshooting Directory Issues

### Check Current Directory Access
```bash
# In Claude Code
> /dirs
> List all accessible directories and show their contents

# Test file operations
> "What files are in the current directory?"
> "Can you access the /c/Workspace/MyProject directory?"
```

### Fix Path Issues
```bash
# Convert Windows paths to MINGW64 format
C:\Workspace\MyProject -> /c/Workspace/MyProject
C:\Users\jomyn\Documents -> /c/Users/jomyn/Documents

# Escape spaces in paths
"C:\Program Files\MyApp" -> "/c/Program Files/MyApp"
```

### Verify MCP Filesystem Server
```bash
# Test MCP servers
claude "/mcp"

# Should show filesystem servers like:
# • filesystem-main: connected
# • filesystem-frontend: connected  
# • filesystem-backend: connected
```

## 9. Best Practices

### 1. Organize by Function
```
/c/Workspace/MyProject/
├── frontend/          # React/Vue/Angular apps
├── backend/           # API servers
├── mobile/            # React Native/Flutter
├── shared/            # Shared libraries
├── docs/              # Documentation
└── tools/             # Build tools and scripts
```

### 2. Use Descriptive MCP Server Names
```json
{
  "mcpServers": {
    "fs-react-app": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/c/Workspace/MyProject/frontend"]
    },
    "fs-node-api": {
      "command": "npx", 
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/c/Workspace/MyProject/backend"]
    }
  }
}
```

### 3. Document Your Structure
```bash
# Record in project memory
> "Record decision: Use /c/Workspace/MyProject as main directory with frontend/, backend/, and shared/ subdirectories for organized code generation"

> "Add learning: Claude Code can access multiple directories simultaneously using MCP filesystem servers"
```

## 10. Quick Setup for Your Current Environment

Based on your MINGW64 environment, here's a quick setup:

```bash
# 1. Set your target directory
export TARGET_DIR="/c/Workspace/MyCodeProject"
mkdir -p "$TARGET_DIR"/{frontend,backend,shared}

# 2. Update .mcp.json
cat > .mcp.json << EOF
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
    "filesystem-target": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$TARGET_DIR"],
      "env": {}
    },
    "filesystem-current": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"],
      "env": {}
    }
  }
}
EOF

# 3. Test the setup
claude
```

Then in Claude Code:
```
> /mcp
> "List files in the target directory"
> "Create a simple Hello World React app in the target directory"
```

This gives you full control over where Claude generates code while maintaining the MCP memory and automation features.