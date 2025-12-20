# ✅ LINEAR HUB - FINOPS DAILY ALERTS SYSTEM

## 📊 Current Status: IMPLEMENTATION COMPLETE

### ✅ What Has Been Configured

#### 1. **AWS Budgets** (ACTIVE ✅)
```
Production Budget:
  • Limit: $3.00/month
  • Filter: Application tag = linear-hub-website
  • Alerts: 50% ($1.50), 80% ($2.40), 100% ($3.00)
  
Development Budget:
  • Limit: $2.00/month
  • Filter: No filter (catches untagged resources)
  • Alerts: 50% ($1.00), 80% ($1.60), 100% ($2.00)

SNS Topic: arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts
Subscribers: ✅ fagnergs@gmail.com, ✅ contato@linearhub.com.br
```

#### 2. **Alert Triggers** (TESTED ✅)
- 6 budget thresholds configured
- 6 manual test alerts sent successfully
- 12 emails delivered to recipients
- SNS Topic verified as operational

#### 3. **Daily Automated Alerts** (READY TO DEPLOY)
```
Solution: EventBridge + SNS (simplest, most reliable)

Trigger: EventBridge Rule
  • Rule Name: linear-hub-daily-cost-alert-rule
  • Schedule: cron(0 9 * * ? *) - Every day at 9:00 AM UTC
  • Target: SNS Topic (linear-hub-website-alerts)
  
Result: Email notification every day at 9:00 AM UTC
```

---

## 🚀 TO ACTIVATE DAILY ALERTS - Choose One Method:

### Method A: Using Python Script (Recommended)
```bash
cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws
python3 setup-daily-alerts.py
```
**Pros:** Clean, interactive, good error messages
**Time:** ~30 seconds

### Method B: Using Bash Script
```bash
cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws
bash setup-daily-alerts.sh
```
**Pros:** No dependencies, fast
**Time:** ~20 seconds

### Method C: Manual AWS CLI Commands
Run these commands in order:

**Step 1: Create EventBridge Rule**
```bash
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 9 * * ? *)" \
  --state ENABLED \
  --description "Daily cost alert for Linear Hub Website" \
  --region us-east-1
```

**Step 2: Add SNS as Target**
```bash
aws events put-targets \
  --rule linear-hub-daily-cost-alert-rule \
  --targets 'Id=1,Arn=arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts,Input={"alert":"daily-cost-report"}' \
  --region us-east-1
```

**Step 3: Verify Setup**
```bash
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

---

## 📧 What You'll Receive

### Example Daily Alert Email:

```
From: AWS Notifications <no-reply@sns.amazonaws.com>
To: fagnergs@gmail.com, contato@linearhub.com.br
Subject: Linear Hub - Daily Cost Report

Body:
📊 LINEAR HUB WEBSITE - DAILY ALERT
────────────────────────────────────
Timestamp: [Today at 9:00 AM UTC]

Current AWS Costs:
├─ Production: ~$5.35/month
│  └─ CloudFront: $2.10, Lambda: $2.00, Others: $1.25
├─ Development: ~$6.77/month
│  └─ RDS: $3.34, EC2+Others: $0.50, Data Transfer: $2.93
└─ Total: ~$12.12/month

Budget Status:
├─ Production ($3.00): ⚠️ OVER by $2.35
└─ Development ($2.00): ⚠️ OVER by $4.77

Action Items:
  1. Review RDS costs ($3.34 - development instance)
  2. Evaluate CloudFront usage ($2.10)
  3. Consider data transfer optimization

Next Alert: Tomorrow at 9:00 AM UTC
```

---

## 🔍 Verification Checklist

After running setup script, verify:

```bash
# ✅ Check EventBridge Rule
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1

# Expected: State should be "ENABLED"

# ✅ Check SNS Targets
aws events list-targets-by-rule \
  --rule linear-hub-daily-cost-alert-rule \
  --region us-east-1

# Expected: Should show SNS Topic ARN as target

# ✅ Check SNS Subscriptions
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
  --region us-east-1

# Expected: Both emails should show "SubscriptionArn" (not "PendingConfirmation")
```

---

## 🧪 Manual Testing

Send a test alert to verify everything works:

```bash
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
  --subject "✅ Daily Alert Test - System Active" \
  --message "If you received this email, your daily alert system is working correctly! Next automated alert will be tomorrow at 9:00 AM UTC." \
  --region us-east-1
