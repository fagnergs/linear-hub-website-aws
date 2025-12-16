# AWS Monitoring & Cost Tracking Setup

**Created:** 16 December 2025  
**Status:** ✅ Fully Configured  
**Environment:** Production (PRD)

---

## 🔔 CloudWatch Alarms

Three production-grade alarms are configured to monitor the critical components of the Linear Hub Website.

### Alarm #1: Lambda Function Errors

**Purpose:** Alert when the contact form Lambda function encounters errors  
**Function:** `linear-hub-contact-api`

```
Name:                   linear-hub-lambda-errors
Metric:                 Errors
Namespace:              AWS/Lambda
Statistic:              Sum
Period:                 300 seconds (5 minutes)
Threshold:              ≥ 5 errors
Comparison:             GreaterThanOrEqualToThreshold
Evaluation Periods:     1
Treat Missing Data:     NotBreaching
Alarm Actions:          SNS Topic (linear-hub-website-alerts)
Status:                 ✅ ACTIVE
```

**When it triggers:**
- 5 or more errors in a single 5-minute period
- Example: Contact form submissions failing repeatedly

---

### Alarm #2: API Gateway 5xx Errors

**Purpose:** Alert when the API returns HTTP 5xx errors  
**API:** `linear-hub-api` (ID: `xsp6ymu9u6`)

```
Name:                   linear-hub-api-gateway-5xx-errors
Metric:                 5XXError
Namespace:              AWS/ApiGateway
Statistic:              Sum
Period:                 300 seconds (5 minutes)
Threshold:              ≥ 10 errors
Comparison:             GreaterThanOrEqualToThreshold
Evaluation Periods:     1
Treat Missing Data:     NotBreaching
Alarm Actions:          SNS Topic (linear-hub-website-alerts)
Status:                 ✅ ACTIVE
```

**When it triggers:**
- 10 or more 5xx errors in a 5-minute period
- Example: API Gateway or Lambda crashing

---

### Alarm #3: CloudFront Distribution Health

**Purpose:** Alert when CloudFront origin latency is too high  
**Distribution:** `E10LMATIX2UNW6` (linear-hub.com.br)

```
Name:                   linear-hub-cloudfront-distribution-health
Metric:                 OriginLatency
Namespace:              AWS/CloudFront
Statistic:              Average
Period:                 300 seconds (5 minutes)
Threshold:              > 1000 milliseconds
Comparison:             GreaterThanThreshold
Evaluation Periods:     2 (= 10 minutes total)
Treat Missing Data:     NotBreaching
Alarm Actions:          SNS Topic (linear-hub-website-alerts)
Status:                 ✅ ACTIVE
```

**When it triggers:**
- Average latency exceeds 1000ms for 10 consecutive minutes
- Example: S3 origin is slow or unreachable

---

## 📧 SNS Topic for Notifications

### Topic Details

```
Name:           linear-hub-website-alerts
ARN:            arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts
Region:         us-east-1
Display Name:   Linear Hub Website Alerts
Status:         ✅ ACTIVE
```

### Subscriptions

All three CloudWatch alarms send notifications to this topic.

**To receive email notifications:**

1. Go to AWS Console → **SNS**
2. Navigate to **Topics** → `linear-hub-website-alerts`
3. Click **Create subscription**
4. Select Protocol: **Email**
5. Enter your email address
6. Confirm the subscription in your email inbox

---

## 💰 Cost Explorer Queries

### Query #1: Costs by Service (Daily)

**Purpose:** Track costs broken down by AWS service on a daily basis

```json
{
  "TimePeriod": {
    "Start": "2025-12-01",
    "End": "2025-12-31"
  },
  "Granularity": "DAILY",
  "Filter": {
    "Tags": {
      "Key": "Application",
      "Values": ["linear-hub-website"]
    }
  },
  "Metrics": ["BlendedCost"],
  "GroupBy": [
    {
      "Type": "DIMENSION",
      "Key": "SERVICE"
    }
  ]
}
```

**Access:**
1. AWS Console → **Cost Explorer**
2. **Custom Reports** tab
3. Apply filters matching the query above

