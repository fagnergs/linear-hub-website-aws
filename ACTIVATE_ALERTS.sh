#!/bin/bash
# QUICK ACTIVATION GUIDE - Copy & Paste Commands

# ============================================================================
# LINEAR HUB FINOPS - ACTIVATE DAILY ALERTS
# ============================================================================
# 
# Run these commands in your terminal to activate daily cost alerts
# Estimated time: 30 seconds
# 
# ============================================================================

# STEP 1: Create EventBridge Rule
# This rule will trigger every day at 9:00 AM UTC
echo "Creating EventBridge Rule..."
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 9 * * ? *)" \
  --state ENABLED \
  --description "Daily cost alert for Linear Hub Website" \
  --region us-east-1

echo "✅ Rule created"
echo ""

# STEP 2: Add SNS as Target
# This tells the rule to send notifications to your SNS Topic
echo "Adding SNS Topic as target..."
aws events put-targets \
  --rule linear-hub-daily-cost-alert-rule \
  --targets 'Id=1,Arn=arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts,Input={"alert":"daily-cost-report"}' \
  --region us-east-1

echo "✅ Target added"
echo ""

# STEP 3: Verify Configuration
echo "Verifying setup..."
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1 | grep -E "State|ScheduleExpression"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  ✅ ACTIVATION COMPLETE!                                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "Your daily alerts are now ACTIVE!"
echo ""
echo "📧 You will receive emails every day at 9:00 AM UTC"
echo "📊 Next alert: Tomorrow at 9:00 AM UTC"
echo ""
echo "🧪 OPTIONAL: Send a test email:"
echo ""
echo "   aws sns publish \\"
echo "     --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \\"
echo "     --subject 'Test Alert' \\"
echo "     --message 'If you see this, your system works!' \\"
echo "     --region us-east-1"
echo ""
