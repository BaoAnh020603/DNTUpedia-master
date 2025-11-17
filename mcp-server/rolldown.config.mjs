import { defineConfig } from "rolldown";

export default defineConfig({
  external: [/^@aws-sdk\//, /^@smithy\//],
  input: "src/mcp_server.ts",
  output: {
    file: "dist/mcp_server.mjs",
    format: "esm",
    target: "es2023",
  },
  platform: "node",
});
