# MCP Client

A TypeScript client for connecting to Model Context Protocol (MCP) servers using HTTP transport.

## Description

This MCP client demonstrates how to connect to and interact with MCP servers over HTTP. It provides a simple interface for testing MCP server functionality and can be used as a reference implementation for building MCP client applications.

## Features

- 🌐 HTTP transport support (Streamable)
- 🔧 TypeScript implementation
- 🛠️ Easy server connection and interaction
- 📝 Example usage patterns

## Installation

```bash
# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env with your MCP server configuration
```

## Usage

### Basic Connection

```bash
# Run the client
npm run start
```

## Example Usage

The client connects to your MCP server and demonstrates:

- Server capability discovery
- Tool listing and execution
- Resource access
- Prompt management

## Connecting to MCP Server

Make sure your MCP server is running first:

```bash
# In mcp-server directory
cd ../mcp-server
npm run dev
```

Then run the client:

```bash
# In mcp-client directory
npm start
```

## Project Structure

```
mcp-client/
├── src/
│   └── index.ts          # Main client implementation
├── .env                  # Environment configuration
├── package.json          # Dependencies and scripts
├── tsconfig.json         # TypeScript configuration
└── README.md
```

## Available Scripts

- `npm start` - Run the client

## Related Projects

- [MCP Server](../mcp-server/README.md) - The corresponding MCP server implementation

## License

[Add your license information here]
