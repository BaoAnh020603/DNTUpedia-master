#!/bin/sh

set -e

source ../.env

git clone https://github.com/katalon-studio/katalon-docs-dita

aws s3 sync "./katalon-docs-dita/docs" "s3://${DOCS_S3_BUCKET_ID}" --delete

aws bedrock-agent start-ingestion-job \
  --knowledge-base-id $KNOWLEDGE_BASE_ID \
  --data-source-id $DOCS_DATA_SOURCE_ID | jq | tee ingestion-job.json

# Check job status, it may take a while...
aws bedrock-agent get-ingestion-job \
  --knowledge-base-id $KNOWLEDGE_BASE_ID \
  --data-source-id $DOCS_DATA_SOURCE_ID \
  --ingestion-job-id $(cat ingestion-job.json | jq -r .ingestionJob.ingestionJobId) | jq
