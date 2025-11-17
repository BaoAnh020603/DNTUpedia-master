# Chatbot

A chatbot application built with Node.js that provides a web interface using Deep Chat. The application uses AWS services including Lambda, API Gateway, SQS, and DynamoDB.

## Quick Start

### Prerequisites

- Node.js (v18+)
- AWS CLI configured with appropriate permissions
- Terraform (for production deployment)

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```
# For development
PORT=3001

# For AWS deployment
DEEP_CHAT_FUNCTION_NAME=your-function-name
KNOWLEDGE_BASE_MCP_SERVER_FUNCTION_URL=your-mcp-server-url
```

### Development

1. Install dependencies:
   ```
   npm install
   ```

2. Start the Deep Chat development server:
   ```
   npm run dev:deep_chat
   ```

3. Access the chat interface at `http://localhost:3001/public/deep_chat.html`

### Production Deployment

1. Build and deploy the Deep Chat Lambda function:
   ```
   npm run deploy:deep_chat
   ```

2. Deploy infrastructure with Terraform:
   ```
   cd terraform
   terraform init
   terraform apply -var="name=your-chatbot-name" \
     -var="knowledge_base_mcp_server_function_url=your-mcp-server-url" \
     -var="slack_bot_token=your-slack-bot-token" \
     -var="slack_signing_secret=your-slack-signing-secret"
   ```

3. After deployment, Terraform will output:
   - API Gateway endpoint
   - Lambda function URLs
   - DynamoDB table information

## Project Structure

- `src/` - Source code
  - `common/` - Shared utilities
  - `deep_chat/` - Deep Chat web interface implementation
- `public/` - Static web files
- `terraform/` - Infrastructure as code

## Features

- Web interface using Deep Chat
- AWS Bedrock integration for AI capabilities
- Model Context Protocol (MCP) support