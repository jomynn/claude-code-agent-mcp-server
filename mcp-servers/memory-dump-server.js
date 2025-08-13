#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  ListToolsRequestSchema,
  CallToolRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';

const server = new Server(
  { name: 'memory-server', version: '1.0.0' },
  { capabilities: { tools: {} } }
);

server.onerror = (error) => console.error('[Error]', error.message);

server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [{
    name: 'add_todo',
    description: 'Add a todo item',
    inputSchema: {
      type: 'object',
      properties: { title: { type: 'string' } },
      required: ['title']
    }
  }]
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;
  if (name === 'add_todo') {
    return { content: [{ type: 'text', text: `✅ Added: "${args.title}"` }] };
  }
  throw new Error(`Unknown tool: ${name}`);
});

const transport = new StdioServerTransport();
await server.connect(transport);
console.error('Memory server running');
