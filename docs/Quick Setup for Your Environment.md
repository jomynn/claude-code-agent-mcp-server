Quick Setup for Your Environment
Based on your MINGW64 Windows setup, here's how to configure target directories:
Method 1: Quick Setup Script

Save and run the setup script:

bash# Save the script as setup-targets.sh
chmod +x setup-targets.sh

# Run with your desired target directory
./setup-targets.sh "/c/Workspace/MyCodeProject"

# Or run interactively
./setup-targets.sh
Method 2: Manual Configuration

Set your target directory:

bash# Choose your target directory (Windows format)
TARGET_DIR="/c/Workspace/MyCodeProject"

# Create the structure
mkdir -p "$TARGET_DIR"/{frontend,backend,shared,docs,tools}
mkdir -p "$TARGET_DIR"/frontend/{src,components,pages}
mkdir -p "$TARGET_DIR"/backend/{src,routes,models}

Update your .mcp.json:

bashcat > .mcp.json << EOF
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
    "filesystem-frontend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$TARGET_DIR/frontend"],
      "env": {}
    },
    "filesystem-backend": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "$TARGET_DIR/backend"],
      "env": {}
    }
  }
}
EOF

Add target directory to your .env:

bashcat >> .env << EOF

# Code Generation Targets
TARGET_PROJECT_DIR=$TARGET_DIR
FRONTEND_DIR=$TARGET_DIR/frontend
BACKEND_DIR=$TARGET_DIR/backend
SHARED_DIR=$TARGET_DIR/shared
EOF
Method 3: Using Claude Code Built-in Directory Management

Start Claude Code and add directories:

bashcd /c/Workspace/N8N_MCP
claude --add-dir /c/Workspace/MyCodeProject

In Claude Code session:

> /add-dir /c/Workspace/MyCodeProject/frontend
> /add-dir /c/Workspace/MyCodeProject/backend
> /dirs
Testing Your Setup

Test MCP servers:

bashclaude "/mcp"
# Should show your filesystem servers

Test directory access:

bashclaude "List contents of the target directory"
claude "What directories are available for code generation?"

Test code generation:

bashclaude "Create a simple React component called HelloWorld in the frontend directory"
claude "Generate a basic Express server setup in the backend directory"
Common Usage Patterns
Frontend Development
bash# React components
claude "Create a UserProfile React component with TypeScript in the frontend/src/components directory"

# Pages
claude "Generate a Dashboard page component in the frontend/src/pages directory"

# Hooks
claude "Create a custom useAuth hook in the frontend/src/hooks directory"
Backend Development
bash# API routes
claude "Create Express routes for user CRUD operations in the backend/src/routes directory"

# Models
claude "Generate Mongoose models for User and Product in the backend/src/models directory"

# Middleware
claude "Create authentication middleware in the backend/src/middleware directory"
Full-Stack Features
bash# Complete feature
claude "Create a complete user authentication system with:
- React login/register components in frontend
- Express auth routes in backend  
- Shared TypeScript interfaces in shared directory"
Directory Structure You'll Get
/c/Workspace/MyCodeProject/
├── frontend/
│   ├── src/
│   ├── components/
│   ├── pages/
│   ├── hooks/
│   └── utils/
├── backend/
│   ├── src/
│   ├── routes/
│   ├── models/
│   ├── middleware/
│   └── config/
├── shared/
│   ├── types/
│   ├── utils/
│   └── constants/
├── docs/
└── tools/
Quick Commands for Your Setup
bash# 1. Set target directory
TARGET_DIR="/c/Workspace/MyCodeProject"

# 2. Create structure  
mkdir -p "$TARGET_DIR"/{frontend,backend,shared}

# 3. Update MCP config (use the script above)

# 4. Test with Claude
claude "Create a README.md in the target directory explaining the project structure"
This gives you organized code generation with Claude Code targeting specific directories while maintaining your MCP memory and automation system.