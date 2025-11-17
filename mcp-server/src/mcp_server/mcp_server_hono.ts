import type { KnowledgeBaseRetrievalResult } from "@aws-sdk/client-bedrock-agent-runtime";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import type { CallToolResult } from "@modelcontextprotocol/sdk/types.js";
import { toFetchResponse, toReqRes } from "fetch-to-node";
import { Hono } from "hono";
import { logger } from "hono/logger";
import { z } from "zod";
import { retrieveFromBedrock } from "./bedrock";

const docsS3BucketId = process.env.DOCS_S3_BUCKET_ID ?? "";
const docsS3UriPrefix =
  docsS3BucketId.length > 0 ? `s3://${docsS3BucketId}/` : "";

const server = new McpServer({
  name: "Katalon knowledge base",
  version: "0.1.0",
});

server.tool(
  "search_katalon_knowledge_base",
  "Search for Katalon documents from knowledge base",
  { query: z.string() },
  async ({ query }) => {
    const results = await retrieveFromBedrock(query).catch((error) => {
      // we don't want to expose any server error to the client
      console.error("retrieveFromBedrock", { error });
      return [] as KnowledgeBaseRetrievalResult[];
    });

    const content: CallToolResult["content"] = results
      .map((result) => {
        const text = result.content?.text ?? "";
        const uri = result.location?.s3Location?.uri ?? "";

        const link =
          docsS3UriPrefix.length > 0 &&
          uri.startsWith(docsS3UriPrefix) &&
          uri.endsWith(".md")
            ? `https://docs.katalon.com/${uri.slice(
                docsS3UriPrefix.length,
                -3
              )}`
            : "";
        if (link.length === 0) {
          console.warn("Unrecognized result", { result });
        }

        return {
          type: "text" as const,
          text:
            link.length > 0
              ? `<result><text>${text}</text><link>${link}</link></result>`
              : text,
        };
      })
      .filter((content) => content.text.length > 0);

    return { content };
  }
);

let transport: StreamableHTTPServerTransport | undefined;

export const app = new Hono();

app.use(logger());
app.post("/mcp", async (c) => {
  if (typeof transport === "undefined") {
    transport = new StreamableHTTPServerTransport({
      sessionIdGenerator: undefined, // stateless mode
    });

    await server.connect(transport).catch((error) => {
      console.error(error);
      process.exit(1);
    });
  }

  const { req, res } = toReqRes(c.req.raw);
  await transport.handleRequest(req, res, await c.req.json());
  return toFetchResponse(res);
});

process.on("SIGINT", async () => {
  await transport?.close().catch(console.error);
  await server.close().catch(console.error);
  process.exit(0);
});
