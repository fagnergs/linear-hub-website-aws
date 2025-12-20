#!/bin/bash

# Daily Cost Alert - Setup Script
# This script configures EventBridge to send daily cost alerts via SNS

set -e

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  🚀 Setting up Daily Cost Alerts for Linear Hub Website       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

AWS_REGION="us-east-1"
ACCOUNT_ID="781705467769"
RULE_NAME="linear-hub-daily-cost-alert-rule"
SNS_TOPIC_ARN="arn:aws:sns:${AWS_REGION}:${ACCOUNT_ID}:linear-hub-website-alerts"
SCHEDULE="cron(0 9 * * ? *)"  # 9:00 AM UTC daily

echo "[1/3] Verifying AWS Credentials..."
IDENTITY=$(aws sts get-caller-identity --region $AWS_REGION 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ AWS Credentials: OK"
    ACCOUNT=$(echo $IDENTITY | grep -o '"Account": "[^"]*' | cut -d'"' -f4)
    echo "    Account: $ACCOUNT"
else
    echo "❌ AWS Credentials: FAILED"
    echo "   Please run: aws configure"
    exit 1
fi

echo ""
echo "[2/3] Creating EventBridge Rule..."
RULE_OUTPUT=$(aws events put-rule \
    --name "$RULE_NAME" \
    --schedule-expression "$SCHEDULE" \
    --state ENABLED \
    --description "Daily cost alert for Linear Hub Website" \
    --region "$AWS_REGION" 2>&1)

if echo "$RULE_OUTPUT" | grep -q "RuleArn"; then
    RULE_ARN=$(echo "$RULE_OUTPUT" | grep -o 'arn:aws:events:[^"]*')
    echo "✅ EventBridge Rule Created"
    echo "   Rule: $RULE_NAME"
    echo "   Schedule: Daily at 9:00 AM UTC"
    echo "   ARN: $RULE_ARN"
else
    echo "⚠️  Rule exists or error occurred"
    echo "$RULE_OUTPUT" | head -5
fi

echo ""
echo "[3/3] Configuring SNS Target..."

# Remove old targets if they exist
echo "    Removing old targets..."
aws events remove-targets \
    --rule "$RULE_NAME" \
    --ids "1" \
    --region "$AWS_REGION" 2>/dev/null || echo "    (No old targets)"

# Add SNS target
TARGET_OUTPUT=$(aws events put-targets \
    --rule "$RULE_NAME" \
    --targets "Id=1,Arn=$SNS_TOPIC_ARN,Input={\"alert\": \"daily-cost-report\"}" \
    --region "$AWS_REGION" 2>&1)

if echo "$TARGET_OUTPUT" | grep -q "FailedEntryCount"; then
    FAILED=$(echo "$TARGET_OUTPUT" | grep -o '"FailedEntryCount": [0-9]*' | grep -o '[0-9]*')
    if [ "$FAILED" = "0" ]; then
        echo "✅ SNS Target Configured"
        echo "   Target: $SNS_TOPIC_ARN"
    else
        echo "❌ Failed to add target: $TARGET_OUTPUT"
        exit 1
    fi
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ SETUP COMPLETE!                                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Your daily alerts are now configured:"
echo ""
echo "   ✅ EventBridge Rule: $RULE_NAME"
echo "   ✅ Schedule: Every day at 9:00 AM UTC"
echo "   ✅ Target: SNS Topic"
echo "   ✅ Recipients: 2 email addresses"
echo ""
echo "📧 You will receive emails with cost information every day at 9 AM UTC"
echo ""
echo "🔍 Verify your setup:"
echo "   aws events describe-rule --name $RULE_NAME --region $AWS_REGION"
echo ""
echo "🧪 Test manually:"
echo "   aws sns publish --topic-arn $SNS_TOPIC_ARN \\"
echo "     --subject 'Test Alert' --message 'If you see this, your system works!' \\"
echo "     --region $AWS_REGION"
echo ""
echo "📝 See DAILY_ALERTS_SETUP.md for more information"
echo ""
