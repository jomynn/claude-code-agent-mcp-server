#!/usr/bin/env node

import fs from 'fs/promises';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';
import readline from 'readline/promises';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const CONFIG_FILE = path.join(__dirname, '..', 'config', 'auth-tokens.json');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

async function loadTokens() {
  try {
    const data = await fs.readFile(CONFIG_FILE, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    console.log('No existing token file found. Creating new one...');
    return { tokens: [] };
  }
}

async function saveTokens(tokens) {
  await fs.mkdir(path.dirname(CONFIG_FILE), { recursive: true });
  await fs.writeFile(CONFIG_FILE, JSON.stringify(tokens, null, 2));
}

async function listTokens() {
  const config = await loadTokens();
  if (config.tokens.length === 0) {
    console.log('No tokens found.');
    return;
  }
  
  console.log('\nExisting tokens:');
  console.log('================');
  config.tokens.forEach((token, index) => {
    console.log(`${index + 1}. Name: ${token.name}`);
    console.log(`   ID: ${token.id}`);
    console.log(`   Token: ${token.token.substring(0, 8)}...${token.token.substring(token.token.length - 8)}`);
    console.log(`   Created: ${token.createdAt}`);
    console.log(`   Active: ${token.active}`);
    console.log('');
  });
}

async function generateToken() {
  const name = await rl.question('Enter token name: ');
  
  const config = await loadTokens();
  const newToken = {
    id: crypto.randomUUID(),
    token: crypto.randomBytes(32).toString('hex'),
    name: name || 'unnamed',
    createdAt: new Date().toISOString(),
    active: true
  };
  
  config.tokens.push(newToken);
  await saveTokens(config);
  
  console.log('\nToken generated successfully!');
  console.log('============================');
  console.log(`Name: ${newToken.name}`);
  console.log(`Token: ${newToken.token}`);
  console.log('\nIMPORTANT: Save this token securely. It will not be shown again in full.');
}

async function revokeToken() {
  const config = await loadTokens();
  if (config.tokens.length === 0) {
    console.log('No tokens to revoke.');
    return;
  }
  
  await listTokens();
  const index = await rl.question('Enter token number to revoke (or 0 to cancel): ');
  const tokenIndex = parseInt(index) - 1;
  
  if (tokenIndex >= 0 && tokenIndex < config.tokens.length) {
    config.tokens[tokenIndex].active = false;
    await saveTokens(config);
    console.log(`Token "${config.tokens[tokenIndex].name}" has been revoked.`);
  } else if (index !== '0') {
    console.log('Invalid token number.');
  }
}

async function main() {
  console.log('MCP Server Authentication Manager');
  console.log('=================================\n');
  
  while (true) {
    console.log('\nOptions:');
    console.log('1. List tokens');
    console.log('2. Generate new token');
    console.log('3. Revoke token');
    console.log('4. Exit');
    
    const choice = await rl.question('\nSelect option (1-4): ');
    
    switch (choice) {
      case '1':
        await listTokens();
        break;
      case '2':
        await generateToken();
        break;
      case '3':
        await revokeToken();
        break;
      case '4':
        rl.close();
        process.exit(0);
      default:
        console.log('Invalid option. Please try again.');
    }
  }
}

main().catch(console.error);