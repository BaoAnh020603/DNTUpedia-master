# DNTUpedia – Chatbot Generative AI hỗ trợ chuyển đổi số tại Trường Đại học Công nghệ Đồng Nai

A complete Model Context Protocol (MCP) implementation with AWS Bedrock integration for intelligent document retrieval.

## Overview

This project consists of two main components:

- **MCP Server**: HTTP-based server with AWS Bedrock Knowledge Base integration
- **MCP Client**: TypeScript client for testing and interacting with MCP servers

## Quick Start

### 1. MCP Server

```bash
cd mcp-server
npm install
cp .env.example .env
# Edit .env with AWS credentials
npm run dev
# Server runs on http://localhost:3000/mcp
```

### 2. MCP Client

```bash
cd mcp-client
npm install
cp .env.example .env
npm run start
```

## Features

- 🤖 AWS Bedrock Knowledge Base integration
- 🔍 Natural language document search
- 🌐 HTTP transport (Streamable MCP)
- ☁️ AWS Lambda deployment ready
- 📄 PDF and Markdown document support

## Project Structure

```
DNTU Document/
├── mcp-server/           # MCP server implementation
│   ├── src/             # Server source code
│   ├── docs/            # Knowledge base documents
│   ├── terraform/       # AWS infrastructure
│   └── scripts/         # Utility scripts
├── mcp-client/          # MCP client implementation
│   └── src/             # Client source code
└── chatbot/             # (empty)
```

## Usage with GitHub Copilot

Add to your VS Code `settings.json`:

```json
{
  "mcp": {
    "servers": {
      "bedrock-server": {
        "type": "http",
        "url": "http://localhost:3000/mcp"
      }
    }
  }
}
```

## Documentation

- [MCP Server Documentation](mcp-server/README.md)
- [MCP Client Documentation](mcp-client/README.md)

## Tech Stack

- **Runtime**: Node.js + TypeScript
- **Server**: Hono.js with HTTP transport
- **Cloud**: AWS Bedrock, Lambda
- **Infrastructure**: Terraform
- **Protocol**: Model Context Protocol (MCP)
