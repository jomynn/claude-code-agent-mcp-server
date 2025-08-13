#!/usr/bin/env node

// Basic Memory Dump Server Stub
// Replace this with the full memory-dump-server.js from the artifacts

console.error('Memory Dump Server starting...');

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';

const server = new Server(
  { name: 'memory-dump-server', version: '1.0.0' },
  { capabilities: { tools: {} } }
);

// Basic tool setup
server.setRequestHandler('tools/list', async () => ({
  tools: [{
    name: 'add_todo',
    description: 'Add a todo item',
    inputSchema: {
      type: 'object',
      properties: {
        title: { type: 'string', description: 'Todo title' }
      },
      required: ['title']
    }
  }]
}));

server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;
  
  if (name === 'add_todo') {
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
