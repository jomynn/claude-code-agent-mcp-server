#!/bin/bash

# Windows Directory Target Setup Script for Code Generation
# Usage: ./setup-targets.sh [target-directory]

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Get target directory from user input or argument
get_target_directory() {
    if [ -n "$1" ]; then
        TARGET_DIR="$1"
    else
        echo "🎯 Code Generation Directory Setup"
        echo ""
        echo "Current directory: $(pwd)"
        echo "Suggested target: /c/Workspace/MyCodeProject"
        echo ""
        read -p "Enter target directory for code generation: " TARGET_DIR
        TARGET_DIR=${TARGET_DIR:-"/c/Workspace/MyCodeProject"}
    fi
    
    # Convert Windows paths to MINGW64 format if needed
    TARGET_DIR=$(echo "$TARGET_DIR" | sed 's|C:\\|/c/|g' | sed 's|\\|/|g')
    
    log_info "Target directory: $TARGET_DIR"
}

create_project_structure() {
    log_info "Creating project structure..."
    
    # Create main directories
    mkdir -p "$TARGET_DIR"/{frontend,backend,shared,docs,tools,tests}
    
    # Create subdirectories
    mkdir -p "$TARGET_DIR"/frontend/{src,public,components,pages,hooks,utils}
    mkdir -p "$TARGET_DIR"/backend/{src,routes,models,middleware,config,tests}
    mkdir -p "$TARGET_DIR"/shared/{types,utils,constants,schemas}
    mkdir -p "$TARGET_DIR"/docs/{api,user,dev}
    mkdir -p "$TARGET_DIR"/tools/{scripts,configs,templates}
    
    log_success "Project structure created at $TARGET_DIR"
}

create_mcp_config() {
    log_info "Creating MCP configuration for target directories..."
    
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
    "filesystem-target": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$TARGET_DIR"],
      "env": {}
    },
    "filesystem-frontend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$TARGET_DIR/frontend"],
      "env": {}
    },
    "filesystem-backend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$TARGET_DIR/backend"],
      "env": {}
    },
    "filesystem-shared": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$TARGET_DIR/shared"],
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
    
    log_success "MCP configuration updated with target directories"
}

create_project_config() {
    log_info "Creating project configuration files..."
    
    # Create .env with target directories
    cat >> .env << EOF

# Code Generation Target Directories
TARGET_PROJECT_DIR=$TARGET_DIR
FRONTEND_DIR=$TARGET_DIR/frontend
BACKEND_DIR=$TARGET_DIR/backend
SHARED_DIR=$TARGET_DIR/shared
DOCS_DIR=$TARGET_DIR/docs
TOOLS_DIR=$TARGET_DIR/tools
EOF
    
    # Create project structure documentation
    cat > "$TARGET_DIR/PROJECT_STRUCTURE.md" << 'EOF'
# Project Structure

This project is organized with the following directory structure:

## 📁 Directory Overview

```
project/
├── frontend/           # Frontend application
│   ├── src/           # Source code
│   ├── public/        # Static assets
│   ├── components/    # Reusable components
│   ├── pages/         # Page components
│   ├── hooks/         # Custom React hooks
│   └── utils/         # Frontend utilities
├── backend/           # Backend API
│   ├── src/           # Source code
│   ├── routes/        # API routes
│   ├── models/        # Data models
│   ├── middleware/    # Express middleware
│   ├── config/        # Configuration files
│   └── tests/         # Backend tests
├── shared/            # Shared code between frontend/backend
│   ├── types/         # TypeScript type definitions
│   ├── utils/         # Shared utilities
│   ├── constants/     # Shared constants
│   └── schemas/       # Validation schemas
├── docs/              # Documentation
│   ├── api/           # API documentation
│   ├── user/          # User guides
│   └── dev/           # Developer documentation
└── tools/             # Development tools
    ├── scripts/       # Build/deployment scripts
    ├── configs/       # Tool configurations
    └── templates/     # Code templates
```

## 🎯 Code Generation Targets

When using Claude Code with MCP, you can target specific directories:

- **Main Project**: All project files
- **Frontend**: React/Vue/Angular applications
- **Backend**: Node.js/Express APIs
- **Shared**: Shared libraries and types
- **Current**: MCP project directory

## 📝 Usage Examples

```bash
# Generate frontend component
"Create a React UserProfile component in the frontend directory"

# Generate backend API
"Create Express routes for user management in the backend directory"

# Generate shared types
"Create TypeScript interfaces for User and Product in the shared types directory"
```
EOF
    
    log_success "Project configuration files created"
}

