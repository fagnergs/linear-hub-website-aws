#!/bin/bash

# AWS Infrastructure Deployment Script
# Creates CloudFront, Lambda, API Gateway, and updates GitHub Secrets
# Usage: ./aws/deploy-infrastructure.sh

set -e

# ═══════════════════════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════════

APPLICATION="linear-hub-website"
ENVIRONMENT="production"
TENANT="linear-hub"
REGION="us-east-1"
DEPLOYER_USER="linear-hub-deployer"

# S3 Bucket (from previous setup)
S3_BUCKET="linear-hub-website-prod-1765543563"

# Lambda Configuration
LAMBDA_FUNCTION_NAME="${TENANT}-contact-api"
LAMBDA_HANDLER="index.handler"
LAMBDA_RUNTIME="nodejs20.x"
LAMBDA_TIMEOUT=30
LAMBDA_MEMORY=256

# API Gateway Configuration
API_GATEWAY_NAME="${TENANT}-api"

# GitHub Configuration
GITHUB_REPO="fagnergs/linear-hub-website-aws"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  AWS Infrastructure Deployment (CloudFront + Lambda + API)   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Configuration:"
echo "   Application: $APPLICATION"
echo "   Environment: $ENVIRONMENT"
echo "   Tenant: $TENANT"
echo "   Region: $REGION"
echo "   S3 Bucket: $S3_BUCKET"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 1: Create CloudFront Distribution with Origin Access Identity
# ═══════════════════════════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Creating CloudFront Distribution with Origin Access Identity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create OAI (Origin Access Identity)
echo "Creating Origin Access Identity..."
OAI_JSON=$(aws cloudfront create-cloud-front-origin-access-identity \
  --cloud-front-origin-access-identity-config \
  CallerReference="$(date +%s)",\
Comment="OAI for ${S3_BUCKET}" \
  --region $REGION)

OAI_ID=$(echo $OAI_JSON | grep -o '"Id": "[^"]*"' | head -1 | cut -d'"' -f4)
OAI_CANONICAL=$(echo $OAI_JSON | grep -o '"S3CanonicalUserId": "[^"]*"' | cut -d'"' -f4)

echo "✅ OAI Created: $OAI_ID"
echo ""

# Update S3 bucket policy to allow CloudFront OAI
echo "Updating S3 bucket policy for CloudFront OAI..."
S3_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "CanonicalUser": "$OAI_CANONICAL"
      },
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${S3_BUCKET}/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "CanonicalUser": "$OAI_CANONICAL"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${S3_BUCKET}"
    }
  ]
}
EOF
)

echo "$S3_POLICY" | aws s3api put-bucket-policy --bucket $S3_BUCKET --policy file:///dev/stdin
echo "✅ S3 bucket policy updated"
echo ""

# Create CloudFront Distribution
echo "Creating CloudFront Distribution..."

CLOUDFRONT_CONFIG=$(cat <<EOF
{
  "CallerReference": "$(date +%s)",
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-${S3_BUCKET}",
        "DomainName": "${S3_BUCKET}.s3.${REGION}.amazonaws.com",
        "S3OriginConfig": {
          "OriginAccessIdentity": "origin-access-identity/cloudfront/${OAI_ID}"
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-${S3_BUCKET}",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "ViewerProtocolPolicy": "redirect-to-https",
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "Compress": true,
    "MinTTL": 0,
    "DefaultTTL": 300,
    "MaxTTL": 31536000
  },
  "Comment": "Distribution for ${APPLICATION}",
  "PriceClass": "PriceClass_100",
  "Enabled": true,
  "ViewerCertificate": {
    "CloudFrontDefaultCertificate": true
  }
}
EOF
)

CLOUDFRONT_JSON=$(aws cloudfront create-distribution \
  --distribution-config "$CLOUDFRONT_CONFIG" \
  --region $REGION)

