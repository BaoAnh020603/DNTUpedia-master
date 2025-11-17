import { streamHandle } from "hono/aws-lambda";
import { app } from "./deep_chat/deep_chat_hono";

export const handler = streamHandle(app);
