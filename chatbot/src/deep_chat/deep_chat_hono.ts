import type { MessageContent } from "deep-chat/dist/types/messages";
import type { Response } from "deep-chat/dist/types/response";
import type { CoreMessage } from "ai";
import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { streamSSE } from "hono/streaming";
import { streamTextWithMcp } from "../common/llm";

export const app = new Hono();
app.use(cors());
app.use(logger());
  
const system = [
  "You are an AI assistant on Dong Nai Technology University (DNTU) document website. ",
  "People may ask you questions about DNTU or things in the education domain. ",
  "Reference result source if available: according to [page title](source link), something something. ",
  "Respectfully decline to answer unrelated questions. ",
].join("");

app.post("/deep_chat", async (c) => {
  const body = (await c.req.json()) as { messages: MessageContent[] };
  const messages = body.messages
    .map<CoreMessage>((message) => ({
      role: message.role === "ai" ? "assistant" : "user",
      content: message.text ?? "",
    }))
    .filter((message) => message.content.length > 0);
  console.log("Handling POST request", { messages });

  return streamSSE(c, async (sse) => {
    const writeResponse = (data: Response) =>
      sse.writeSSE({ data: JSON.stringify(data) });

    const { fullStream } = await streamTextWithMcp(system, messages);

    for await (const part of fullStream) {
      switch (part.type) {
        case "tool-call":
          const { toolName, args } = part;
          console.log("Tool call:", toolName, JSON.stringify(args, null, 2));
          break;
        case "text-delta":
          const { textDelta } = part;
          writeResponse({ role: "ai", text: textDelta });
          break;
      }
    }
  });
});