**Services tracked:**
- API Gateway
- Lambda
- CloudFront
- S3
- Route 53
- ACM

---

### Query #2: Monthly Cost Summary

**Purpose:** Track total monthly costs to monitor budgets

```json
{
  "TimePeriod": {
    "Start": "2025-12-01",
    "End": "2025-12-31"
  },
  "Granularity": "MONTHLY",
  "Metrics": ["BlendedCost"]
}
```

**Access:**
1. AWS Console → **Cost Explorer**
2. **Custom Reports** tab
3. Set Granularity to "Monthly"

**Monthly baseline estimate:** ~$5.35/month

---

## 🎯 Recommended Thresholds

| Metric | Threshold | Rationale |
|--------|-----------|-----------|
| Lambda Errors | ≥ 5 | Allows 1-2 errors without alerting; 5+ indicates a problem |
| API 5xx Errors | ≥ 10 | Contact form can handle brief failures; 10+ is critical |
| CloudFront Latency | > 1000ms | S3 typical latency is <100ms; >1000ms indicates issues |

---

## 📊 Monitoring Dashboard

You can create a CloudWatch Dashboard to visualize all metrics in one place:

```bash
aws cloudwatch put-dashboard \
  --dashboard-name linear-hub-website-monitoring \
  --dashboard-body file://dashboard-config.json
```

**Recommended widgets:**
1. Lambda Errors metric
2. API Gateway 5xx Errors metric
3. CloudFront OriginLatency metric
4. Cost anomaly detection
5. Top services by cost

---

## 🔧 Managing Alarms

### List all alarms

```bash
aws cloudwatch describe-alarms \
  --alarm-names \
    linear-hub-lambda-errors \
    linear-hub-api-gateway-5xx-errors \
    linear-hub-cloudfront-distribution-health \
  --region us-east-1
```

### Disable an alarm temporarily

```bash
aws cloudwatch disable-alarm-actions \
  --alarm-names linear-hub-lambda-errors \
  --region us-east-1
```

### Re-enable an alarm

```bash
aws cloudwatch enable-alarm-actions \
  --alarm-names linear-hub-lambda-errors \
  --region us-east-1
```

### Delete an alarm

```bash
aws cloudwatch delete-alarms \
  --alarm-names linear-hub-lambda-errors \
  --region us-east-1
```

---

## 💡 Best Practices

### 1. Regular Review
- Review alarms monthly to adjust thresholds based on actual patterns
- Check Cost Explorer reports weekly to catch unexpected charges early

### 2. Escalation
- Start with email notifications (SNS)
- Consider adding SMS or PagerDuty integration for critical issues
- Implement on-call rotation for production issues

### 3. Alert Tuning
- Avoid alert fatigue by setting appropriate thresholds
- Use evaluation periods to filter out transient spikes
- Document reasons for threshold changes

### 4. Cost Management
- Review Cost Explorer queries to identify optimization opportunities
- Set up AWS Budgets for additional cost control
- Schedule monthly cost review meetings

### 5. Documentation
- Keep this document updated when making changes
- Document any threshold adjustments with reasons
- Maintain an alarm runbook for on-call engineers

---

## 🚀 Next Steps

1. **✅ Subscribe to SNS topic** for email notifications
2. **Create a CloudWatch Dashboard** to visualize all metrics
3. **Set up AWS Budgets** to receive alerts on cost overages
4. **Document escalation procedures** for when alarms trigger
5. **Schedule monthly reviews** of both alarms and costs

---

## 📞 Support

For issues with alarms or cost tracking:
1. Check CloudWatch Logs for detailed error information
2. Review the CloudWatch Alarms console for alarm state history
3. Consult AWS documentation for metric explanations
4. Contact DevOps team for assistance

---

## 📝 Change Log

| Date | Change | Author |
|------|--------|--------|
| 2025-12-16 | Initial setup of 3 CloudWatch Alarms + SNS Topic + Cost Explorer queries | DevOps |

---

**Last Updated:** 16 December 2025  
**Status:** Production Ready  
**Review Schedule:** Monthly
