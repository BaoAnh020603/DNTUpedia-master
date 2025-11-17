import { serve } from "@hono/node-server";
import { app } from "./mcp_server/mcp_server_hono";

const port = parseInt(process.env.PORT || "3000");
serve({ fetch: app.fetch, port });
console.log(`Serving on port ${port}...`);
