import { defineConfig } from "rolldown";

export default defineConfig({
  external: [
    /^@aws-sdk\//,

    // cannot externalize these because of `@smithy/eventstream-codec`
    // /^@smithy\//
  ],
  output: {
    format: "esm",
    target: "es2023",
  },
  platform: "node",
});
