#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import crypto from 'crypto';
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

console.error('Memory Dump Server starting with authentication...');

// Authentication configuration
const AUTH_CONFIG = {
  tokenFile: path.join(__dirname, '..', 'config', 'auth-tokens.json'),
  requireAuth: process.env.MCP_REQUIRE_AUTH === 'true',
  tokenExpiry: parseInt(process.env.MCP_TOKEN_EXPIRY || '86400000'), // 24 hours default
};

// In-memory storage for authenticated sessions
const authenticatedSessions = new Map();

// Load or create auth tokens
async function loadAuthTokens() {
  try {
    await fs.mkdir(path.dirname(AUTH_CONFIG.tokenFile), { recursive: true });
    const data = await fs.readFile(AUTH_CONFIG.tokenFile, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    const defaultTokens = {
      tokens: [
        {
          id: crypto.randomUUID(),
          token: crypto.randomBytes(32).toString('hex'),
          name: 'default',
          createdAt: new Date().toISOString(),
          active: true
        }
      ]
    };
    await fs.writeFile(AUTH_CONFIG.tokenFile, JSON.stringify(defaultTokens, null, 2));
    console.error('Created default auth token:', defaultTokens.tokens[0].token);
    return defaultTokens;
  }
}

// Verify authentication token
function verifyToken(token) {
  if (!AUTH_CONFIG.requireAuth) return { authenticated: true, user: 'anonymous' };
  
  const session = authenticatedSessions.get(token);
  if (session && Date.now() - session.timestamp < AUTH_CONFIG.tokenExpiry) {
    session.timestamp = Date.now(); // Refresh session
    return { authenticated: true, user: session.user };
  }
  
  return { authenticated: false };
}

// Authentication middleware
async function authenticate(token, authTokens) {
  if (!AUTH_CONFIG.requireAuth) return { success: true, user: 'anonymous' };
  
  const validToken = authTokens.tokens.find(t => t.active && t.token === token);
  if (validToken) {
    const sessionId = crypto.randomUUID();
    authenticatedSessions.set(sessionId, {
      user: validToken.name,
      timestamp: Date.now(),
      tokenId: validToken.id
    });
    return { success: true, sessionId, user: validToken.name };
  }
  
  return { success: false };
}

const authTokens = await loadAuthTokens();

const server = new Server(
  { name: 'memory-dump-server', version: '1.0.0' },
  { capabilities: { tools: {} } }
);

// Tool definitions
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'authenticate',
      description: 'Authenticate with the MCP server',
      inputSchema: {
        type: 'object',
        properties: {
          token: { type: 'string', description: 'Authentication token' }
        },
        required: ['token']
      }
    },
    {
      name: 'add_todo',
      description: 'Add a todo item (requires authentication)',
      inputSchema: {
        type: 'object',
        properties: {
          title: { type: 'string', description: 'Todo title' },
          sessionId: { type: 'string', description: 'Session ID from authentication' }
        },
        required: ['title']
      }
    },
    {
      name: 'generate_token',
      description: 'Generate a new authentication token (admin only)',
      inputSchema: {
        type: 'object',
        properties: {
          name: { type: 'string', description: 'Name for the token' },
          adminToken: { type: 'string', description: 'Admin token for authorization' }
        },
        required: ['name', 'adminToken']
      }
    }
  ]
}));

server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;
  
  // Handle authentication
  if (name === 'authenticate') {
    const authResult = await authenticate(args.token, authTokens);
    if (authResult.success) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            success: true,
            message: `Authenticated as ${authResult.user}`,
            sessionId: authResult.sessionId
          })
        }]
      };
    }
    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          success: false,
          message: 'Invalid authentication token'
        })
      }]
    };
  }
  
  // Handle token generation (admin only)
  if (name === 'generate_token') {
    const adminToken = authTokens.tokens.find(t => t.name === 'default' && t.active);
    if (args.adminToken !== adminToken?.token) {
      return {
        content: [{
          type: 'text',
          text: JSON.stringify({
            success: false,
            message: 'Invalid admin token'
          })
        }]
      };
    }
    
    const newToken = {
      id: crypto.randomUUID(),
      token: crypto.randomBytes(32).toString('hex'),
      name: args.name,
      createdAt: new Date().toISOString(),
      active: true
    };
    
    authTokens.tokens.push(newToken);
    await fs.writeFile(AUTH_CONFIG.tokenFile, JSON.stringify(authTokens, null, 2));
    
    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          success: true,
          token: newToken.token,
          message: `Token generated for ${args.name}`
        })
      }]
    };
  }
  
  // Handle authenticated tools
  if (name === 'add_todo') {
    // Check authentication if required
    if (AUTH_CONFIG.requireAuth && args.sessionId) {
      const authStatus = verifyToken(args.sessionId);
      if (!authStatus.authenticated) {
        return {
          content: [{
            type: 'text',
            text: JSON.stringify({
              success: false,
              message: 'Authentication required. Please authenticate first.'
            })
          }]
        };
      }
    }
    
    return {
      content: [{
        type: 'text',
        text: `Added todo: "${args.title}"`
      }]
    };
  }
  
  throw new Error(`Unknown tool: ${name}`);
});

const transport = new StdioServerTransport();
await server.connect(transport);
console.error('Memory Dump Server running on stdio');
