# n8n + MCP Integration Project

A comprehensive setup integrating **n8n workflow automation** with **Claude Code** and **Model Context Protocol (MCP) servers** for intelligent project management, automated memory dumps, and AI-powered development workflows.

## 🌟 Features

- **🔄 n8n Workflow Automation**: Visual workflow builder for complex automations
- **🤖 Claude Code Integration**: AI-powered coding assistant with MCP support
- **💾 Persistent Memory System**: Project state and knowledge preservation
- **📄 Automated Dumps**: Daily summaries and shutdown backups
- **🎯 Target Directory Management**: Organized code generation across multiple directories
- **🛠️ Development Tools**: Scripts for automation, monitoring, and maintenance
- **🔧 Windows Compatible**: Optimized for MINGW64/Git Bash environments

## 📁 Project Structure

```
my-project-n8n/
├── 📄 README.md                 # This file
├── 🔧 .env                      # Environment configuration
├── ⚙️ .mcp.json                 # MCP server configuration
├── 📦 package.json              # Project dependencies and scripts
├── 🚫 .gitignore               # Git ignore rules
│
├── 🤖 mcp-servers/              # Custom MCP servers
│   ├── memory-dump-server.js    # Memory management server
│   └── package.json             # MCP server dependencies
│
├── 🔄 automation/               # Automation scripts
│   ├── auto-dump.sh             # Memory dump automation
│   ├── setup-cron.sh            # Cron job setup (Linux/Mac)
│   ├── check-dumps.sh           # System status checker
│   └── windows-fix.sh           # Windows compatibility fixes
│
├── 💾 memory-dumps/             # Automated memory dumps
│   ├── daily-summary-*.md       # Daily project summaries
│   ├── memory-dump-*.md         # Full memory dumps
│   └── shutdown-backup-*.json   # Emergency backups
│
├── 💿 backups/                  # Compressed backups
│   └── *.json.gz               # Timestamped backup files
│
├── 📊 logs/                     # System logs
│   ├── project.log             # Main project log
│   ├── dump.log                # Dump operation log
│   └── cron.log                # Cron job logs
│
├── 🗂️ workflows/               # n8n workflow exports
│   └── *.json                  # Exported n8n workflows
│
└── 🎯 [Target Directories]/     # Code generation targets
    ├── frontend/               # Frontend applications
    ├── backend/                # Backend APIs
    ├── shared/                 # Shared libraries
    └── docs/                   # Documentation
```

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18.0.0 or higher
- **npm** 8.0.0 or higher
- **Git**
- **Claude Pro/Team subscription** (for Claude Code)
- **Windows**: Git Bash or WSL2 recommended

### 1. Installation

```bash
# Clone or download the project
git clone <your-repo-url>
cd my-project-n8n

# Install dependencies
npm install

# Run setup scripts
./automation/windows-fix.sh    # Windows users
./setup-targets.sh             # Set target directories
```

### 2. Configure Environment

```bash
# Edit .env file with your settings
cp .env.example .env
nano .env

# Key settings to update:
# - N8N_API_KEY=your_api_key_here
# - N8N_BASIC_AUTH_PASSWORD=your_password
# - TARGET_PROJECT_DIR=/c/Workspace/MyProject
```

### 3. Start Services

```bash
# Start n8n
npm run start &

# Authenticate Claude Code (one-time setup)
claude auth
claude --dangerously-skip-permissions

# Start Claude Code with MCP
claude
```

### 4. Verify Setup

```bash
# Check system status
npm run check:dumps

# Test MCP servers
claude "/mcp"

# Test code generation
claude "Create a simple README.md in the target directory"
```

## 🔧 Configuration

### Environment Variables (.env)

```bash
# Project Configuration
PROJECT_NAME=My Awesome Project
PROJECT_VERSION=1.0.0

# n8n Configuration
N8N_HOST=http://localhost:5678
N8N_API_KEY=your_api_key_here
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password

# Code Generation Targets
TARGET_PROJECT_DIR=/c/Workspace/MyProject
FRONTEND_DIR=/c/Workspace/MyProject/frontend
BACKEND_DIR=/c/Workspace/MyProject/backend
SHARED_DIR=/c/Workspace/MyProject/shared

# Memory & Dumps
MEMORY_FILE=./project-memory.json
DUMP_DIR=./memory-dumps
BACKUP_DIR=./backups
AUTO_DUMP=true

# Automation
CRON_ENABLED=true
DAILY_DUMP_TIME=18:00
BACKUP_INTERVAL=4h
CLEANUP_DAYS=30

# Logging
LOG_LEVEL=info
LOG_FILE=./logs/project.log
```

