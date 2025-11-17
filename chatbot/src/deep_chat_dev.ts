import { serve } from "@hono/node-server";
import { serveStatic } from "@hono/node-server/serve-static";
import { app } from "./deep_chat/deep_chat_hono";

app.use("/public/*", serveStatic({ root: "./" }));

const port = parseInt(process.env.PORT || "3001");
serve({ fetch: app.fetch, port });
console.log(`Serving on port ${port}...`);
