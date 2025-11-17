import { createAmazonBedrock } from "@ai-sdk/amazon-bedrock";
import { fromNodeProviderChain } from "@aws-sdk/credential-providers";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp";
import { experimental_createMCPClient, streamText } from "ai";

const bedrock = createAmazonBedrock({
  credentialProvider: fromNodeProviderChain(),
});

(async () => {
  const url = `${process.env.KNOWLEDGE_BASE_MCP_SERVER_FUNCTION_URL}/mcp`;
  const transport = new StreamableHTTPClientTransport(new URL(url));
  const client = await experimental_createMCPClient({ transport });
  console.warn("Created MCP client", { url });

  try {
    const tools = await client.tools();
    console.warn({ tools: Object.keys(tools) });

    const startedAt = Date.now();
    const { fullStream } = streamText({
      model: bedrock("amazon.nova-pro-v1:0"),
      tools,
      maxSteps: 3,
      messages: [
        {
          role: "user",
          content: "Does Katalon support testing of Salesforce applications?",
        },
      ],
    });

    for await (const part of fullStream) {
      switch (part.type) {
        case "tool-call":
          const { toolName, args } = part;
          console.warn("Tool call:", toolName, JSON.stringify(args, null, 2));
          break;
        case "tool-result":
          const { result } = part;
          console.warn(JSON.stringify(result, null, 2));
          break;
        case "text-delta":
          const { textDelta } = part;
          process.stdout.write(textDelta);
          break;
        case "step-finish":
        case "step-start":
        case "finish":
          process.stderr.write("\n");
          break;
        default:
          console.warn("Unknown part:", { part });
          break;
      }
    }

    const elapsedInMs = Date.now() - startedAt;
    console.log({ elapsedInMs });
  } finally {
    await transport.close();
  }
})();