### MCP Servers (.mcp.json)

```json
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
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${TARGET_PROJECT_DIR}"],
      "env": {}
    },
    "filesystem-current": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"],
      "env": {}
    }
  }
}
```

## 🎯 Usage Examples

### Project Management

```bash
# Add tasks and track progress
claude "Add todo: Implement user authentication, high priority, due tomorrow"
claude "Update project status to development with 75% progress"
claude "Record decision: Use PostgreSQL for database with rationale: better performance for complex queries"

# Get project insights
claude "Get project overview with details"
claude "What are my next recommended actions?"
claude "Show me all high priority pending tasks"
```

### Code Generation

```bash
# Frontend development
claude "Create a React UserProfile component with TypeScript in the frontend directory"
claude "Generate a responsive dashboard layout in the frontend/src/pages directory"

# Backend development  
claude "Create Express API routes for user CRUD operations in the backend directory"
claude "Generate Mongoose models for User and Product in the backend/models directory"

# Full-stack features
claude "Create a complete authentication system with React frontend, Express backend, and shared TypeScript types"
```

### n8n Workflow Integration

```bash
# Workflow documentation
claude "Show me available n8n nodes for HTTP requests"
claude "Create a workflow that triggers when a GitHub issue is created and sends a Slack notification"

# Workflow management
claude "List all n8n workflows and their status"
claude "Export the user-registration workflow to the workflows directory"
```

### Memory Management

```bash
# Manual dumps
claude "Create memory dump with type full"
claude "Create daily summary with metrics and tomorrow's plan"

# Search and insights
claude "Search memory for 'authentication' across all types"
claude "What decisions have we made about the database?"
claude "Show me recent learnings from the past week"
```

## 📜 Available Scripts

```bash
# n8n Management
npm run start                    # Start n8n server
npm run start:docker            # Start with Docker
npm run stop:docker             # Stop Docker containers

# Claude Code
npm run claude                   # Start Claude Code
npm run test:mcp                 # Test MCP server connections

# Memory & Dumps
npm run dump:manual             # Create manual memory dump
npm run dump:daily              # Create daily summary
npm run dump:shutdown           # Create shutdown dump

# System Management
npm run check:dumps             # Check system status
npm run setup:cron              # Setup automation (Linux/Mac)
npm run change-target           # Change target directory
npm run test:targets            # Test target directory access

# Logs
npm run logs:n8n               # View n8n logs
npm run logs:project           # View project logs
```

## 🤖 MCP Server Capabilities

### Memory Dump Server

- **Project Status Management**: Track phases, progress, milestones
- **Todo Management**: Add, update, complete tasks with priorities
- **Knowledge Base**: Record decisions, learnings, and insights
- **Auto-Dump System**: Automatic memory preservation on events
- **Search & Analytics**: Find information across project history

### Filesystem Servers

- **Multi-Directory Access**: Target different project areas
- **Organized Code Generation**: Frontend, backend, shared code
- **File Operations**: Read, write, search, and manage files
- **Project Structure**: Maintain organized directory hierarchies

## 🔄 Automation Features

### Daily Automation

- **6:00 PM**: Daily summary generation
- **11:30 PM**: Full memory dump and backup
- **Every 4 hours**: Incremental backups (workdays)
- **Weekly**: Comprehensive project reports

### Event-Triggered Dumps

- **Task Completion**: Auto-dump when tasks are marked complete
- **Milestone Achievement**: Comprehensive dumps for milestones
- **Shutdown Detection**: Emergency dumps on system shutdown
- **Error Recovery**: Backup creation on critical errors

### Cleanup & Maintenance

- **Log Rotation**: Automatic log file management
- **Backup Cleanup**: Remove backups older than 30 days
- **Memory Optimization**: Compress old dumps and backups
- **Health Monitoring**: System status checks and alerts

## 🛠️ Development Workflow

### 1. Daily Development