create_helper_scripts() {
    log_info "Creating helper scripts..."
    
    # Create directory navigation script
    cat > change-target.sh << 'EOF'
#!/bin/bash

# Quick script to change target directory

echo "🎯 Current target directory:"
grep "TARGET_PROJECT_DIR=" .env | cut -d'=' -f2

echo ""
read -p "Enter new target directory: " NEW_TARGET

if [ -n "$NEW_TARGET" ]; then
    # Convert Windows paths
    NEW_TARGET=$(echo "$NEW_TARGET" | sed 's|C:\\|/c/|g' | sed 's|\\|/|g')
    
    # Update .env
    sed -i "s|TARGET_PROJECT_DIR=.*|TARGET_PROJECT_DIR=$NEW_TARGET|" .env
    sed -i "s|FRONTEND_DIR=.*|FRONTEND_DIR=$NEW_TARGET/frontend|" .env
    sed -i "s|BACKEND_DIR=.*|BACKEND_DIR=$NEW_TARGET/backend|" .env
    sed -i "s|SHARED_DIR=.*|SHARED_DIR=$NEW_TARGET/shared|" .env
    
    # Recreate structure
    mkdir -p "$NEW_TARGET"/{frontend,backend,shared,docs,tools}
    
    echo "✅ Target directory updated to: $NEW_TARGET"
    echo "⚠️  Restart Claude Code to apply changes"
else
    echo "❌ No directory specified"
fi
EOF
    
    chmod +x change-target.sh
    
    # Create test script
    cat > test-targets.sh << 'EOF'
#!/bin/bash

# Test target directory access

echo "🧪 Testing target directory access..."

TARGET_DIR=$(grep "TARGET_PROJECT_DIR=" .env | cut -d'=' -f2)

echo "Target directory: $TARGET_DIR"
echo ""

if [ -d "$TARGET_DIR" ]; then
    echo "✅ Target directory exists"
    echo "📁 Contents:"
    ls -la "$TARGET_DIR" 2>/dev/null || echo "  (empty or no access)"
else
    echo "❌ Target directory does not exist"
    echo "Creating directory structure..."
    mkdir -p "$TARGET_DIR"/{frontend,backend,shared}
    echo "✅ Directory structure created"
fi

echo ""
echo "🔧 MCP Servers:"
if [ -f ".mcp.json" ]; then
    grep -o '"filesystem-[^"]*"' .mcp.json | tr -d '"'
else
    echo "❌ .mcp.json not found"
fi

echo ""
echo "🎯 To test with Claude Code:"
echo '  claude "List contents of the target directory"'
echo '  claude "Create a simple README.md in the target directory"'
EOF
    
    chmod +x test-targets.sh
    
    log_success "Helper scripts created"
}

update_package_json() {
    log_info "Updating package.json with target directory scripts..."
    
    # Check if package.json exists
    if [ -f "package.json" ]; then
        # Create temporary updated package.json
        cat package.json | jq '.scripts += {
            "change-target": "./change-target.sh",
            "test-targets": "./test-targets.sh",
            "open-target": "explorer \"$(grep TARGET_PROJECT_DIR= .env | cut -d= -f2 | sed \"s|/c/|C:/|g\")\""
        }' > package.json.tmp && mv package.json.tmp package.json
        
        log_success "Package.json updated with target directory scripts"
    else
        log_warning "package.json not found - skipping script updates"
    fi
}

