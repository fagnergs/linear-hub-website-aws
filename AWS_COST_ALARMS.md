# 💰 AWS Cost Alarms - Linear Hub Website Production

**Status**: ✅ **CONFIGURED AND ACTIVE**

---

## 📋 Overview

Three-layer cost control strategy configured for Linear Hub Website production environment:

1. **Budget Notifications** - Hard limit with 3-tier alerts (50%, 80%, 100%)
2. **Cost Anomaly Detection** - Automated spike detection with daily notifications
3. **Email Subscriptions** - Direct email alerts to Fagner (fagner.gois@gmail.com)

---

## 1️⃣ AWS Budget Configuration

### Budget Details
```
Budget Name:        linear-hub-website-monthly
Monthly Limit:      $6.00 USD
Filter Type:        Resource Tags
Filter Criteria:    Application = linear-hub-website
Budget Type:        COST (actual spend only, not forecast)
Time Unit:          MONTHLY
Renewal:            Auto-renews on 1st of each month
```

### Budget Notifications

| Threshold | Trigger | Email Recipient | Purpose |
|-----------|---------|-----------------|---------|
| **50%** | $3.00 spent | fagner.gois@gmail.com | Early warning |
| **80%** | $4.80 spent | fagner.gois@gmail.com | Escalation alert |
| **100%** | $6.00 spent | fagner.gois@gmail.com | Critical limit reached |

### What to Expect
- 1st alert: When spending reaches **$3.00** (halfway through month)
- 2nd alert: When spending reaches **$4.80** (80% consumed)
- 3rd alert: When spending reaches **$6.00** (fully exhausted)

### Budget Logic
- **Baseline cost**: ~$5.35/month (current production infrastructure)
- **Safety margin**: $0.65/month (20% buffer for spikes)
- **No hard stop**: Budget alerts don't automatically halt services; they're notifications only

---

## 2️⃣ Cost Anomaly Detection

### Anomaly Monitor Configuration
```
Monitor Name:       Default-Services-Monitor (account-wide)
Monitor Type:       DIMENSIONAL (monitors all services)
Update Frequency:   Daily
Detection Method:   Machine learning based
```

### Anomaly Subscription Setup
```
Subscription Name:  linear-hub-website-anomaly-alerts
Detection Threshold: 20% deviation from baseline
Check Frequency:    DAILY
Notification Type:  EMAIL
Recipient:          fagner.gois@gmail.com
```

### How It Works
1. System learns historical spending patterns for the past 14 days
2. Each day, AWS compares actual spend vs. historical baseline
3. If spend deviates **>20%** from normal pattern → anomaly detected
4. Daily email sent to fagner.gois@gmail.com with anomaly details

### Example Scenarios
| Scenario | Daily Baseline | Actual Spend | Deviation | Alert Triggered? |
|----------|----------------|--------------|-----------|------------------|
| Normal day | $0.18 | $0.17 | -5.6% | ❌ No |
| Slight increase | $0.18 | $0.20 | +11% | ❌ No |
| Spike detection | $0.18 | $0.22 | +22% | ✅ Yes |
| Major incident | $0.18 | $0.35 | +94% | ✅ Yes |

---

## 3️⃣ Email Subscription & Confirmation

### Notification Flow
```
Budget Threshold Exceeded
    ↓
AWS Budgets Service
    ↓
Email to fagner.gois@gmail.com
    ↓
You Receive Alert

---

Anomaly Detected
    ↓
Cost Anomaly Detection
    ↓
Email to fagner.gois@gmail.com
    ↓
You Receive Alert
```

### Confirming Email Subscriptions
Check your email inbox for:
- **AWS Notifications** from budgets-notifications@aws.amazon.com (Budget setup)
- **AWS Cost Anomaly** notifications (Anomaly detection setup)

Click **"Confirm Subscription"** in each email to activate notifications.

---

## 4️⃣ Operational Guidelines

### What to Do When You Receive Budget Alerts

**50% Threshold Alert ($3.00)**
- ✅ Review the email for current spending breakdown
- ✅ Check which services are driving costs
- ✅ This is INFORMATIONAL - no immediate action needed
- ✅ Gives you 2 weeks to plan if needed

**80% Threshold Alert ($4.80)**
- 🟡 ESCALATION - Spending is approaching limit
- 🟡 Review services with highest cost
- 🟡 Consider if any scaling or optimization is needed
- 🟡 You have ~4 days before hard limit (if linear spending)

**100% Threshold Alert ($6.00)**
- 🔴 CRITICAL - Monthly budget fully consumed
- 🔴 New charges will exceed budget
- 🔴 IMMEDIATE ACTION: Review recent changes/incidents
- 🔴 Consider stopping non-critical services
- 🔴 Check for unexpected resource scaling or attacks

### What to Do When You Receive Anomaly Alerts

- ✅ Indicates **unusual spending pattern** detected
- ✅ May or may not indicate a problem
- ✅ Check email for:
  - Which services triggered the anomaly
  - Historical baseline vs. actual
  - Percentage deviation
- ✅ Investigate root cause:
  - Recent infrastructure changes?
  - Increased traffic?
  - Misconfiguration?
  - Security incident?

---

## 5️⃣ Integration with Operational Monitoring

### Cost Alarms vs. Infrastructure Alarms

| Concern | Tool | Metric | Action |
|---------|------|--------|--------|
| Service crashed | CloudWatch Alarm | Lambda errors ≥5 | Immediate investigation |
| High latency | CloudWatch Alarm | CloudFront >1000ms | Performance review |
| Cost spike | Budget Alert | $6.00 limit | Budget review |
| Anomaly | Anomaly Detection | 20% deviation | Investigation |

