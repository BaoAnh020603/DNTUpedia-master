import {
  BedrockAgentRuntimeClient,
  RetrieveCommand,
  RetrieveCommandOutput,
  ValidationException,
} from "@aws-sdk/client-bedrock-agent-runtime";

// Role levels as integers
enum ROLE {
  ANONYMOUS = 1,
  USER = 2,
  ADMIN = 4,
}

const client = new BedrockAgentRuntimeClient();

async function retrieveWithRetry(
  command: RetrieveCommand,
  attempt: number
): Promise<RetrieveCommandOutput> {
  try {
    return await client.send(command);
  } catch (error) {
    let shouldRetry = false;
    if (error instanceof ValidationException) {
      if (error.message.includes(" is resuming after being auto-paused.")) {
        // this may happen when Aurora scales to zero
        shouldRetry = true;
      }
    }

    // retry at maximum 5 times
    if (!shouldRetry || attempt >= 5) {
      throw error;
    }

    // exponential backoff: 1s, 2s, 4s, 8s, 16s
    const durationInMs = Math.pow(2, attempt) * 1000;
    await new Promise((r) => setTimeout(r, durationInMs));

    console.warn("Retrying retrieval...", { attempt, durationInMs, error });
    return retrieveWithRetry(command, attempt + 1);
  }
}

export async function retrieveFromBedrock(text: string) {
  const command = new RetrieveCommand({
    knowledgeBaseId: process.env.KNOWLEDGE_BASE_ID,
    retrievalQuery: { text },
    retrievalConfiguration: {
      vectorSearchConfiguration: {
        filter: {
          lessThanOrEquals: {
            key: "role",
            value: ROLE.ANONYMOUS, // TODO: replace by JWT claims
          },
        },
      },
    },
  });
  const response = await retrieveWithRetry(command, 0);
  return response.retrievalResults ?? [];
}
