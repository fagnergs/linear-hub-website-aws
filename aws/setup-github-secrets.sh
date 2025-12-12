#!/bin/bash

# GitHub Secrets Setup Script
# This script helps you add AWS secrets to your GitHub repository
# You need GitHub CLI (gh) installed: https://cli.github.com/

set -e

REPO="fagnergs/linear-hub-website-aws"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║          GitHub Secrets Setup for AWS Deployment             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found!"
    echo ""
    echo "Install it from: https://cli.github.com/"
    echo "Or via Homebrew: brew install gh"
    exit 1
fi

echo "✅ GitHub CLI found: $(gh --version)"
echo ""

# Check if authenticated
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ Not authenticated with GitHub!"
    echo ""
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ Authenticated with GitHub"
echo ""

# Values from AWS_DEPLOYMENT_SUMMARY.md
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Secrets to Configure:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Collect AWS credentials from user
echo "Enter your AWS credentials (from AWS_CREDENTIALS.md):"
echo ""

read -p "AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
read -p "AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
read -p "RESEND_API_KEY (from Resend.com dashboard): " RESEND_API_KEY

# Fixed values
AWS_REGION="us-east-1"
S3_BUCKET="linear-hub-website-prod-1765543563"
CLOUDFRONT_DISTRIBUTION_ID="EDQZRUQFXIMQ6"
LAMBDA_FUNCTION_NAME="linear-hub-contact-api"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Setting GitHub Secrets..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Add secrets
gh secret set AWS_ACCESS_KEY_ID --body "$AWS_ACCESS_KEY_ID" --repo $REPO && \
    echo "✅ AWS_ACCESS_KEY_ID" || echo "❌ Failed to set AWS_ACCESS_KEY_ID"

gh secret set AWS_SECRET_ACCESS_KEY --body "$AWS_SECRET_ACCESS_KEY" --repo $REPO && \
    echo "✅ AWS_SECRET_ACCESS_KEY" || echo "❌ Failed to set AWS_SECRET_ACCESS_KEY"

gh secret set AWS_REGION --body "$AWS_REGION" --repo $REPO && \
    echo "✅ AWS_REGION" || echo "❌ Failed to set AWS_REGION"

gh secret set S3_BUCKET --body "$S3_BUCKET" --repo $REPO && \
    echo "✅ S3_BUCKET" || echo "❌ Failed to set S3_BUCKET"

gh secret set CLOUDFRONT_DISTRIBUTION_ID --body "$CLOUDFRONT_DISTRIBUTION_ID" --repo $REPO && \
    echo "✅ CLOUDFRONT_DISTRIBUTION_ID" || echo "❌ Failed to set CLOUDFRONT_DISTRIBUTION_ID"

gh secret set LAMBDA_FUNCTION_NAME --body "$LAMBDA_FUNCTION_NAME" --repo $REPO && \
    echo "✅ LAMBDA_FUNCTION_NAME" || echo "❌ Failed to set LAMBDA_FUNCTION_NAME"

gh secret set RESEND_API_KEY --body "$RESEND_API_KEY" --repo $REPO && \
    echo "✅ RESEND_API_KEY" || echo "❌ Failed to set RESEND_API_KEY"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ ALL SECRETS CONFIGURED!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify
echo "Verifying secrets..."
echo ""
gh secret list --repo $REPO || echo "Could not list secrets"

echo ""
echo "🚀 Next Steps:"
echo "  1. Update DNS records (linear-hub.com.br → d1dmp1hz6w68o3.cloudfront.net)"
echo "  2. Update NEXT_PUBLIC_API_ENDPOINT in next.config.js (optional)"
echo "  3. git push origin main"
echo "  4. Monitor GitHub Actions deployment"
echo ""