**Both layers are active and complementary:**
- CloudWatch → Infrastructure health issues
- Cost Alarms → Financial control & anomalies

---

## 6️⃣ Managing Your Alerts

### Viewing Budget Status (AWS Console)
```
AWS Console → Budgets → linear-hub-website-monthly
├─ Current month spending
├─ Forecast for month
├─ Notification history
└─ Budget alerts log
```

### Viewing Anomalies (AWS Console)
```
AWS Console → Cost Explorer → Cost Anomaly Detection
├─ Monitored resources
├─ Anomaly detection history
├─ Threshold settings
└─ Subscription details
```

### Updating Budget Threshold
```bash
# Increase budget to $8/month if needed
aws budgets update-budget \
  --account-id 781705467769 \
  --budget \
    BudgetName=linear-hub-website-monthly,\
    BudgetLimit={Amount=8,Unit=USD},\
    TimeUnit=MONTHLY,\
    BudgetType=COST,\
    CostFilters={TagKeyValue=[Application$linear-hub-website]}

# Decrease to $4/month if optimizing
aws budgets update-budget \
  --account-id 781705467769 \
  --budget \
    BudgetName=linear-hub-website-monthly,\
    BudgetLimit={Amount=4,Unit=USD},\
    TimeUnit=MONTHLY,\
    BudgetType=COST,\
    CostFilters={TagKeyValue=[Application$linear-hub-website]}
```

### Modifying Anomaly Detection Threshold
```bash
# Change from 20% to 15% detection threshold (more sensitive)
aws ce update-anomaly-subscription \
  --account-id 781705467769 \
  --subscription-arn 'arn:aws:ce::781705467769:anomaly-subscription/linear-hub-website-anomaly-alerts' \
  --threshold 15

# Change from 20% to 30% detection threshold (less noise)
aws ce update-anomaly-subscription \
  --account-id 781705467769 \
  --subscription-arn 'arn:aws:ce::781705467769:anomaly-subscription/linear-hub-website-anomaly-alerts' \
  --threshold 30
```

---

## 7️⃣ Cost Breakdown Reference

### Current Monthly Baseline (~$5.35)
```
CloudFront:         $2.10 (CDN delivery, 51.8KB assets)
Lambda:             $2.00 (contact form processing)
API Gateway:        $0.75 (API calls & data transfer)
S3:                 $0.35 (storage + requests)
Route 53:           $0.10 (DNS queries)
ACM:                $0.05 (certificate auto-renewal)
─────────────────────────────
TOTAL:              $5.35/month
```

### Scaling Impact
- **2x traffic**: +$4-5/month (CDN & Lambda scale)
- **10x traffic**: +$20-25/month (significant scaling)
- **Email deliveries**: +$0.10 per 50,000 Resend emails

### Budget Optimization Strategies
1. **CDN Caching**: Increase CloudFront cache TTL → reduce origin requests
2. **Lambda Performance**: Optimize contact form → reduce execution time
3. **Cost Explorer**: Review daily spend breakdown for anomalies
4. **Reserved Capacity**: Currently pay-as-you-go (good for variable traffic)

---

## 8️⃣ Quick Reference Commands

### View Budget Status
```bash
aws budgets describe-budget \
  --account-id 781705467769 \
  --budget-name linear-hub-website-monthly \
  --region us-east-1
```

### View Anomaly Subscriptions
```bash
aws ce list-anomaly-subscriptions --region us-east-1
```

### View Anomaly Detection History
```bash
aws ce list-anomalies \
  --date-interval Start=2025-01-01,End=2025-12-31 \
  --region us-east-1
```

### Describe Anomaly Monitor
```bash
aws ce get-anomaly-monitors --region us-east-1
```

### List All Budget Notifications
```bash
aws budgets describe-notifications-for-budget \
  --account-id 781705467769 \
  --budget-name linear-hub-website-monthly \
  --region us-east-1
```

---

## 9️⃣ FAQ

**Q: Will my services stop if I exceed the budget?**
A: No. AWS Budget alerts are **notifications only**. They won't automatically stop services. You must manually investigate and take action.

**Q: How long does it take for anomaly detection to start working?**
A: It requires ~14 days of baseline data. After that, daily checks begin.

**Q: Can I have multiple budgets for different projects?**
A: Yes! Each project can have its own budget. Currently configured for linear-hub-website only.

**Q: What if I accidentally increase infrastructure costs?**
A: The 50% alert gives you early warning. Review CloudWatch logs and Cost Explorer to identify the cause.

**Q: Can I change the $6/month threshold?**
A: Yes! Use `aws budgets update-budget` command or AWS Console to adjust.

**Q: Will anomaly detection catch a DDoS attack?**
A: Partially. It would detect the unusual spike, but CloudWatch Alarms are better for real-time incident response.

**Q: How do I export spending reports?**
A: Use Cost Explorer for custom queries, or AWS Console to download budget reports.

---

## 🔟 Maintenance Checklist

- [ ] Confirm email subscriptions from AWS (check inbox & spam folder)
- [ ] Review Cost Explorer monthly for cost breakdown
- [ ] Adjust budget threshold if baseline changes
- [ ] Update anomaly threshold if too many false positives
- [ ] Archive old monthly reports for compliance
- [ ] Review tagging compliance annually

---

**Configuration Date**: 2025-01-XX  
**Last Updated**: 2025-01-XX  
**Status**: ✅ All alerts active and receiving emails  
**Next Review**: 2025-02-XX (after first month of alerts)

---

*For more details, see [AWS_MONITORING_SETUP.md](AWS_MONITORING_SETUP.md) (infrastructure alarms) and [AWS_RESOURCE_GROUP.md](AWS_RESOURCE_GROUP.md) (cost per resource group).*
