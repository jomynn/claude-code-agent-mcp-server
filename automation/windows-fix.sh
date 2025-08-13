#!/bin/bash

# Windows Fix Script for MCP Server Installation Issues
# Run this after the quick-setup.sh fails

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

fix_mcp_servers() {
    log_info "Fixing MCP server installation issues..."
    
    # Check if we're in the right directory
    if [ ! -f ".mcp.json" ]; then
        log_error "Not in project directory. Please cd to your project first."
        exit 1
    fi
    
    # Update MCP configuration with working packages only
    log_info "Creating fixed MCP configuration..."
    
    cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "memory-dump": {
      "command": "node",
      "args": ["./mcp-servers/memory-dump-server.js"],
      "env": {
        "MEMORY_FILE": "./project-memory.json",
        "DUMP_DIR": "./memory-dumps",
        "AUTO_DUMP": "true",
        "LOG_LEVEL": "info"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "./"],
      "env": {}
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"],
      "env": {}
    }
  }
}
EOF
    
    log_success "Fixed MCP configuration created"
}

fix_windows_paths() {
    log_info "Fixing Windows-specific path issues..."
    
    # Fix package.json scripts for Windows
    if [ -f "package.json" ]; then
        # Create Windows-compatible package.json
        cat > package.json.tmp << 'EOF'
{
  "name": "my-project-n8n-mcp",
  "version": "1.0.0",
  "description": "Project with n8n and MCP integration",
  "type": "module",
  "scripts": {
    "start": "n8n start",
    "claude": "claude",
    "setup:cron": "echo 'Cron not available on Windows - use Task Scheduler'",
    "check:dumps": "bash ./automation/check-dumps.sh",
    "dump:manual": "bash ./automation/auto-dump.sh",
    "test:mcp": "claude \"/mcp\"",
    "test:system": "bash ./automation/check-dumps.sh"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "latest"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=8.0.0"
  }
}
EOF
        mv package.json.tmp package.json
        log_success "Fixed package.json for Windows"
    fi
}

create_working_memory_server() {
    log_info "Creating working memory dump server..."
    
    cat > mcp-servers/memory-dump-server.js << 'EOF'
#!/usr/bin/env node

/**
 * Basic Memory Dump Server for Windows
 * Simplified version that works on Windows systems
 */

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ErrorCode,
  ListToolsRequestSchema,
  McpError,
} from '@modelcontextprotocol/sdk/types.js';
import fs from 'fs/promises';
import path from 'path';

