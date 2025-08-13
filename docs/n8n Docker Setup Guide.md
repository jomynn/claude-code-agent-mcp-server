# n8n Docker Setup Guide

## 1. Check Docker Installation

### Verify Docker is Available
```bash
# Check if Docker is installed
docker --version

# Check if Docker is running
docker ps

# If Docker not installed on Windows:
# Download from: https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe
```

### Install Docker (if needed)
```bash
# Windows: Download Docker Desktop
# https://docs.docker.com/desktop/install/windows-install/

# Or use winget
winget install Docker.DockerDesktop

# Linux (Ubuntu/Debian)
sudo apt update
sudo apt install docker.io docker-compose

# macOS
brew install docker docker-compose
```

## 2. Simple n8n Docker Setup

### Method 1: Quick Docker Run
```bash
# Run n8n with Docker (simplest method)
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n

# For Windows (PowerShell)
docker run -it --rm --name n8n -p 5678:5678 -v ${HOME}/.n8n:/home/node/.n8n n8nio/n8n

# For Windows (Git Bash/MINGW64)
docker run -it --rm --name n8n -p 5678:5678 -v /c/Users/$USER/.n8n:/home/node/.n8n n8nio/n8n
```

### Method 2: Docker Compose (Recommended)
```bash
# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_secure_password_123
      - WEBHOOK_URL=http://localhost:5678/
      - N8N_API_KEY=n8n_api_key_your_secret_key_here
      - DB_TYPE=sqlite
      - N8N_ENCRYPTION_KEY=your_encryption_key_change_this
    volumes:
      - ./n8n_data:/home/node/.n8n
      - ./workflows:/home/node/workflows
    networks:
      - n8n_network

networks:
  n8n_network:
    driver: bridge

volumes:
  n8n_data:
EOF
```

### Method 3: Docker Compose with Database
```bash
# Advanced setup with PostgreSQL
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  postgres:
    image: postgres:13
    container_name: n8n_postgres
    restart: unless-stopped
    environment:
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=n8n_password
      - POSTGRES_DB=n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - n8n_network

  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your_secure_password_123
      - WEBHOOK_URL=http://localhost:5678/
      - N8N_API_KEY=n8n_api_key_your_secret_key_here
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8n_password
      - N8N_ENCRYPTION_KEY=your_encryption_key_change_this
    volumes:
      - ./n8n_data:/home/node/.n8n
      - ./workflows:/home/node/workflows
    depends_on:
      - postgres
    networks:
      - n8n_network

networks:
  n8n_network:
    driver: bridge

volumes:
  postgres_data:
  n8n_data:
EOF
```

## 3. Windows-Specific Docker Setup

### Create Windows-Compatible docker-compose.yml
```bash
# For Windows users (MINGW64/Git Bash)
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=mySecurePassword123
      - WEBHOOK_URL=http://localhost:5678/
      - N8N_API_KEY=your_api_key_here_change_this
      - DB_TYPE=sqlite
      - N8N_ENCRYPTION_KEY=myEncryptionKey123Change
    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/home/node/workflows
    networks:
      - n8n_network

networks:
  n8n_network:
    driver: bridge

volumes:
  n8n_data:
EOF
```

## 4. Start n8n with Docker

### Using Docker Compose
```bash
# Start n8n in background
docker-compose up -d

# Check if it's running
docker-compose ps

# View logs
docker-compose logs -f n8n

# Stop n8n
docker-compose down
```

### Using Direct Docker Commands
```bash
# Start n8n
docker run -d \
  --name n8n \
  -p 5678:5678 \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=mypassword \
  -e N8N_API_KEY=myapikey \
  -v n8n_data:/home/node/.n8n \
  n8nio/n8n

# Check status
docker ps | grep n8n

# View logs
docker logs n8n

# Stop n8n
docker stop n8n
docker rm n8n
```

## 5. Test n8n Docker Setup

### Verify n8n is Running
```bash
# Test health endpoint
curl http://localhost:5678/rest/health

# Should return: {"status":"ok"}

# Test API access
curl -H "X-N8N-API-KEY: your_api_key_here" \
     http://localhost:5678/rest/workflows

# Should return: [] (empty array if no workflows)
```

### Access n8n Interface
```bash
# Open in browser
# URL: http://localhost:5678
# Username: admin
# Password: (from docker-compose.yml)
```

## 6. Update Project Configuration

### Update .env File
```bash
# Add Docker-specific settings to .env
cat >> .env << 'EOF'

# n8n Docker Configuration
N8N_HOST=http://localhost:5678
N8N_API_KEY=your_api_key_here_change_this
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=mySecurePassword123
N8N_DOCKER=true
EOF
```