record_in_memory() {
    log_info "Recording target directory in project memory..."
    
    # Initialize memory if it doesn't exist
    if [ ! -f "project-memory.json" ]; then
        cat > project-memory.json << 'EOF'
{
  "project_info": {
    "name": "MCP Code Generation Project",
    "created_at": "",
    "last_updated": ""
  },
  "todos": {
    "items": [],
    "next_id": 1
  },
  "status": {
    "current_phase": "setup",
    "progress_percentage": 0
  },
  "knowledge": {
    "decisions": [],
    "learnings": []
  }
}
EOF
    fi
    
    # Update with current timestamp
    CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Update memory with target directory info (basic shell approach)
    cat > temp_memory.json << EOF
{
  "project_info": {
    "name": "MCP Code Generation Project",
    "created_at": "$CURRENT_TIME",
    "last_updated": "$CURRENT_TIME",
    "target_directory": "$TARGET_DIR"
  },
  "todos": {
    "items": [
      {
        "id": 1,
        "title": "Configure code generation target directories",
        "status": "completed",
        "created_at": "$CURRENT_TIME",
        "completed_at": "$CURRENT_TIME"
      }
    ],
    "next_id": 2
  },
  "status": {
    "current_phase": "configured",
    "progress_percentage": 25
  },
  "knowledge": {
    "decisions": [
      {
        "id": 1,
        "title": "Set target directory for code generation",
        "description": "Configured $TARGET_DIR as the main target for generated code",
        "rationale": "Organized structure with separate frontend, backend, and shared directories",
        "decided_at": "$CURRENT_TIME"
      }
    ],
    "learnings": [
      {
        "id": 1,
        "title": "MCP Filesystem Server Configuration",
        "description": "Multiple filesystem servers can target different directories for organized code generation",
        "learned_at": "$CURRENT_TIME"
      }
    ]
  }
}
EOF
    
    mv temp_memory.json project-memory.json
    log_success "Target directory recorded in project memory"
}

print_summary() {
    echo ""
    echo "🎉 Target Directory Setup Complete!"
    echo ""
    echo "📁 Target Directory: $TARGET_DIR"
    echo "📁 Structure Created:"
    echo "   ├── frontend/     # Frontend applications"
    echo "   ├── backend/      # Backend APIs"  
    echo "   ├── shared/       # Shared code"
    echo "   ├── docs/         # Documentation"
    echo "   └── tools/        # Development tools"
    echo ""
    echo "🔧 MCP Servers Configured:"
    echo "   • filesystem-target   (main project)"
    echo "   • filesystem-frontend (React/Vue/Angular)"
    echo "   • filesystem-backend  (Node.js/Express)"
    echo "   • filesystem-shared   (shared libraries)"
    echo "   • filesystem-current  (MCP project)"
    echo ""
    echo "📝 Available Commands:"
    echo "   npm run change-target    # Change target directory"
    echo "   npm run test-targets     # Test directory access"
    echo "   ./test-targets.sh        # Test setup"
    echo ""
    echo "🚀 Usage with Claude Code:"
    echo '   claude "Create a React TodoList component in the frontend directory"'
    echo '   claude "Generate Express API routes in the backend directory"'
    echo '   claude "Create shared TypeScript interfaces in the shared directory"'
    echo ""
    echo "⚠️  Next Steps:"
    echo "   1. Restart Claude Code to load new MCP configuration"
    echo "   2. Test with: claude \"/mcp\""
    echo "   3. Verify access: claude \"List contents of target directory\""
}

main() {
    echo "🎯 Setting up target directories for code generation..."
    echo ""
    
    get_target_directory "$1"
    create_project_structure
    create_mcp_config
    create_project_config
    create_helper_scripts
    update_package_json
    record_in_memory
    print_summary
}

# Check if jq is available for package.json manipulation
if ! command -v jq &> /dev/null; then
    log_warning "jq not found - some features may not work properly"
    log_info "Install jq for full functionality: winget install jqlang.jq"
fi

main "$@"