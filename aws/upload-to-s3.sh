#!/bin/bash

# Upload Next.js Build to S3 for Testing
# This script uploads the generated .next directory to S3 and invalidates CloudFront

set -e

# Configuration
S3_BUCKET="linear-hub-website-prod-1765543563"
CLOUDFRONT_DISTRIBUTION="EDQZRUQFXIMQ6"
REGION="us-east-1"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     Upload Next.js Build to S3 for CloudFront Testing       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if .next directory exists
if [ ! -d ".next" ]; then
    echo "❌ .next directory not found!"
    echo ""
    echo "Run: npm run build"
    exit 1
fi

echo "📦 Build directory found: ./.next"
echo ""

# Get project root
PROJECT_ROOT="$(pwd)"
BUILD_DIR="${PROJECT_ROOT}/.next"
PUBLIC_DIR="${PROJECT_ROOT}/public"

# Verify AWS credentials
echo "🔐 Verifying AWS credentials..."
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS credentials not configured!"
    echo "Run: aws configure"
    exit 1
fi
echo "✅ AWS credentials verified"
echo ""

# Upload .next/static files (with long cache)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣  Uploading static files (cache: 1 year)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d "${BUILD_DIR}/static" ]; then
    aws s3 sync "${BUILD_DIR}/static" "s3://${S3_BUCKET}/_next/static" \
        --region $REGION \
        --cache-control "public, max-age=31536000, immutable" \
        --delete \
        --exclude "*.map" \
        --exclude "*.js.map"
    echo "✅ Static files uploaded"
else
    echo "⚠️  No static files found"
fi
echo ""

# Upload public directory
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣  Uploading public assets (cache: 1 year)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d "${PUBLIC_DIR}" ]; then
    aws s3 sync "${PUBLIC_DIR}" "s3://${S3_BUCKET}/" \
        --region $REGION \
        --cache-control "public, max-age=31536000" \
        --delete \
        --exclude ".gitkeep"
    echo "✅ Public assets uploaded"
else
    echo "⚠️  No public directory found"
fi
echo ""

# Upload HTML files (.next/server/pages -> root with short cache)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣  Uploading HTML files (cache: 5 minutes)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d "${BUILD_DIR}/server/pages" ]; then
    # Find all HTML files and upload with short cache
    find "${BUILD_DIR}/server/pages" -name "*.html" | while read file; do
        # Get relative path
        rel_path="${file#${BUILD_DIR}/server/pages/}"
        s3_path="${rel_path}"
        
        # Remove trailing index.html if present
        s3_path="${s3_path//index.html/}"
        
        # Add trailing slash if not present
        if [[ ! "$s3_path" =~ /$ ]] && [ ! -z "$s3_path" ]; then
            s3_path="${s3_path}/"
        fi
        
        echo "  ⬆️  ${rel_path} → s3://${S3_BUCKET}/${s3_path}index.html"
        
        aws s3 cp "$file" "s3://${S3_BUCKET}/${s3_path}index.html" \
            --region $REGION \
            --cache-control "public, max-age=300" \
            --content-type "text/html; charset=utf-8"
    done
    echo "✅ HTML files uploaded"
else
    echo "⚠️  No HTML files found"
fi
echo ""

# Invalidate CloudFront cache
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣  Invalidating CloudFront cache..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

INVALIDATION=$(aws cloudfront create-invalidation \
    --distribution-id $CLOUDFRONT_DISTRIBUTION \
    --paths "/*" \
    --region $REGION)

INVALIDATION_ID=$(echo $INVALIDATION | grep -o '"Id": "[^"]*"' | head -1 | cut -d'"' -f4)

echo "✅ CloudFront invalidation created"
echo "   ID: $INVALIDATION_ID"
echo "   Status: Pending (usually completes in 1-2 minutes)"
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ UPLOAD COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🌐 Your site is now accessible via CloudFront:"
echo ""
echo "   https://d1dmp1hz6w68o3.cloudfront.net/"
echo ""
echo "   (May take 1-2 minutes for CloudFront to cache)"
echo ""
echo "📊 Test your site:"
echo ""
echo "   curl -I https://d1dmp1hz6w68o3.cloudfront.net/"
echo ""
echo "📝 Next steps:"
echo "   1. Add GitHub Secrets: ./aws/setup-github-secrets.sh"
echo "   2. Update DNS: registrador → d1dmp1hz6w68o3.cloudfront.net"
echo "   3. Deploy: git push origin main"
echo ""
