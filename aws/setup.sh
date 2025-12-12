#!/bin/bash
# AWS Setup Script for Linear Hub Website
# This script automates IAM, S3, CloudFront, and Lambda setup

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  AWS Setup: Linear Hub Website (Lambda + S3 + CloudFront)    ║"
echo "╚════════════════════════════════════════════════════════════════╝"

# Configuration
APPLICATION="linear-hub-website"
ENVIRONMENT="production"
TENANT="linear-hub"
REGION="us-east-1"
DEPLOYER_USER="linear-hub-deployer"
BUCKET_SUFFIX=$(date +%s)
BUCKET_NAME="${TENANT}-website-prod-${BUCKET_SUFFIX}"

echo ""
echo "📋 Configuration:"
echo "   Application: $APPLICATION"
echo "   Environment: $ENVIRONMENT"
echo "   Tenant: $TENANT"
echo "   Region: $REGION"
echo "   Bucket: $BUCKET_NAME"
echo ""

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI not found. Install it first:"
    echo "   https://aws.amazon.com/cli/"
    exit 1
fi

echo "✅ AWS CLI found: $(aws --version)"

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials not configured."
    echo "   Run: aws configure"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "✅ AWS Account ID: $ACCOUNT_ID"
echo ""

# Step 1: Create IAM User
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 1: Creating IAM User ($DEPLOYER_USER)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if aws iam get-user --user-name "$DEPLOYER_USER" 2>/dev/null; then
    echo "⚠️  User $DEPLOYER_USER already exists"
else
    aws iam create-user --user-name "$DEPLOYER_USER" \
      --tags Key=Application,Value=$APPLICATION Key=Tenant,Value=$TENANT
    echo "✅ Created IAM user: $DEPLOYER_USER"
fi

# Step 2: Create S3 Bucket
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Creating S3 Bucket"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --tags "TagSet=[
    {Key=Application,Value=$APPLICATION},
    {Key=Environment,Value=$ENVIRONMENT},
    {Key=Tenant,Value=$TENANT}
  ]" 2>/dev/null || echo "⚠️  Bucket may already exist"

echo "✅ S3 Bucket: $BUCKET_NAME"

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled
echo "✅ Versioning enabled"

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
echo "✅ Encryption enabled (AES256)"

# Block public access
aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
echo "✅ Public access blocked"

# Step 3: Create Output
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ SETUP COMPLETED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "📌 NEXT STEPS:"
echo ""
echo "1️⃣  Create IAM Access Keys:"
echo "    aws iam create-access-key --user-name $DEPLOYER_USER"
echo "    ⚠️  SAVE THE OUTPUT SECURELY!"
echo ""
echo "2️⃣  Attach IAM Policy:"
echo "    aws iam put-user-policy --user-name $DEPLOYER_USER \\"
echo "      --policy-name ${DEPLOYER_USER}-policy \\"
echo "      --policy-document file://aws/iam-policy.json"
echo ""
echo "3️⃣  Create CloudFront Distribution (manual in Console or via script)"
echo ""
echo "4️⃣  Add GitHub Secrets:"
echo "    AWS_ACCESS_KEY_ID"
echo "    AWS_SECRET_ACCESS_KEY"
echo "    S3_BUCKET=$BUCKET_NAME"
echo ""
echo "5️⃣  Run GitHub Actions workflow to deploy"
echo ""

echo "📝 Save these values:"
echo "   BUCKET_NAME=$BUCKET_NAME"
echo "   ACCOUNT_ID=$ACCOUNT_ID"
echo "   IAM_USER=$DEPLOYER_USER"
echo ""
