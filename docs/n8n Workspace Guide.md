# n8n Workspace Guide

## What is a Workspace in n8n?

A **workspace** in n8n is an organizational unit that contains:
- **Workflows** (automation sequences)
- **Credentials** (API keys, database connections)
- **Users and permissions** (team access control)
- **Variables** (reusable configuration values)
- **Templates** (workflow blueprints)

Think of it as a **project container** where you organize related automations.

## Types of n8n Workspaces

### 1. Local/Self-Hosted Workspace
- **Single workspace** per n8n instance
- All workflows in one workspace
- Full control over data and infrastructure
- No workspace switching needed

### 2. n8n Cloud Workspaces
- **Multiple workspaces** per account
- Separate environments (dev, staging, prod)
- Team collaboration features
- Workspace-specific billing

### 3. Enterprise Workspaces
- **Advanced workspace management**
- Role-based access control
- Audit logs and compliance
- SSO integration

## Setting Up Your n8n Workspace

### For Docker Installation (Your Current Setup)

Since you're using Docker, you have a **single workspace** that contains all your workflows.

#### Access Your n8n Workspace:
```bash
# Start your n8n Docker container
npm run start  # or docker-compose up -d

# Access the workspace
# URL: http://localhost:5678
# Username: admin
# Password: (from your .env file)
```

#### Workspace Structure:
```
Your n8n Workspace
├── 📄 Workflows
│   ├── Workflow 1
│   ├── Workflow 2
│   └── ...
├── 🔑 Credentials
│   ├── API Keys
│   ├── Database Connections
│   └── OAuth Tokens
├── 🔧 Settings
│   ├── Variables
│   ├── Users
│   └── Webhooks
└── 📊 Executions
    ├── Success logs
    ├── Error logs
    └── Performance data
```

### For n8n Cloud

If you want multiple workspaces, you'd need n8n Cloud:

1. **Sign up at [n8n.cloud](https://n8n.cloud)**
2. **Create workspaces:**
   - Development workspace
   - Staging workspace  
   - Production workspace
3. **Invite team members**
4. **Configure workspace settings**

## Workspace Management

### Creating Workflows in Your Workspace

#### 1. Access n8n Interface
```bash
# Open in browser
http://localhost:5678

# Login with credentials from .env:
# Username: admin
# Password: your_password_from_env
```

#### 2. Create Your First Workflow
```markdown
1. Click "New Workflow"
2. Add a trigger node (e.g., "Manual Trigger")
3. Add action nodes (e.g., "HTTP Request", "Set")
4. Connect the nodes
5. Save the workflow
6. Test execution
```

#### 3. Organize Workflows
```markdown
- Use descriptive names: "Send Daily Report Email"
- Add tags: #automation, #reporting, #daily
- Create folders (in n8n Cloud)
- Use workflow templates
```

### Workspace Configuration

#### Environment Variables for Your Workspace
```bash
# In your .env file
N8N_HOST=http://localhost:5678
N8N_PORT=5678
N8N_PROTOCOL=http

# Workspace settings
WEBHOOK_URL=http://localhost:5678/
N8N_EDITOR_BASE_URL=http://localhost:5678/

# Security
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password

# Database (workspace data storage)
DB_TYPE=sqlite
DB_SQLITE_DATABASE=.n8n/database.sqlite
```

#### Workspace Backup
```bash
# Backup your workspace data
docker exec n8n cp -r /home/node/.n8n /backup
# Or with volumes:
docker cp n8n:/home/node/.n8n ./workspace-backup
```

## Common n8n Workspace Use Cases

### 1. Development Workspace
```markdown
Purpose: Testing and developing workflows
Contents:
- Experimental workflows
- Test credentials (sandbox APIs)
- Development webhooks
- Debug executions
```

### 2. Production Workspace  
```markdown
Purpose: Live automation workflows
Contents:
- Stable, tested workflows
- Production credentials
- Live webhooks
- Monitoring and alerts
```

### 3. Team Collaboration Workspace
```markdown
Purpose: Shared team automations
Contents:
- Shared workflows
- Team credentials
- Collaborative templates
- Role-based permissions
```

## Workspace Best Practices

### 1. Workflow Organization
```markdown
✅ Good Practices:
- Use clear, descriptive names
- Add documentation in workflow notes
- Group related workflows with tags
- Create workflow templates for common patterns
- Use consistent naming conventions

❌ Avoid:
- Generic names like "Workflow 1"
- No documentation
- Mixing test and production workflows
- Hardcoded values (use variables instead)
```

### 2. Credential Management
```markdown
✅ Security Best Practices:
- Use environment variables for sensitive data
- Rotate credentials regularly
- Use least-privilege access
- Separate dev/staging/prod credentials
- Enable credential encryption

❌ Security Risks:
- Hardcoding API keys in workflows
- Sharing production credentials
- Using overprivileged accounts
- No credential rotation
```

### 3. Workflow Development Lifecycle
```markdown
1. Design → Plan workflow logic
2. Develop → Create in development workspace
3. Test → Validate with test data
4. Review → Code/logic review
5. Deploy → Move to production workspace
6. Monitor → Track execution and errors
7. Maintain → Update and improve
```

## Workspace Integration with MCP

### Connecting Your MCP Setup to n8n Workspace

Since you have both n8n and MCP running, here's how they work together:

#### 1. MCP Memory Tracking n8n Workflows
```bash
# In Claude Code, track your n8n workspace
> "Add todo: Create customer onboarding workflow in n8n workspace"
> "Record decision: Use n8n workspace for all automation workflows"
> "Add learning: n8n workspace contains all our automation logic"
```

#### 2. n8n Workflows Updating MCP Memory
```markdown
Create n8n workflows that:
- Update project status in MCP memory
- Log completed tasks
- Create workflow execution summaries
- Send daily reports to MCP memory dump
```

#### 3. Automated Documentation
```bash
# Create workflows that document themselves
> "Create n8n workflow that automatically updates our MCP memory with workflow execution statistics"
```

## Practical Workspace Setup for Your Project

### Step 1: Access Your Workspace
```bash
# Start n8n (if not running)
npm run start

# Open workspace
http://localhost:5678

# Login with your credentials
```

### Step 2: Create Your First Workflow
```markdown
1. Click "New Workflow"
2. Name it: "MCP Integration Test"
3. Add nodes:
   - Manual Trigger
   - HTTP Request (to test MCP memory API)
   - Set (to format response)
4. Save and test
```

### Step 3: Organize Your Workspace
```markdown
Create workflow categories:
- 📊 Data Processing
- 🔔 Notifications  
- 🔄 Integrations
- 📝 Reporting
- 🛠️ Utilities
```

### Step 4: Connect to Your MCP System
```markdown
Create workflows that:
- Read from your project-memory.json
- Update todos and status
- Create automated dumps
- Send notifications about project progress
```

## Example Workflows for Your Workspace

### 1. Daily Status Report Workflow
```markdown
Trigger: Schedule (daily at 6 PM)
Actions:
1. Read project-memory.json
2. Format status report
3. Send email/Slack notification
4. Update MCP memory with report sent
```

### 2. Todo Completion Notification
```markdown
Trigger: Webhook (when todo completed)
Actions:
1. Receive todo completion data
2. Update project statistics
3. Send team notification
4. Create memory dump
```

### 3. Error Monitoring Workflow
```markdown
Trigger: Schedule (every 15 minutes)
Actions:
1. Check system health
2. Read error logs
3. Alert if issues found
4. Update monitoring dashboard
```

## Workspace Monitoring and Analytics

### Track Workspace Performance
```bash
# Monitor workflow executions
# View in n8n interface: Executions tab

# Check execution statistics
# Success rate, error rate, execution time

# Set up alerts for failed workflows
# Configure webhook notifications
```

### Workspace Metrics
```markdown
Key metrics to track:
- Total workflows: X
- Active workflows: Y  
- Daily executions: Z
- Success rate: N%
- Average execution time: T seconds
- Error frequency: E/day
```

## Workspace Backup and Recovery

### Backup Your Workspace
```bash
# Method 1: Export workflows individually
# From n8n interface: Settings > Export

# Method 2: Backup entire workspace data
docker exec n8n cp -r /home/node/.n8n ./workspace-backup

# Method 3: Database backup
cp .n8n/database.sqlite ./workspace-backup/

# Method 4: Full container backup
docker commit n8n n8n-workspace-backup:$(date +%Y%m%d)
```

### Restore Workspace
```bash
# Restore from backup
docker cp ./workspace-backup n8n:/home/node/.n8n

# Or restore database
cp ./workspace-backup/database.sqlite .n8n/

# Restart n8n
docker-compose restart n8n
```

## Your Workspace is Ready!

Your current Docker setup provides a complete n8n workspace where you can:

✅ **Create unlimited workflows**
✅ **Store credentials securely** 
✅ **Manage executions and logs**
✅ **Integrate with your MCP system**
✅ **Backup and restore data**
✅ **Monitor performance**

**Next Steps:**
1. Access http://localhost:5678
2. Create your first workflow
3. Test the integration with your MCP memory system
4. Set up monitoring and alerts
5. Build automation workflows for your project

Your workspace is essentially your **automation command center** where all your n8n workflows live and run!