### Update package.json Scripts
```bash
# Add Docker scripts to package.json
cat > package.json << 'EOF'
{
  "name": "my-n8n-mcp-project",
  "version": "1.0.0",
  "scripts": {
    "start": "docker-compose up -d",
    "stop": "docker-compose down",
    "logs": "docker-compose logs -f n8n",
    "restart": "docker-compose restart n8n",
    "status": "docker-compose ps",
    "shell": "docker exec -it n8n /bin/sh",
    "claude": "claude",
    "test:mcp": "claude \"/mcp\"",
    "check:dumps": "bash ./automation/check-dumps.sh"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "latest"
  }
}
EOF
```

### Update MCP Configuration for Docker
```bash
# No changes needed to .mcp.json for Docker
# The MCP servers connect to n8n via HTTP API
cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "memory-dump": {
      "command": "node",
      "args": ["./mcp-servers/memory-dump-server.js"],
      "env": {
        "MEMORY_FILE": "./project-memory.json",
        "DUMP_DIR": "./memory-dumps",
        "N8N_HOST": "http://localhost:5678"
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
```

## 7. Complete Docker Setup Script

### Automated Setup Script
```bash
#!/bin/bash

# n8n Docker Setup Script
echo "🐳 Setting up n8n with Docker..."

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker Desktop first."
    echo "   Download: https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
    exit 1
fi

# Check if Docker is running
if ! docker ps &> /dev/null; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

echo "✅ Docker is available and running"

# Create project directories
mkdir -p {workflows,n8n_data,logs,memory-dumps,backups,mcp-servers}

# Generate secure passwords
N8N_PASSWORD=$(openssl rand -base64 12 | tr -d '=+/' | cut -c1-16)
N8N_API_KEY=$(openssl rand -hex 32)
ENCRYPTION_KEY=$(openssl rand -base64 32 | tr -d '=+/' | cut -c1-32)

# Create docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=0.0.0.0
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD
      - WEBHOOK_URL=http://localhost:5678/
      - N8N_API_KEY=$N8N_API_KEY
      - DB_TYPE=sqlite
      - N8N_ENCRYPTION_KEY=$ENCRYPTION_KEY
    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/home/node/workflows
    networks:
      - n8n_network

networks:
  n8n_network:
    driver: bridge

volumes:
  n8n_data:
EOF

# Update .env file
cat >> .env << EOF

# n8n Docker Configuration
N8N_HOST=http://localhost:5678
N8N_API_KEY=$N8N_API_KEY
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=$N8N_PASSWORD
N8N_DOCKER=true
ENCRYPTION_KEY=$ENCRYPTION_KEY
EOF

# Start n8n
echo "🚀 Starting n8n with Docker..."
docker-compose up -d

# Wait for n8n to start
echo "⏳ Waiting for n8n to be ready..."
for i in {1..30}; do
    if curl -s --connect-timeout 2 http://localhost:5678/rest/health >/dev/null 2>&1; then
        echo "✅ n8n is running!"
        break
    fi
    echo -n "."
    sleep 2
done

echo ""
echo "🎉 n8n Docker Setup Complete!"
echo ""
echo "📊 Access Information:"
echo "   🌐 URL: http://localhost:5678"
echo "   👤 Username: admin"
echo "   🔑 Password: $N8N_PASSWORD"
echo "   🗝️  API Key: $N8N_API_KEY"
echo ""
echo "📋 Useful Commands:"
echo "   npm start        # Start n8n"
echo "   npm stop         # Stop n8n"
echo "   npm run logs     # View logs"
echo "   npm run status   # Check status"
echo ""
echo "🧪 Test Commands:"
echo "   curl http://localhost:5678/rest/health"
echo "   claude \"/mcp\""
```

## 8. Troubleshooting Docker Issues

### Common Docker Problems

#### Docker Desktop Not Running
```bash
# Start Docker Desktop manually
# Or restart Docker service (Linux)
sudo systemctl restart docker
```

#### Port 5678 Already in Use
```bash
# Check what's using the port
netstat -ano | findstr 5678

# Use different port
docker run -p 5679:5678 n8nio/n8n
```

#### Permission Issues (Linux)
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Or use sudo
sudo docker-compose up -d
```

#### Memory Issues
```bash
# Increase Docker memory limit in Docker Desktop settings
# Or add memory limits to docker-compose.yml
services:
  n8n:
    mem_limit: 1g
    memswap_limit: 1g
```

## 9. Quick Start Commands

```bash
# 1. Create docker-compose.yml (use script above)

# 2. Start n8n
docker-compose up -d

# 3. Check status
docker-compose ps
curl http://localhost:5678/rest/health

# 4. Test MCP connection
claude
> /mcp

# 5. Test n8n access
> "Check if n8n is accessible at localhost:5678"
```

## 10. Integration with MCP

Once n8n is running with Docker, your MCP servers will connect to it via HTTP API. No changes needed to MCP configuration - it will work the same way whether n8n runs via npm or Docker.

The Docker approach is actually better because:
- ✅ Isolated environment
- ✅ Easy to start/stop
- ✅ Consistent across different systems
- ✅ No global npm installation conflicts
- ✅ Easy backups (just copy volumes)

Use Docker Compose method for the best experience!