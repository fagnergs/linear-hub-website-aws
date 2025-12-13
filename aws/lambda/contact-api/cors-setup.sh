#!/bin/bash

API_ID="xsp6ymu9u6"
RESOURCE_ID="1qs1uf"
REGION="us-east-1"

# Create OPTIONS method
echo "Creating OPTIONS method..."
aws apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method OPTIONS \
  --type MOCK \
  --region $REGION

# Create method response
echo "Creating method response..."
aws apigateway put-method-response \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method OPTIONS \
  --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Headers":true,"method.response.header.Access-Control-Allow-Methods":true,"method.response.header.Access-Control-Allow-Origin":true}' \
  --region $REGION

# Create integration response
echo "Creating integration response..."
aws apigateway put-integration-response \
  --rest-api-id $API_ID \
  --resource-id $RESOURCE_ID \
  --http-method OPTIONS \
  --status-code 200 \
  --response-parameters '{"method.response.header.Access-Control-Allow-Headers":"'"'"'Content-Type'"'"'","method.response.header.Access-Control-Allow-Methods":"'"'"'POST,OPTIONS'"'"'","method.response.header.Access-Control-Allow-Origin":"'"'"'*'"'"'}' \
  --region $REGION

# Deploy
echo "Deploying..."
aws apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name prod \
  --region $REGION

echo "✅ CORS configured!"
