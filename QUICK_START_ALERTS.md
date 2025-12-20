# 🚀 QUICK REFERENCE CARD - Daily Alerts

## ⚡ Activate in 1 Minute

```bash
# Go to project directory
cd /Users/fagnergs/Documents/GitHub/linear-hub-website-aws

# Run ONE of these:
python3 setup-daily-alerts.py    # Recommended
# OR
bash setup-daily-alerts.sh       # Alternative
# OR  
bash ACTIVATE_ALERTS.sh          # Manual commands
```

**That's it!** You'll have daily alerts by tomorrow at 9:00 AM UTC.

---

## 📊 What You're Activating

| Item | Details |
|------|---------|
| **What** | Daily cost alert emails |
| **When** | 9:00 AM UTC every single day |
| **Where** | fagnergs@gmail.com + contato@linearhub.com.br |
| **Why** | Track AWS costs against budget ($3 production + $2 dev) |
| **How** | EventBridge → SNS → Email |

---

## 💡 Quick Facts

- **Real AWS Costs:** $12.12/month
  - Production: $5.35 (CloudFront $2.10, Lambda $2.00)
  - Development: $6.77 (RDS $3.34, Data Transfer $2.93)

- **Your Budgets:** $5.00/month total
  - Production: $3.00 (currently $2.35 over)
  - Development: $2.00 (currently $4.77 over)

---

## 🧪 Test It

Send a test email:
```bash
aws sns publish \
  --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
  --subject "Test" \
  --message "If you see this, it works!" \
  --region us-east-1
```

Should receive 2 emails within 1-2 minutes.

---

## 🔧 Common Commands

### Check if active
```bash
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```
Look for `"State": "ENABLED"`

### Temporarily pause
```bash
aws events disable-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

### Resume
```bash
aws events enable-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

### Delete (if needed)
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

### Change time (example: 2:00 PM UTC instead of 9:00 AM)
```bash
aws events put-rule \
  --name linear-hub-daily-cost-alert-rule \
  --schedule-expression "cron(0 14 * * ? *)" \
  --state ENABLED \
  --region us-east-1
```

---

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| [FINOPS_SUMMARY.md](FINOPS_SUMMARY.md) | 📖 Start here |
| [FINOPS_DAILY_ALERTS.md](FINOPS_DAILY_ALERTS.md) | 🔍 Detailed setup |
| [DAILY_ALERTS_SETUP.md](DAILY_ALERTS_SETUP.md) | 📋 Full reference |
| [FINOPS_AUDIT_2025-12.md](FINOPS_AUDIT_2025-12.md) | 💰 Cost analysis |

---

## ❓ FAQ

**Q: When will I get the first email?**  
A: Tomorrow at 9:00 AM UTC (and every day after)

**Q: Can I change the time?**  
A: Yes, see "Change time" command above

**Q: What if I don't get an email?**  
A: Check spam folder, or verify subscriptions with:
```bash
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:781705467769:linear-hub-website-alerts \
  --region us-east-1
```

**Q: Can I add more email recipients?**  
A: Yes, via AWS SNS Console

**Q: Will this cost money?**  
A: No, EventBridge and SNS are part of AWS free tier for your usage

---

## 🎯 Next Steps

1. ✅ Run setup script (choose your method above)
2. ✅ Send test email to verify
3. ✅ Wait for tomorrow's automated alert
4. ✅ Review costs and plan optimizations
5. ⭐ Consider Phase 2 (enhanced HTML reports)

---

## 📞 Need Help?

Check documentation files or run:
```bash
# Test AWS credentials
aws sts get-caller-identity

# Verify SNS topic exists
aws sns list-topics --region us-east-1

# See EventBridge rule details
aws events describe-rule \
  --name linear-hub-daily-cost-alert-rule \
  --region us-east-1
```

---

**Status:** ✅ Ready to Activate  
**Time to Setup:** < 2 minutes  
**Time to First Alert:** ~24 hours (tomorrow @ 9:00 AM UTC)
