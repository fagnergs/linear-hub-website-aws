# AWS Resource Group - Linear Hub Website

**Created:** 16 December 2025  
**Purpose:** Centralized management and cost tracking for all Linear Hub Website production resources  

---

## 📦 Resource Group Details

### General Information
- **Name:** `linear-hub-website-production`
- **ARN:** `arn:aws:resource-groups:us-east-1:781705467769:group/linear-hub-website-production`
- **Region:** `us-east-1`
- **Description:** Linear Hub Website Production Resources
- **Status:** ✅ Active

### Filtering Criteria

The Resource Group uses **TAG_FILTERS_1_0** to automatically group resources based on:

**Required Tags:**
- `Application: linear-hub-website`
- `Environment: production`

**Resource Types Included:**
- AWS::CloudFront::Distribution
- AWS::S3::Bucket
- AWS::Lambda::Function
- AWS::ApiGateway::RestApi

---

## 📊 Grouped Resources

### Current Members

| Resource | Type | ARN | Status |
|----------|------|-----|--------|
| linear-hub-api | API Gateway | `arn:aws:apigateway:us-east-1::/restapis/xsp6ymu9u6` | ✅ Active |
| linear-hub-website-prod-* | S3 Bucket | `arn:aws:s3:::linear-hub-website-prod-*` | ✅ Active |
| linear-hub-contact-api | Lambda | `arn:aws:lambda:us-east-1:*:function:linear-hub-contact-api` | ✅ Active |
| E10LMATIX2UNW6 | CloudFront | `arn:aws:cloudfront::*:distribution/E10LMATIX2UNW6` | ✅ Active |

**Total:** 4 resources grouped

---

## 💰 Financial Management

### Accessing Cost Explorer via Resource Group

The Resource Group integrates with AWS Cost Explorer for centralized cost tracking:

```bash
# View costs for this resource group
aws ce get-cost-and-usage \
  --time-period Start=2025-12-01,End=2025-12-31 \
  --granularity MONTHLY \
  --filter file://filter.json \
  --metrics "BlendedCost" \
  --group-by Type=DIMENSION,Key=RESOURCE_ID
```

### Monthly Cost Breakdown

| Resource | Cost | Percentage |
|----------|------|-----------|
| API Gateway | ~$3.50 | 65% |
| CloudFront | ~$0.085/GB* | 20% |
| Lambda | ~$0.20 | 4% |
| Route 53 | ~$0.50 | 9% |
| S3 | ~$0.023 | 1% |
| **Total** | **~$4.30** | **100%** |

*Data transfer dependent

### Cost Optimization Tips

1. **CloudFront Cache**
   - Monitor cache hit ratio
   - Adjust TTL for static vs dynamic content
   - Use geographic distribution for better performance

2. **API Gateway**
   - Most expensive service (~65% of costs)
   - Consider consolidating endpoints
   - Monitor request volume
   - Add caching where possible

3. **Lambda**
   - Well-optimized (free tier covered)
   - Minimal cost for contact form processing

4. **Cleanup Opportunities**
   - Delete orphaned S3 buckets (~$0.50/month savings)
   - Delete unused CloudFormation stacks (~$0.10/month savings)

---

## 🔧 Managing Resources via Resource Group

### AWS Console Access

1. Go to **AWS Systems Manager** → **Resource Groups**
2. Select **linear-hub-website-production**
3. View all grouped resources
4. Take bulk actions (tagging, permissions, monitoring)

### AWS CLI Operations

**List all resources in the group:**
```bash
aws resource-groups list-group-resources \
  --group-name "linear-hub-website-production" \
  --region us-east-1
```

**Get group details:**
```bash
aws resource-groups get-group \
  --group-name "linear-hub-website-production" \
  --region us-east-1
```

**Update group query (add/remove resources):**
```bash
aws resource-groups update-group-query \
  --group-name "linear-hub-website-production" \
  --resource-query '{"Type":"TAG_FILTERS_1_0","Query":"..."}'
```