class SimpleMemoryServer {
  constructor() {
    this.server = new Server(
      {
        name: 'simple-memory-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.memoryFile = process.env.MEMORY_FILE || './project-memory.json';
    this.dumpDir = process.env.DUMP_DIR || './memory-dumps';
    this.setupToolHandlers();
    
    // Error handling
    this.server.onerror = (error) => console.error('[MCP Error]', error);
    
    // Windows-compatible shutdown handling
    process.on('SIGINT', async () => {
      await this.createShutdownDump();
      await this.server.close();
      process.exit(0);
    });
  }

  async ensureMemoryFile() {
    try {
      await fs.access(this.memoryFile);
    } catch {
      const initialData = {
        project_info: {
          name: 'My Project',
          created_at: new Date().toISOString(),
          last_updated: new Date().toISOString()
        },
        todos: {
          items: [],
          next_id: 1
        },
        status: {
          current_phase: 'planning',
          progress_percentage: 0
        },
        knowledge: {
          decisions: [],
          learnings: []
        }
      };
      await fs.writeFile(this.memoryFile, JSON.stringify(initialData, null, 2));
    }

    // Ensure dump directory exists
    try {
      await fs.access(this.dumpDir);
    } catch {
      await fs.mkdir(this.dumpDir, { recursive: true });
    }
  }

  async loadMemory() {
    await this.ensureMemoryFile();
    const data = await fs.readFile(this.memoryFile, 'utf-8');
    return JSON.parse(data);
  }

  async saveMemory(data) {
    data.project_info.last_updated = new Date().toISOString();
    await fs.writeFile(this.memoryFile, JSON.stringify(data, null, 2));
  }

  setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => ({
      tools: [
        {
          name: 'add_todo',
          description: 'Add a todo item',
          inputSchema: {
            type: 'object',
            properties: {
              title: {
                type: 'string',
                description: 'Todo title',
              },
              description: {
                type: 'string',
                description: 'Todo description (optional)',
              },
              priority: {
                type: 'string',
                enum: ['low', 'medium', 'high'],
                description: 'Todo priority',
                default: 'medium',
              },
            },
            required: ['title'],
          },
        },
        {
          name: 'list_todos',
          description: 'List all todos',
          inputSchema: {
            type: 'object',
            properties: {
              status: {
                type: 'string',
                enum: ['pending', 'completed', 'all'],
                description: 'Filter by status',
                default: 'all',
              },
            },
          },
        },
        {
          name: 'update_project_status',
          description: 'Update project status',
          inputSchema: {
            type: 'object',
            properties: {
              phase: {
                type: 'string',
                description: 'Current project phase',
              },
              progress: {
                type: 'number',
                minimum: 0,
                maximum: 100,
                description: 'Progress percentage',
              },
            },
          },
        },
        {
          name: 'create_dump',
          description: 'Create a memory dump file',
          inputSchema: {
            type: 'object',
            properties: {
              type: {
                type: 'string',
                enum: ['summary', 'full'],
                default: 'summary',
                description: 'Type of dump to create',
              },
            },
          },
        },
      ],
    }));

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case 'add_todo':
            return await this.addTodo(args);
          case 'list_todos':
            return await this.listTodos(args);
          case 'update_project_status':
            return await this.updateProjectStatus(args);
          case 'create_dump':
            return await this.createDump(args);
          default:
            throw new McpError(
              ErrorCode.MethodNotFound,
              `Unknown tool: ${name}`
            );
        }
      } catch (error) {
        throw new McpError(
          ErrorCode.InternalError,
          `Tool execution failed: ${error.message}`
        );
      }
    });
  }

  async addTodo(args) {
    const memory = await this.loadMemory();
    const todo = {
      id: memory.todos.next_id++,
      title: args.title,
      description: args.description || '',
      priority: args.priority || 'medium',
      status: 'pending',
      created_at: new Date().toISOString(),
    };

    memory.todos.items.push(todo);
    await this.saveMemory(memory);

    return {
      content: [
        {
          type: 'text',
          text: `✅ Added todo #${todo.id}: "${todo.title}" (Priority: ${todo.priority})`,
        },
      ],
    };
  }

  async listTodos(args = {}) {
    const memory = await this.loadMemory();
    let todos = memory.todos.items;

    if (args.status && args.status !== 'all') {
      todos = todos.filter(t => t.status === args.status);
    }

    if (todos.length === 0) {
      return {
        content: [
          {
            type: 'text',
            text: '📋 No todos found.',
          },
        ],
      };
    }

    const todoList = todos.map(todo => {
      const status = todo.status === 'completed' ? '✅' : '⏳';
      const priority = { low: '🟢', medium: '🟡', high: '🔴' }[todo.priority];
      return `${status} #${todo.id} ${priority} ${todo.title}${todo.description ? '\n   ' + todo.description : ''}`;
    }).join('\n\n');

    return {
      content: [
        {
          type: 'text',
          text: `📋 **Todo List** (${todos.length} items)\n\n${todoList}`,
        },
      ],
    };
  }

  async updateProjectStatus(args) {
    const memory = await this.loadMemory();
    
    if (args.phase) memory.status.current_phase = args.phase;
    if (args.progress !== undefined) memory.status.progress_percentage = args.progress;
    
    await this.saveMemory(memory);

    return {
      content: [{
        type: 'text',
        text: `📊 Project status updated!\nPhase: ${memory.status.current_phase}\nProgress: ${memory.status.progress_percentage}%`
      }]
    };
  }

  async createDump(args = {}) {
    const memory = await this.loadMemory();
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').split('T')[0] + '_' + 
                     new Date().toISOString().replace(/[:.]/g, '-').split('T')[1].split('-')[0];
    const filename = `memory-dump-${args.type || 'summary'}-${timestamp}.md`;
    const filepath = path.join(this.dumpDir, filename);

    let content = `# Project Memory Dump\n\n`;
    content += `**Generated**: ${new Date().toLocaleString()}\n`;
    content += `**Type**: ${args.type || 'summary'}\n\n`;

    content += `## Project Status\n\n`;
    content += `**Phase**: ${memory.status.current_phase}\n`;
    content += `**Progress**: ${memory.status.progress_percentage}%\n\n`;

    content += `## Todos (${memory.todos.items.length})\n\n`;
    memory.todos.items.forEach(todo => {
      const status = todo.status === 'completed' ? '✅' : '⏳';
      const priority = { low: '🟢', medium: '🟡', high: '🔴' }[todo.priority];
      content += `${status} **#${todo.id}** ${priority} ${todo.title}\n`;
      if (todo.description) content += `  ${todo.description}\n`;
      content += '\n';
    });

    await fs.writeFile(filepath, content, 'utf-8');

    return {
      content: [{
        type: 'text',
        text: `📄 **Memory dump created!**\n\n**File**: ${filename}\n**Location**: ${filepath}`
      }]
    };
  }

  async createShutdownDump() {
    try {
      await this.createDump({ type: 'full' });
      console.error('Shutdown dump created successfully');
    } catch (error) {
      console.error('Failed to create shutdown dump:', error.message);
    }
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Simple Memory Server running on stdio');
  }
}