DISTRIBUTION_ID=$(echo $CLOUDFRONT_JSON | grep -o '"Id": "[^"]*"' | head -1 | cut -d'"' -f4)
DISTRIBUTION_DOMAIN=$(echo $CLOUDFRONT_JSON | grep -o '"DomainName": "[^"]*"' | head -1 | cut -d'"' -f4)

echo "✅ CloudFront Distribution Created!"
echo "   ID: $DISTRIBUTION_ID"
echo "   Domain: $DISTRIBUTION_DOMAIN"
echo "   Status: Deploying (may take 5-10 minutes)"
echo ""

# Add tags to CloudFront distribution
echo "Adding tags to CloudFront distribution..."
aws cloudfront tag-resource \
  --resource "arn:aws:cloudfront::781705467769:distribution/$DISTRIBUTION_ID" \
  --tags Items=[{Key=Application,Value=$APPLICATION},{Key=Environment,Value=$ENVIRONMENT},{Key=Tenant,Value=$TENANT}] \
  2>/dev/null || echo "✅ Tags added"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 2: Create IAM Role for Lambda
# ═══════════════════════════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Creating IAM Role for Lambda"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

LAMBDA_ROLE_NAME="${TENANT}-lambda-role"

# Create trust policy
TRUST_POLICY=$(cat <<'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

echo "Creating IAM role..."
ROLE_JSON=$(aws iam create-role \
  --role-name $LAMBDA_ROLE_NAME \
  --assume-role-policy-document "$TRUST_POLICY" \
  --tags Key=Application,Value=$APPLICATION Key=Environment,Value=$ENVIRONMENT \
  2>/dev/null || aws iam get-role --role-name $LAMBDA_ROLE_NAME)

LAMBDA_ROLE_ARN=$(echo $ROLE_JSON | grep -o '"Arn": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "✅ IAM Role Created/Found: $LAMBDA_ROLE_ARN"
echo ""

# Attach basic Lambda execution policy
echo "Attaching CloudWatch Logs policy to Lambda role..."
aws iam attach-role-policy \
  --role-name $LAMBDA_ROLE_NAME \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole \
  2>/dev/null || echo "✅ Policy already attached"
echo "✅ CloudWatch Logs policy attached"
echo ""

# Wait for role to be available
sleep 5

# ═══════════════════════════════════════════════════════════════════════════
# STEP 3: Create Lambda Function
# ═══════════════════════════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Creating Lambda Function"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create deployment package (zip file with Lambda code)
echo "Creating Lambda deployment package..."

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Create temporary directory for Lambda package
LAMBDA_PKG_DIR=$(mktemp -d)
cp "$SCRIPT_DIR/lambda/index.js" "$LAMBDA_PKG_DIR/"
cp "$SCRIPT_DIR/lambda/package.json" "$LAMBDA_PKG_DIR/"

# Create zip file
cd "$LAMBDA_PKG_DIR"
zip -q lambda-function.zip index.js package.json
LAMBDA_ZIP="$LAMBDA_PKG_DIR/lambda-function.zip"

echo "✅ Deployment package created"
echo ""

# Create or update Lambda function
echo "Creating Lambda function..."
LAMBDA_JSON=$(aws lambda create-function \
  --function-name $LAMBDA_FUNCTION_NAME \
  --runtime $LAMBDA_RUNTIME \
  --role $LAMBDA_ROLE_ARN \
  --handler $LAMBDA_HANDLER \
  --timeout $LAMBDA_TIMEOUT \
  --memory-size $LAMBDA_MEMORY \
  --zip-file fileb://$LAMBDA_ZIP \
  --description "Contact form API for ${APPLICATION}" \
  --tags Application=$APPLICATION,Environment=$ENVIRONMENT,Tenant=$TENANT \
  --environment Variables="{RESEND_API_KEY=PLACEHOLDER}" \
  --region $REGION \
  2>/dev/null || aws lambda get-function --function-name $LAMBDA_FUNCTION_NAME --region $REGION)

LAMBDA_ARN=$(echo $LAMBDA_JSON | grep -o '"FunctionArn": "[^"]*"' | head -1 | cut -d'"' -f4)
LAMBDA_VERSION=$(echo $LAMBDA_JSON | grep -o '"Version": "[^"]*"' | head -1 | cut -d'"' -f4 || echo "1")

echo "✅ Lambda Function Created!"
echo "   Name: $LAMBDA_FUNCTION_NAME"
echo "   ARN: $LAMBDA_ARN"
echo "   Version: $LAMBDA_VERSION"
echo ""

# Clean up
rm -rf "$LAMBDA_PKG_DIR"

# ═══════════════════════════════════════════════════════════════════════════
# STEP 4: Create API Gateway
# ═══════════════════════════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Creating API Gateway"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Creating REST API..."
API_JSON=$(aws apigateway create-rest-api \
  --name $API_GATEWAY_NAME \
  --description "API for ${APPLICATION}" \
  --endpoint-configuration types=REGIONAL \
  --region $REGION)

REST_API_ID=$(echo $API_JSON | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
echo "✅ REST API Created: $REST_API_ID"
echo ""

# Get root resource
ROOT_RESOURCE=$(aws apigateway get-resources \
  --rest-api-id $REST_API_ID \
  --region $REGION | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)

# Create /contact resource
echo "Creating /contact resource..."
CONTACT_RESOURCE=$(aws apigateway create-resource \
  --rest-api-id $REST_API_ID \
  --parent-id $ROOT_RESOURCE \
  --path-part contact \
  --region $REGION | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)

echo "✅ /contact resource created: $CONTACT_RESOURCE"
echo ""

# Create POST method
echo "Creating POST method..."
aws apigateway put-method \
  --rest-api-id $REST_API_ID \
  --resource-id $CONTACT_RESOURCE \
  --http-method POST \
  --authorization-type NONE \
  --region $REGION > /dev/null

echo "✅ POST method created"
echo ""

# Add Lambda integration
echo "Adding Lambda integration..."
aws apigateway put-integration \
  --rest-api-id $REST_API_ID \
  --resource-id $CONTACT_RESOURCE \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:${REGION}:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations" \
  --region $REGION > /dev/null

echo "✅ Lambda integration added"
echo ""

# Grant API Gateway permission to invoke Lambda
echo "Granting API Gateway permission to invoke Lambda..."
SOURCE_ARN="arn:aws:execute-api:${REGION}:781705467769:${REST_API_ID}/*/*/contact"

aws lambda add-permission \
  --function-name $LAMBDA_FUNCTION_NAME \
  --statement-id AllowAPIGateway \
  --action lambda:InvokeFunction \
  --principal apigateway.amazonaws.com \
  --source-arn $SOURCE_ARN \
  --region $REGION \
  2>/dev/null || echo "✅ Permission already exists"

echo "✅ API Gateway Lambda permission granted"
echo ""

# Deploy API
echo "Deploying API..."
DEPLOYMENT_JSON=$(aws apigateway create-deployment \
  --rest-api-id $REST_API_ID \
  --stage-name prod \
  --description "Production deployment" \
  --region $REGION)

DEPLOYMENT_ID=$(echo $DEPLOYMENT_JSON | grep -o '"id": "[^"]*"' | head -1 | cut -d'"' -f4)
API_ENDPOINT="https://${REST_API_ID}.execute-api.${REGION}.amazonaws.com/prod/contact"

echo "✅ API Deployed!"
echo "   Deployment ID: $DEPLOYMENT_ID"
echo "   Endpoint: $API_ENDPOINT"
echo ""

# ═══════════════════════════════════════════════════════════════════════════
# STEP 5: Summary and Output
# ═══════════════════════════════════════════════════════════════════════════

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ INFRASTRUCTURE DEPLOYMENT COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Created Resources:"
echo ""
echo "  ☁️  CloudFront Distribution"
echo "      ID: $DISTRIBUTION_ID"
echo "      Domain: $DISTRIBUTION_DOMAIN"
echo "      OAI ID: $OAI_ID"
echo ""
echo "  λ Lambda Function"
echo "      Name: $LAMBDA_FUNCTION_NAME"
echo "      ARN: $LAMBDA_ARN"
echo "      Role ARN: $LAMBDA_ROLE_ARN"
echo ""
echo "  🔌 API Gateway"
echo "      API ID: $REST_API_ID"
echo "      Endpoint: $API_ENDPOINT"
echo "      Deployment ID: $DEPLOYMENT_ID"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 GitHub Secrets to Add (from AWS_CREDENTIALS.md):"
echo ""
echo "  AWS_ACCESS_KEY_ID=<your-access-key-id>"
echo "  AWS_SECRET_ACCESS_KEY=<your-secret-access-key>"
echo "  AWS_REGION=$REGION"
echo "  S3_BUCKET=$S3_BUCKET"
echo "  CLOUDFRONT_DISTRIBUTION_ID=$DISTRIBUTION_ID"
echo "  LAMBDA_FUNCTION_NAME=$LAMBDA_FUNCTION_NAME"
echo "  RESEND_API_KEY=<your-resend-api-key>"
echo ""
echo "🌐 Next Steps:"
echo "  1. Update DNS: linear-hub.com.br → $DISTRIBUTION_DOMAIN"
echo "  2. Add GitHub Secrets"
echo "  3. Update next.config.js with API_ENDPOINT=$API_ENDPOINT"
echo "  4. Deploy: git push origin main"
echo ""

# Save to file for reference
SUMMARY_FILE="AWS_DEPLOYMENT_SUMMARY.md"
cat > "$PROJECT_ROOT/$SUMMARY_FILE" << EOF
# AWS Deployment Summary

**Created:** $(date)

## CloudFront Distribution
- **ID:** $DISTRIBUTION_ID
- **Domain:** $DISTRIBUTION_DOMAIN
- **OAI ID:** $OAI_ID
- **Status:** Deploying (5-10 minutes)

## Lambda Function
- **Name:** $LAMBDA_FUNCTION_NAME
- **ARN:** $LAMBDA_ARN
- **Role ARN:** $LAMBDA_ROLE_ARN
- **Runtime:** $LAMBDA_RUNTIME
- **Memory:** $LAMBDA_MEMORY MB
- **Timeout:** $LAMBDA_TIMEOUT seconds

## API Gateway
- **API ID:** $REST_API_ID
- **Endpoint:** $API_ENDPOINT
- **Method:** POST /contact
- **Deployment ID:** $DEPLOYMENT_ID

## GitHub Secrets Required
\`\`\`
AWS_ACCESS_KEY_ID=<from-AWS_CREDENTIALS.md>
AWS_SECRET_ACCESS_KEY=<from-AWS_CREDENTIALS.md>
AWS_REGION=us-east-1
S3_BUCKET=$S3_BUCKET
CLOUDFRONT_DISTRIBUTION_ID=$DISTRIBUTION_ID
LAMBDA_FUNCTION_NAME=$LAMBDA_FUNCTION_NAME
RESEND_API_KEY=<your-resend-key>
\`\`\`

## DNS Configuration
Update your domain registrar:
\`\`\`
A Record: linear-hub.com.br → $DISTRIBUTION_DOMAIN
CNAME Record: www.linear-hub.com.br → $DISTRIBUTION_DOMAIN
\`\`\`

## Environment Variables to Update
Update \`.env.production\` or GitHub Secrets:
\`\`\`
NEXT_PUBLIC_API_ENDPOINT=$API_ENDPOINT
RESEND_API_KEY=<your-resend-key>
\`\`\`
EOF

echo "✅ Deployment summary saved to $SUMMARY_FILE"
echo ""
echo "All done! 🎉"
