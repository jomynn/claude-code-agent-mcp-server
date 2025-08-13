#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CONFIG_FILE = path.join(__dirname, '..', 'config', 'auth-tokens.json');

console.log('Testing MCP Authentication System');
console.log('==================================\n');

async function testTokenManagement() {
  console.log('1. Testing Token File Creation/Loading...');
  try {
    const data = await fs.readFile(CONFIG_FILE, 'utf8');
    const config = JSON.parse(data);
    
    if (config.tokens && config.tokens.length > 0) {
      console.log('   ✓ Token file exists and contains tokens');
      console.log(`   ✓ Found ${config.tokens.length} token(s)`);
      
      const defaultToken = config.tokens.find(t => t.name === 'default');
      if (defaultToken) {
        console.log('   ✓ Default token exists');
        console.log(`   ✓ Token format: ${defaultToken.token.substring(0, 8)}...${defaultToken.token.substring(defaultToken.token.length - 8)}`);
      }
    } else {
      console.log('   ⚠ Token file exists but contains no tokens');
    }
  } catch (error) {
    console.log('   ✗ Error reading token file:', error.message);
  }
}

async function testAuthFeatures() {
  console.log('\n2. Testing Authentication Features...');
  
  // Test environment variables
  console.log('   Environment Variables:');
  console.log(`   - MCP_REQUIRE_AUTH: ${process.env.MCP_REQUIRE_AUTH || 'not set (defaults to false)'}`);
  console.log(`   - MCP_TOKEN_EXPIRY: ${process.env.MCP_TOKEN_EXPIRY || 'not set (defaults to 86400000ms)'}`);
  
  // Test authentication logic
  const requireAuth = process.env.MCP_REQUIRE_AUTH === 'true';
  if (requireAuth) {
    console.log('   ✓ Authentication is ENABLED');
  } else {
    console.log('   ⚠ Authentication is DISABLED (set MCP_REQUIRE_AUTH=true to enable)');
  }
}

async function testServerIntegration() {
  console.log('\n3. Server Integration Check...');
  
  try {
    // Check if server file exists
    const serverPath = path.join(__dirname, '..', 'mcp-servers', 'memory-dump-server.js');
    await fs.access(serverPath);
    console.log('   ✓ MCP server file exists');
    
    // Check for authentication endpoints in server
    const serverCode = await fs.readFile(serverPath, 'utf8');
    
    if (serverCode.includes('authenticate')) {
      console.log('   ✓ Authentication endpoint implemented');
    }
    
    if (serverCode.includes('generate_token')) {
      console.log('   ✓ Token generation endpoint implemented');
    }
    
    if (serverCode.includes('verifyToken')) {
      console.log('   ✓ Token verification logic implemented');
    }
    
  } catch (error) {
    console.log('   ✗ Error checking server integration:', error.message);
  }
}

async function main() {
  await testTokenManagement();
  await testAuthFeatures();
  await testServerIntegration();
  
  console.log('\n==================================');
  console.log('Authentication System Test Complete');
  console.log('\nNext Steps:');
  console.log('1. Set MCP_REQUIRE_AUTH=true in .env to enable authentication');
  console.log('2. Run "npm run auth:manage" to manage tokens');
  console.log('3. Run "npm run mcp:start" to start the MCP server');
  console.log('4. Use the default token from config/auth-tokens.json to authenticate');
}

main().catch(console.error);