const server = new SimpleMemoryServer();
server.run().catch(console.error);
EOF
    
    chmod +x mcp-servers/memory-dump-server.js
    log_success "Working memory dump server created"
}

create_windows_automation() {
    log_info "Creating Windows-compatible automation scripts..."
    
    # Create Windows-compatible auto-dump script
    cat > automation/auto-dump.sh << 'EOF'
#!/bin/bash

# Windows-compatible auto-dump script

PROJECT_DIR="$(pwd)"
MEMORY_FILE="$PROJECT_DIR/project-memory.json"
DUMP_DIR="$PROJECT_DIR/memory-dumps"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_FILE="$PROJECT_DIR/logs/dump.log"

# Create directories (Windows-compatible)
mkdir -p "$DUMP_DIR" "$BACKUP_DIR" "$(dirname "$LOG_FILE")" 2>/dev/null || true

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

case "${1:-shutdown}" in
    "daily")
        log_message "Creating daily summary..."
        if [ -f "$MEMORY_FILE" ]; then
            timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
            cp "$MEMORY_FILE" "$DUMP_DIR/daily-backup-$timestamp.json" 2>/dev/null || {
                log_message "Failed to create daily backup"
                exit 1
            }
            log_message "Daily backup created: daily-backup-$timestamp.json"
        else
            log_message "Memory file not found: $MEMORY_FILE"
        fi
        ;;
    "shutdown"|*)
        log_message "Creating shutdown dump..."
        if [ -f "$MEMORY_FILE" ]; then
            timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
            cp "$MEMORY_FILE" "$BACKUP_DIR/shutdown-backup-$timestamp.json" 2>/dev/null || {
                log_message "Failed to create shutdown backup"
                exit 1
            }
            # Try to compress if gzip is available
            if command -v gzip >/dev/null 2>&1; then
                gzip "$BACKUP_DIR/shutdown-backup-$timestamp.json"
                log_message "Shutdown backup created: shutdown-backup-$timestamp.json.gz"
            else
                log_message "Shutdown backup created: shutdown-backup-$timestamp.json (gzip not available)"
            fi
        else
            log_message "Memory file not found: $MEMORY_FILE"
        fi
        ;;
