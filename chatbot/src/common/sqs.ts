import { SendMessageCommand, SQSClient } from "@aws-sdk/client-sqs";

const client = new SQSClient();

export async function sendSqsMessage(queueUrl: string, messageBody: string) {
  const command = new SendMessageCommand({
    QueueUrl: queueUrl,
    MessageBody: messageBody,
  });
  await client.send(command);
}
