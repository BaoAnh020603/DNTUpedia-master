import { streamHandle } from "hono/aws-lambda";
import { app } from "./mcp_server/mcp_server_hono";

export const handler = streamHandle(app);
