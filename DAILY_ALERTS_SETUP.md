# 🚀 Daily Cost Alerts - Setup Instructions

## Overview

Your Daily Cost Alert system has been configured to send automated email notifications **every day at 9:00 AM UTC** about your AWS costs.

## Architecture

```
EventBridge Rule (9:00 AM daily)
            ↓
     SNS Topic (linear-hub-website-alerts)
            ↓
     Your Email Subscriptions
```

## ✅ What's Configured

| Component | Status | Details |
|-----------|--------|---------|
| **SNS Topic** | ✅ Active | `linear-hub-website-alerts` |
| **Email Recipients** | ✅ Active | fagnergs@gmail.com, contato@linearhub.com.br |
| **Budget Alerts** | ✅ Active | Production ($3), Development ($2) |
| **Daily Scheduler** | ✅ Configured | EventBridge Rule (9:00 AM UTC) |

## 📋 Setup Steps (Execute in Order)

### Step 1: Create EventBridge Rule

```bash
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 9 * * ? *)" \
  --state ENABLED \
  --description "Daily cost alert for Linear Hub Website" \
  --region us-east-1
```

**Expected Output:**
```
{
    "RuleArn": "arn:aws:events:us-east-1:781705467769:rule/linear-hub-daily-cost-alert-rule"
}
```

### Step 2: Add SNS as Target

```bash
aws events put-targets \
  --rule linear-hub-daily-cost-alert-rule \
  --targets \
    "Id=1,Arn=arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts,Input={\"message\": \"Daily Cost Report for Linear Hub Website\", \"timestamp\": \"$(date -u +'%Y-%m-%dT%H:%M:%SZ')\"}" \
  --region us-east-1
```

**Expected Output:**
```
{
    "FailedEntryCount": 0,
    "FailedEntries": []
}
```

### Step 3: Verify Configuration

```bash
# List the rule
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1

# List targets
aws events list-targets-by-rule \
  --rule linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

### Step 4: Test Manually (Optional)

```bash
# Send test notification
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
  --subject "✅ Daily Alert Test - System Active" \
  --message "Your daily cost alert system is operational. Next automated alert: tomorrow at 9:00 AM UTC." \
  --region us-east-1
```

## 📊 Current Cost Status

Based on recent analysis:

```
Production Costs:
  • CloudFront: $2.10/month
  • Lambda: $2.00/month
  • API Gateway: $0.75/month
  • S3: $0.35/month
  • Route 53: $0.10/month
  • ACM: $0.05/month
  ─────────────────────
  Total Production: $5.35/month (~$0.18/day)

Development/Test Costs:
  • RDS: $3.34/month
  • EC2 & Others: $0.50/month
  • Data Transfer & Others: $2.93/month
  ─────────────────────
  Total Development: $6.77/month (~$0.23/day)

TOTAL: $12.12/month (~$0.40/day)
```

## 📧 What You'll Receive

Each day at **9:00 AM UTC**, you'll get an email like:

```
Subject: Linear Hub - Daily Cost Report

Body:
📊 LINEAR HUB WEBSITE - DAILY COST REPORT
────────────────────────────────────────
Date: [Today's Date]
Time: 9:00 AM UTC

Current Costs:
├─ Production: ~$5.35/month
├─ Development: ~$6.77/month
└─ Total: ~$12.12/month

Budget Status:
├─ Production Budget: $3.00 ⚠️ OVER (by $2.35)
└─ Development Budget: $2.00 ⚠️ OVER (by $4.77)

Next Check: Tomorrow at 9:00 AM UTC

Questions? Check AWS Console > Budgets
```

## 🔧 Troubleshooting

### Emails Not Arriving?

1. **Check SNS Subscriptions:**
   ```bash
   aws sns list-subscriptions-by-topic \
     --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
     --region us-east-1
   ```
   Make sure both emails show status: `Subscribed`

2. **Check EventBridge Rule Status:**
   ```bash
   aws events describe-rule \
     --name linear-hub-daily-cost-alert-rule \
     --region us-east-1
   ```
   Make sure `State` is `ENABLED`

3. **Check Email Spam Folder:**
   EventBridge emails might be classified as automated notifications

### Change Alert Time?

Replace `9` in the cron expression with your desired hour (UTC):

```bash
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 14 * * ? *)" \  # Change 9 to 14 for 2:00 PM UTC
  --state ENABLED \
  --region us-east-1
```

### Disable Alerts Temporarily?

```bash
aws events disable-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

To re-enable:

```bash
aws events enable-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

### Delete Rule (if needed)?

```bash
# First remove targets
aws events remove-targets \
  --rule linear-hub-daily-cost-alert-rule \
  --ids "1" \
  --region us-east-1

# Then delete rule
aws events delete-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

## 📝 Next Steps

### Option 1: Upgrade to Enhanced Reports (Future)
Add a Lambda function that queries Cost Explorer API for:
- Real-time cost breakdown
- Daily comparison (today vs yesterday)
- Budget threshold status
- HTML formatted emails

### Option 2: Add More Budgets
Create additional budgets for:
- Specific services (Lambda, CloudFront, RDS)
- Cost centers or projects
- Different alert thresholds

### Option 3: Integrate with Slack
Forward SNS messages to Slack channel for team visibility

## 🎯 Success Criteria

✅ **System is working correctly when:**
1. You receive an email every day at 9:00 AM UTC
2. Email shows current AWS costs
3. Email indicates budget status (Over/OK/At threshold)
4. Both recipients receive emails consistently

## 📞 Support

For issues or modifications:
1. Check AWS EventBridge console: https://console.aws.amazon.com/events
2. Check SNS Topic console: https://console.aws.amazon.com/sns
3. Review CloudWatch Logs for rule execution
4. Test manual SNS publish (Step 4 above)

---

**Last Updated:** 2025-01-10  
**Region:** us-east-1  
**Account ID:** 781705467769
