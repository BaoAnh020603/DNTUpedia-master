
#!/bin/bash

# Test the /deep_chat endpoint
curl -X POST https://io3d4xjwho34pma4eypowg27ga0nzylk.lambda-url.us-east-1.on.aws/deep_chat \
  -H "Content-Type: application/json" \
  -H "Accept: text/event-stream" \
  -d '{
    "messages": [
      {
        "role": "user",
        "text": "What is DNTU?"
      }
    ]
  }'