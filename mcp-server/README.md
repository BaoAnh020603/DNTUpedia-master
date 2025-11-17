# MCP Server with AWS Bedrock

A Model Context Protocol (MCP) server that provides intelligent document retrieval using AWS Bedrock Knowledge Base via HTTP transport.

## Description

This MCP server integrates with AWS Bedrock Knowledge Base to provide AI-powered document search and retrieval. It supports both local development and AWS Lambda deployment with HTTP transport for easy integration with MCP clients.

## Features

- 🤖 AWS Bedrock Knowledge Base integration
- 🔍 Natural language document search
- 📄 PDF and Markdown document support
- 🌐 HTTP transport (Streamable)
- ☁️ AWS Lambda deployment ready
- 🛠️ Terraform infrastructure automation

## Installation

```bash
# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env with your AWS credentials and configuration
```

## Local Development

```bash
# Start development server
npm run dev

# Server runs on http://localhost:3000/mcp
```

## Production Build

```bash
# Build for production
npm run build

# Output: dist/mcp_server.mjs and dist/mcp_server.zip
```

## Deployment

### AWS Lambda Deployment

1. **Deploy infrastructure**:

```bash
cd terraform
terraform init
terraform apply
```

2. **Deploy function code**:

```bash
# Set environment variable from terraform output
export KNOWLEDGE_BASE_MCP_SERVER_FUNCTION_NAME="your-function-name"

# Deploy
npm run deploy
```

## Configuration

### Environment Variables

```bash
cp .env.example .env
```

Edit .env file with your AWS Credentials

### MCP Client Configuration

#### VS Code

Add to `settings.json`:

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

#### Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "bedrock-server": {
      "type": "http",
      "url": "http://localhost:3000/mcp"
    }
  }
}
```

## Document Management

### Prepare Documents

```bash
# Generate metadata for documents
./scripts/generate-metadata.sh

# Ingest documents to Bedrock Knowledge Base
./scripts/ingest-docs.sh
```

### Document Structure

```
docs/
├── external/              # External documentation
│   ├── external.md
│   ├── knowledge.pdf
│   └── *.metadata.json    # Auto-generated metadata
└── internal/              # Internal documentation
    ├── internal.md
    └── *.metadata.json
```

## Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run deploy` - Deploy to AWS Lambda
- `./scripts/generate-metadata.sh` - Generate document metadata
- `./scripts/ingest-docs.sh` - Upload docs to Bedrock

## Project Structure

```
mcp-server/
├── src/
│   ├── mcp_server.ts         # Main server (production)
│   ├── mcp_server_dev.ts     # Development server
│   └── mcp_server/           # Server modules
├── docs/                     # Documentation files
├── scripts/                  # Utility scripts
├── terraform/                # AWS infrastructure
├── dist/                     # Build output
└── rolldown.config.mjs       # Build configuration
```

## Tech Stack

- **Runtime**: Node.js with TypeScript
- **Framework**: Hono.js for HTTP server
- **Build**: Rolldown bundler
- **Cloud**: AWS Bedrock, Lambda
- **Infrastructure**: Terraform
- **Protocol**: Model Context Protocol (MCP)