```bash
# Morning: Check project status
npm run check:dumps
claude "Get project overview and next actions"

# Development: Use AI assistance
claude "Add todo: Implement password reset feature"
claude "Create React component for password reset form"

# Evening: Review and dump
claude "Update project status with today's progress"
npm run dump:daily
```

### 2. Feature Development

```bash
# Planning
claude "Add upcoming feature: Real-time notifications with medium priority"
claude "Break down the implementation steps for real-time notifications"

# Implementation
claude "Create WebSocket server in backend for real-time features"
claude "Generate React hooks for WebSocket connection in frontend"

# Completion
claude "Complete task with notes: Real-time notifications implemented successfully"
claude "Record learning: WebSocket implementation requires careful connection management"
```

### 3. Team Collaboration

```bash
# Documentation
claude "Create API documentation for the authentication endpoints"
claude "Generate team update report for the past sprint"

# Knowledge Sharing
claude "Record decision: Use Redis for session storage with rationale and alternatives"
claude "Export project report for stakeholder meeting"
```

## 🚨 Troubleshooting

### Common Issues

#### MCP Servers Not Connecting
```bash
# Check MCP status
claude "/mcp"

# Restart Claude Code
# Exit and restart in project directory
cd /path/to/project
claude
```

#### n8n Not Accessible
```bash
# Check if n8n is running
curl http://localhost:5678/rest/health

# Restart n8n
npm run start
```

#### File Permission Issues
```bash
# Fix script permissions
chmod +x automation/*.sh
chmod +x mcp-servers/*.js

# Fix directory permissions
chmod 755 memory-dumps backups logs
```

#### Windows Path Issues
```bash
# Run Windows fix script
./automation/windows-fix.sh

# Convert paths manually
# C:\Workspace\Project -> /c/Workspace/Project
```

### Debug Information

```bash
# System check
./automation/check-dumps.sh

# View logs
tail -f logs/project.log
tail -f logs/dump.log

# Test individual components
node mcp-servers/memory-dump-server.js
curl http://localhost:5678/rest/health
```

## 📚 Documentation

### API Documentation
- **n8n API**: Access at `http://localhost:5678/rest/`
- **MCP Protocol**: [Model Context Protocol Docs](https://modelcontextprotocol.io/)
- **Claude Code**: [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)

### Configuration Files
- **`.env`**: Environment variables and settings
- **`.mcp.json`**: MCP server configuration
- **`package.json`**: Dependencies and scripts
- **Project Memory**: Stored in `project-memory.json`

### Generated Files
- **Memory Dumps**: Markdown files in `memory-dumps/`
- **Backups**: Compressed JSON in `backups/`
- **Logs**: Operation logs in `logs/`
- **Workflows**: n8n exports in `workflows/`

## 🤝 Contributing

### Adding New MCP Servers

1. Create server in `mcp-servers/` directory
2. Add configuration to `.mcp.json`
3. Update documentation
4. Test with Claude Code

### Extending Automation

1. Add scripts to `automation/` directory
2. Update `package.json` scripts
3. Document usage in README
4. Test on target platforms

### Improving Memory System

1. Extend memory dump server capabilities
2. Add new tool functions
3. Update auto-dump triggers
4. Enhance search and analytics

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help

1. **Check Documentation**: Review this README and inline comments
2. **Run Diagnostics**: Use `npm run check:dumps` and debug scripts
3. **Check Logs**: Review logs in `logs/` directory
4. **Community Resources**: 
   - [n8n Community](https://community.n8n.io/)
   - [Anthropic Discord](https://discord.gg/anthropic)
   - [MCP GitHub](https://github.com/modelcontextprotocol)

### Reporting Issues

When reporting issues, include:
- System information (OS, Node.js version)
- Error messages and logs
- Steps to reproduce
- Configuration files (without sensitive data)

### Feature Requests

Suggestions for improvements:
- New MCP server capabilities
- Additional automation features
- Better Windows compatibility
- Enhanced documentation

---

## 🎉 Acknowledgments

- **Anthropic** for Claude Code and MCP protocol
- **n8n** for the excellent workflow automation platform
- **Community contributors** for MCP servers and tools
- **Open source libraries** that make this integration possible

---

**Happy Coding! 🚀**

*Built with ❤️ using n8n, Claude Code, and MCP*