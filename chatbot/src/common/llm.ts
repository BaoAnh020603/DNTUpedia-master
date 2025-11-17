import { createAmazonBedrock } from "@ai-sdk/amazon-bedrock";
import { fromNodeProviderChain } from "@aws-sdk/credential-providers";
import { StreamableHTTPClientTransport } from "@modelcontextprotocol/sdk/client/streamableHttp";
import {
  CoreMessage,
  experimental_createMCPClient,
  streamText,
  ToolSet,
} from "ai";

const bedrock = createAmazonBedrock({
  credentialProvider: fromNodeProviderChain(),
});

const toolsPromise = new Promise<ToolSet>(async (resolve) => {
  const url = `${process.env.KNOWLEDGE_BASE_MCP_SERVER_FUNCTION_URL}/mcp`;
  const transport = new StreamableHTTPClientTransport(new URL(url));
  const client = await experimental_createMCPClient({ transport });
  console.log("Created MCP client", { url });
  const tools = await client.tools();
  console.log({ tools: Object.keys(tools) });
  resolve(tools);
});

export async function streamTextWithMcp(
  system: string,
  messages: CoreMessage[]
) {
  return streamText({
    model: bedrock("amazon.nova-pro-v1:0"),
    messages,
    maxSteps: 10,
    system,
    tools: await toolsPromise,
  });
}
