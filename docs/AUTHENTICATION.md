# MCP Server Authentication

## Overview

The MCP server now includes a token-based authentication system to secure access to its tools and resources.

## Features

- **Token-based authentication**: Secure access using API tokens
- **Session management**: Automatic session creation and expiry
- **Admin token generation**: Create new tokens for different users/services
- **Token revocation**: Disable compromised or unused tokens
- **Optional authentication**: Can be enabled/disabled via environment variables

## Configuration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Enable authentication (true/false)
MCP_REQUIRE_AUTH=true

# Token expiry time in milliseconds (default: 86400000 = 24 hours)
MCP_TOKEN_EXPIRY=86400000
```

## Managing Tokens

### Using the Management Script

Run the authentication manager:

```bash
npm run auth:manage
```

Options available:
1. **List tokens**: View all existing tokens (partially masked)
2. **Generate new token**: Create a new authentication token
3. **Revoke token**: Disable an existing token
4. **Exit**: Close the manager

### Token Storage

Tokens are stored in `config/auth-tokens.json` with the following structure:

```json
{
  "tokens": [
    {
      "id": "unique-id",
      "token": "secure-token-hash",
      "name": "token-name",
      "createdAt": "ISO-date",
      "active": true
    }
  ]
}
```

## Using Authentication

### 1. Authenticate with the Server

First, authenticate to get a session ID:

```javascript
const result = await mcp.callTool('authenticate', {
  token: 'your-authentication-token'
});

// Response:
{
  "success": true,
  "message": "Authenticated as default",
  "sessionId": "generated-session-id"
}
```

### 2. Use Authenticated Tools

Include the session ID in subsequent tool calls:

```javascript
const result = await mcp.callTool('add_todo', {
  title: 'My Todo Item',
  sessionId: 'your-session-id'
});
```

### 3. Generate New Tokens (Admin Only)

Admin users can generate new tokens:

```javascript
const result = await mcp.callTool('generate_token', {
  name: 'new-user',
  adminToken: 'admin-authentication-token'
});

// Response:
{
  "success": true,
  "token": "newly-generated-token",
  "message": "Token generated for new-user"
}
```

## Security Best Practices

1. **Never commit tokens**: Keep `auth-tokens.json` and `.env` files in `.gitignore`
2. **Use HTTPS**: Always use secure connections in production
3. **Rotate tokens regularly**: Generate new tokens periodically
4. **Revoke unused tokens**: Disable tokens that are no longer needed
5. **Monitor access**: Keep track of authentication attempts and usage

## Integration with n8n

When using with n8n workflows:

1. Store your MCP token in n8n credentials
2. Use the HTTP Request node to authenticate:
   - Method: POST
   - Endpoint: Your MCP server endpoint
   - Body: Include the authentication token
3. Store the session ID in workflow variables
4. Include session ID in subsequent MCP tool calls

## Troubleshooting

### Token Not Working

1. Check if authentication is enabled (`MCP_REQUIRE_AUTH=true`)
2. Verify token is active in `config/auth-tokens.json`
3. Ensure token hasn't expired (check `MCP_TOKEN_EXPIRY`)

### Session Expired

Sessions expire after the configured timeout. Re-authenticate to get a new session ID.

### Can't Generate Admin Token

Only the default token created on first run has admin privileges. Use it to generate additional admin tokens if needed.