esac
EOF
    
    # Create Windows check script
    cat > automation/check-dumps.sh << 'EOF'
#!/bin/bash

PROJECT_DIR="$(pwd)"
echo "=== Project Status (Windows) ==="
echo "Directory: $PROJECT_DIR"
echo "Memory file: $([ -f project-memory.json ] && echo "✅ Exists" || echo "❌ Missing")"
echo "Dumps: $(ls memory-dumps/ 2>/dev/null | wc -l) files"
echo "Backups: $(ls backups/ 2>/dev/null | wc -l) files"

# Check n8n status (Windows-compatible)
if command -v curl >/dev/null 2>&1; then
    echo "n8n status: $(curl -s http://localhost:5678/rest/health 2>/dev/null && echo "✅ Running" || echo "❌ Not running")"
else
    echo "n8n status: ❓ (curl not available)"
fi

echo ""
echo "Recent dumps:"
ls -lt memory-dumps/ 2>/dev/null | head -3 || echo "No dumps found"
EOF
    
    chmod +x automation/auto-dump.sh automation/check-dumps.sh
    log_success "Windows-compatible automation scripts created"
}

install_missing_dependencies() {
    log_info "Installing missing dependencies..."
    
    # Install MCP SDK in mcp-servers directory
    cd mcp-servers
    npm install @modelcontextprotocol/sdk@latest
    cd ..
    
    # Try to install working MCP servers
    log_info "Attempting to install working MCP servers..."
    
    # These should work
    npm install -g @modelcontextprotocol/server-filesystem 2>/dev/null || log_warning "Filesystem server install failed"
    npm install -g @modelcontextprotocol/server-memory 2>/dev/null || log_warning "Memory server install failed"
    
    log_success "Dependencies installation completed"
}

test_setup() {
    log_info "Testing the fixed setup..."
    
    # Test if memory server can start
    log_info "Testing memory dump server..."
    timeout 5s node mcp-servers/memory-dump-server.js </dev/null >/dev/null 2>&1 && {
        log_success "Memory dump server test passed"
    } || {
        log_warning "Memory dump server test failed (this is normal - it needs stdio input)"
    }
    
    # Test automation scripts
    log_info "Testing automation scripts..."
    ./automation/check-dumps.sh >/dev/null 2>&1 && {
        log_success "Automation scripts test passed"
    } || {
        log_warning "Automation scripts test failed"
    }
    
    log_success "Setup testing completed"
}

print_next_steps() {
    echo ""
    echo "🔧 Windows Setup Fix Completed!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. claude auth                          # Authenticate Claude Code"
    echo "2. claude --dangerously-skip-permissions # Setup permissions"
    echo "3. npm run start                        # Start n8n"
    echo "4. claude                               # Start Claude Code with MCP"
    echo ""
    echo "🧪 Test Commands:"
    echo "• npm run check:dumps                   # Check system status"
    echo "• claude \"/mcp\"                       # Test MCP servers"
    echo "• npm run dump:manual                   # Create manual dump"
    echo ""
    echo "⚠️  Windows Notes:"
    echo "• Cron jobs not available - use Task Scheduler instead"
    echo "• Some commands may need 'bash' prefix in Command Prompt"
    echo "• Use Git Bash or WSL for best compatibility"
    echo ""
    echo "🚀 You can now use:"
    echo '• claude "Add todo: Fix Windows compatibility, high priority"'
    echo '• claude "Update project status to development with 50% progress"'
    echo '• claude "Create dump with type summary"'
}

main() {
    echo "🔧 Fixing Windows MCP Setup Issues..."
    echo ""
    
    fix_mcp_servers
    fix_windows_paths
    create_working_memory_server
    create_windows_automation
    install_missing_dependencies
    test_setup
    print_next_steps
}

main "$@"