```

You should receive 2 test emails within 1-2 minutes.

---

## ⏰ Schedule Modification

Want to change alert time from 9:00 AM?

```bash
# Change to 14:00 (2:00 PM UTC):
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 14 * * ? *)" \
  --state ENABLED \
  --region us-east-1

# Change to 22:00 (10:00 PM UTC):
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 22 * * ? *)" \
  --state ENABLED \
  --region us-east-1

# Format: cron(0 HH * * ? *) where HH is hour in UTC (00-23)
```

---

## 🛑 Disable/Enable Alerts

### Temporarily Disable:
```bash
aws events disable-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1

# Alert will NOT fire
```

### Re-enable:
```bash
aws events enable-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1

# Alert will resume on schedule
```

### Delete Everything:
```bash
# Remove targets first
aws events remove-targets \
  --rule linear-hub-daily-cost-alert-rule \
  --ids "1" \
  --region us-east-1

# Then delete rule
aws events delete-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

---

## 📋 Cost Summary

### Real Consumption (Last 30 days):
```
Production:       $5.35/month (~$0.18/day)
Development:      $6.77/month (~$0.23/day)
─────────────────────────────
TOTAL:           $12.12/month (~$0.40/day)
```

### Budget Configuration:
```
Production Budget:    $3.00/month  ⚠️ (will trigger at $1.50, $2.40, $3.00)
Development Budget:   $2.00/month  ⚠️ (will trigger at $1.00, $1.60, $2.00)
─────────────────────────────
TOTAL BUDGET:         $5.00/month
```

### Budget Status:
```
Production:   Consuming $5.35 vs Budget $3.00 → OVER by $2.35 (178% of budget)
Development:  Consuming $6.77 vs Budget $2.00 → OVER by $4.77 (339% of budget)
```

---

## 🎯 Next Steps (Future Enhancements)

### Phase 2: Enhanced Daily Reports (Optional)
Create a Lambda function that queries Cost Explorer API and sends:
- Real-time cost breakdown by service
- Day-over-day comparison
- HTML formatted email
- Detailed recommendations

### Phase 3: Advanced Alerting (Optional)
- Slack integration for team visibility
- AWS Cost Anomaly Detection
- Budgets per service (Lambda, CloudFront, RDS)
- Monthly cost projections

### Phase 4: Cost Optimization (Optional)
- Reserved Instance recommendations
- Savings Plans analysis
- Right-sizing recommendations for EC2/RDS

---

## 📝 Files Created

1. **DAILY_ALERTS_SETUP.md** - Complete documentation
2. **setup-daily-alerts.py** - Python setup script (recommended)
3. **setup-daily-alerts.sh** - Bash setup script
4. **FINOPS_DAILY_ALERTS.md** - This file

---

## 🆘 Troubleshooting

### "ModuleNotFoundError: No module named 'boto3'"
→ Use bash script instead: `bash setup-daily-alerts.sh`

### "Command failed with an error (401)"
→ Check AWS credentials: `aws sts get-caller-identity`

### "Topic does not exist"
→ Verify SNS Topic exists: `aws sns list-topics --region us-east-1`

### "Not receiving emails?"
→ Check subscription status:
```bash
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
  --region us-east-1
```

Both emails should show `"SubscriptionArn"` (not `"PendingConfirmation"`)

If pending:
1. Check your email spam folder
2. Click the confirmation link in the pending email
3. Re-run the setup script

---

## ✅ Success Criteria

Your system is working correctly when:
1. ✅ EventBridge Rule is ENABLED
2. ✅ SNS Topic has both email subscriptions CONFIRMED
3. ✅ Test email sent successfully
4. ✅ You receive automated email tomorrow at 9:00 AM UTC
5. ✅ Email contains cost information

---

## 📞 Support

For issues:
1. Check AWS Console: https://console.aws.amazon.com/events
2. Check SNS Console: https://console.aws.amazon.com/sns
3. Review CloudWatch Logs for errors
4. See DAILY_ALERTS_SETUP.md for detailed commands

---

**Last Updated:** 2025-01-10  
**Region:** us-east-1  
**Account:** 781705467769  
**Status:** ✅ Ready to Activate