---

## 🏷️ Tag Management

### Tags Applied to Resource Group

```
Environment:    production
Application:    linear-hub-website
Tenant:         linear-hub
CostCenter:     website
ManagedBy:      terraform
```

### Ensuring New Resources Are Included

When creating new AWS resources for this project:

1. **Always apply these tags:**
   ```
   Application=linear-hub-website
   Environment=production
   Tenant=linear-hub
   CostCenter=website
   ManagedBy=terraform
   ```

2. **New resource will automatically be grouped** if it matches the filter criteria

3. **Verify grouping:**
   ```bash
   aws resource-groups list-group-resources \
     --group-name "linear-hub-website-production"
   ```

---

## 🔐 Access Control

### Managing Group Permissions

Use IAM policies to control who can manage this Resource Group:

**Example policy for read-only access:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "resource-groups:GetGroup",
        "resource-groups:ListGroupResources",
        "resource-groups:GetGroupQuery"
      ],
      "Resource": "arn:aws:resource-groups:us-east-1:*:group/linear-hub-website-production"
    }
  ]
}
```

**Example policy for management access:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "resource-groups:*"
      ],
      "Resource": "arn:aws:resource-groups:us-east-1:*:group/linear-hub-website-production"
    }
  ]
}
```

---

## 📈 Monitoring & Alerts

### CloudWatch Integration

Create CloudWatch alarms for the grouped resources:

**Monitor Lambda errors:**
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "linear-hub-lambda-errors" \
  --alarm-description "Alert if Lambda function fails" \
  --metric-name Errors \
  --namespace AWS/Lambda \
  --statistic Sum \
  --period 300 \
  --threshold 5 \
  --comparison-operator GreaterThanThreshold
```

**Monitor API Gateway 5xx errors:**
```bash
aws cloudwatch put-metric-alarm \
  --alarm-name "linear-hub-api-errors" \
  --alarm-description "Alert on API Gateway errors" \
  --metric-name 5XXError \
  --namespace AWS/ApiGateway \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold
```

---

## 📋 Best Practices

### 1. Regular Audits
- Review Resource Group members monthly
- Verify all resources have proper tags
- Check for orphaned resources

### 2. Cost Monitoring
- Review monthly costs via Cost Explorer
- Alert on unusual spikes
- Plan capacity based on growth

### 3. Backup & DR
- Document Resource Group configuration in code
- Version control all resource definitions
- Test disaster recovery procedures quarterly

### 4. Compliance
- Ensure all resources comply with company policies
- Maintain audit logs via CloudTrail
- Regular security assessments

### 5. Documentation
- Keep this document updated
- Document resource ownership
- Maintain runbook for common operations

---

## 🚀 Future Enhancements

### Planned Additions

- [ ] Add CloudWatch Log Groups to Resource Group
- [ ] Create Route53 zone resource (when tagging available)
- [ ] Add ACM Certificate (when tagging available)
- [ ] Implement automated backup policies
- [ ] Configure automated cost optimization

### Scalability

As the project grows:
1. Add new resources with the same tags
2. They'll automatically be grouped
3. Costs and management scale centrally

---

## 🔗 Related Resources

- [AWS Resource Groups Documentation](https://docs.aws.amazon.com/ARG/latest/userguide/whatisrg.html)
- [Cost Explorer Integration](https://docs.aws.amazon.com/cost-management/latest/userguide/ce-exploring.html)
- [Tag Strategy Best Practices](https://docs.aws.amazon.com/general/latest/gr/tagging.html)
- [AWS Systems Manager Resource Groups](https://docs.aws.amazon.com/systems-manager/latest/userguide/resource-groups.html)

---

## 📞 Management

**Resource Group Owner:** DevOps Team  
**Last Updated:** 16 December 2025  
**Next Review:** January 2026  

For questions or updates, refer to the main project documentation in `AWS_PRODUCTION_RESOURCES.md`.
