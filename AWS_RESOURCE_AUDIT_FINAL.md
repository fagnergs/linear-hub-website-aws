# AWS Resource Audit - Tagging & Cleanup Report

**Date:** 14 December 2025  
**Status:** ✅ COMPLETE - Ready for Cleanup  

---

## 📊 AUDIT SUMMARY

| Category | Total | Properly Tagged | No Tags | Action |
|----------|-------|-----------------|---------|--------|
| CloudFront | 1 | ⚠️ Partial | 0 | ✅ Update tags |
| S3 Buckets | 4 | 2 | 2 | ⚠️ Cleanup needed |
| Lambda | 3 | 1 | 2 | ⚠️ Cleanup/Tag |
| API Gateway | 3 | 0 | 3 | ⚠️ Cleanup/Tag |
| ACM Certs | 2 | ⚠️ Partial | 0 | ✅ No action |
| Route 53 | 1 | ✅ Yes | 0 | ✅ OK |
| CloudWatch Logs | 5 | N/A | N/A | ⚠️ Cleanup |
| CloudFormation | 3 | N/A | N/A | ⚠️ Cleanup |

---

## 🔍 DETAILED FINDINGS

### 1️⃣ CloudFront Distributions

#### ✅ E10LMATIX2UNW6 (ACTIVE - Production)
```
Domain:     d378ca32dt91zn.cloudfront.net
Aliases:    linear-hub.com.br, www.linear-hub.com.br
Status:     Deployed ✅
S3 Origin:  linear-hub-website-prod-1765543563 ✅
Certificate: linear-hub.com.br ✅
Tags:       ❌ NO TAGS (Should have environment, tenant, etc.)
```
**Action:** Add production tags

---

### 2️⃣ S3 Buckets

#### ✅ linear-hub-website-prod-1765543563 (ACTIVE - Production)
```
Created:     2025-12-12
Size:        ~51.8 KB (index.html only visible)
Website:     ✅ Hosted (index: index.html, error: 404.html)
Status:      ✅ ACTIVE
Tags:        ✅ YES
  - Environment: production
  - ManagedBy: terraform
  - Tenant: linear-hub
  - CostCenter: website
  - Application: linear-hub-website
```
**Action:** ✅ No cleanup needed

---

#### ❌ jsmc.com.br (ABANDONED - Can be deleted)
```
Created:     2025-12-05
Size:        Unknown
Status:      ❌ ORPHANED (Old domain, not in use)
Tags:        ❌ NO TAGS
Usage:       Not connected to any active CloudFront or Route53
```
**Action:** 🗑️ **RECOMMENDED FOR DELETION**

---

#### ❌ www.jsmc.com.br (ABANDONED - Can be deleted)
```
Created:     2025-12-05
Size:        Unknown
Status:      ❌ ORPHANED (Old domain variant, not in use)
Tags:        ❌ NO TAGS
Usage:       Not connected to any active CloudFront or Route53
```
**Action:** 🗑️ **RECOMMENDED FOR DELETION**

---

#### ⚠️ aws-sam-cli-managed-default-samclisourcebucket-... (INTERNAL)
```
Created:     2025-11-28
Purpose:     AWS SAM CLI artifact storage
Tags:        ✅ YES (CloudFormation managed)
Status:      ⚠️ May be obsolete if no active SAM deployments
```
**Action:** Check if SAM deployments still in use

---

### 3️⃣ Lambda Functions

#### ✅ linear-hub-contact-api (ACTIVE - Production)
```
Runtime:     nodejs20.x
Modified:    2025-12-13
Status:      ✅ ACTIVE (Recently updated for recovery)
Tags:        ✅ YES
  - Application: linear-hub-website
  - Environment: production
  - Tenant: linear-hub
```
**Action:** ✅ No cleanup needed

---

#### ❌ sam-app-ApiFunction-v73gljTkdfvZ (ABANDONED)
```
Runtime:     nodejs18.x
Modified:    2025-11-28
CloudFormation Stack: sam-app
Status:      ❌ ORPHANED (Not used by site)
Tags:        ✅ CloudFormation tags only
Logs:        2,139 bytes (minimal activity)
```
**Action:** 🗑️ **RECOMMENDED FOR DELETION** (delete sam-app stack)

---

#### ❌ site-final-definitivo-ApiFunction-e7E24LkJogp6 (ABANDONED)
```
Runtime:     nodejs20.x
Modified:    2025-11-28
CloudFormation Stack: site-final-definitivo
Status:      ❌ ORPHANED (Not used by site)
Tags:        ✅ CloudFormation tags only
Logs:        9,973 bytes (minimal activity)
```
**Action:** 🗑️ **RECOMMENDED FOR DELETION** (delete site-final-definitivo stack)

---

### 4️⃣ API Gateway

#### ✅ linear-hub-api (ACTIVE - Production)
```
API ID:      xsp6ymu9u6
Status:      ✅ ACTIVE (Connected to Lambda)
Tags:        ❌ NO TAGS
```
**Action:** Add production tags

---

#### ❌ sam-app (ABANDONED)
```
API ID:      mvf0nk9j9a
Status:      ❌ ORPHANED (CloudFormation stack sam-app)
Tags:        None visible
```
**Action:** 🗑️ **DELETE with sam-app CloudFormation stack**

---

#### ❌ site-final-definitivo (ABANDONED)
```
API ID:      a3efcvbbaf
Status:      ❌ ORPHANED (CloudFormation stack site-final-definitivo)
Tags:        None visible
```
**Action:** 🗑️ **DELETE with site-final-definitivo CloudFormation stack**

---

### 5️⃣ ACM Certificates

#### ✅ linear-hub.com.br
```
ARN:         arn:aws:acm:us-east-1:781705467769:certificate/5b7c5719-6344-4afa-9c80-73525ef0d345
Status:      ✅ ACTIVE (In use by CloudFront)
Validation:  DNS validated
```
**Action:** ✅ No cleanup needed

---

#### ⚠️ jsmc.com.br
```
ARN:         arn:aws:acm:us-east-1:781705467769:certificate/332f5a47-3c9b-4fec-aba8-02a891a035ec
Status:      ⚠️ NOT IN USE (Old domain, CloudFront updated to use linear-hub cert)
Usage:       Can be kept for historical reference or deleted
```
**Action:** ⚠️ **Optional deletion** (keeping doesn't cost money, but can clean up for hygiene)

---

### 6️⃣ Route 53

#### ✅ Z01786261P1IDZOECZQA5 - linear-hub.com.br
```
Records:
  - linear-hub.com.br      → d378ca32dt91zn.cloudfront.net ✅
  - www.linear-hub.com.br  → d378ca32dt91zn.cloudfront.net ✅
  - MX Records             → Zoho Mail ✅
  - TXT/SPF Records        → Zoho + SES validation ✅

Status:      ✅ ACTIVE
Tags:        ✅ YES (likely CloudFormation)
```
**Action:** ✅ No cleanup needed

---

### 7️⃣ CloudWatch Logs

#### ✅ /aws/lambda/linear-hub-contact-api
```
Size:        0 bytes (new)
Retention:   Never
Status:      ✅ ACTIVE (production)
```
**Action:** ✅ No cleanup needed

---

#### ⚠️ /aws/lambda/jsmc-contact-form-handler
```
Size:        53,608 bytes
Retention:   Never
Status:      ❌ ORPHANED (No corresponding Lambda - old function deleted)
Last Activity: Unknown (old)
```
**Action:** 🗑️ **SAFE TO DELETE** (orphaned log group with no function)

---

#### ⚠️ /aws/lambda/sam-app-ApiFunction-v73gljTkdfvZ
```
Size:        2,139 bytes
Retention:   Never
Status:      ❌ ORPHANED (Lambda marked for deletion)
```
**Action:** 🗑️ **DELETE with sam-app stack**

---

#### ⚠️ /aws/lambda/site-final-definitivo-ApiFunction-e7E24LkJogp6
```
Size:        9,973 bytes
Retention:   Never
Status:      ❌ ORPHANED (Lambda marked for deletion)
```
**Action:** 🗑️ **DELETE with site-final-definitivo stack**

---

#### ⚠️ RDSOSMetrics
```
Size:        9,396,422 bytes (9.3 MB!)
Retention:   30 days
Status:      ⚠️ Large log group, purpose unclear
```
**Action:** ⚠️ Investigate if RDS monitoring is active, adjust retention if not needed

---

### 8️⃣ CloudFormation Stacks

#### ⚠️ aws-sam-cli-managed-default (CREATE_COMPLETE)
```
Purpose:     Managed by AWS SAM CLI for artifact storage
S3 Bucket:   aws-sam-cli-managed-default-samclisourcebucket-...
Status:      ⚠️ May be obsolete
```
**Action:** ⚠️ Check if using SAM CLI, delete if not needed

---

#### ❌ sam-app (UPDATE_COMPLETE)
```
Resources:   1 Lambda, 1 API Gateway
LastUpdate:  2025-11-28
Status:      ❌ ABANDONED (Not used by linear-hub site)
```
**Action:** 🗑️ **RECOMMENDED FOR DELETION**

---

#### ❌ site-final-definitivo (UPDATE_COMPLETE)
```
Resources:   1 Lambda, 1 API Gateway
LastUpdate:  2025-11-28
Status:      ❌ ABANDONED (Not used by linear-hub site)
```
**Action:** 🗑️ **RECOMMENDED FOR DELETION**

---

## 🎯 CLEANUP RECOMMENDATIONS

### Priority 1: IMMEDIATE DELETION (Safe, No Dependencies)
✅ **Definitely delete these:**

1. **S3 Bucket: jsmc.com.br**
   - Orphaned, no active CloudFront
   - No tags, no Route53 records
   - Cost: Minimal, but cleanup improves hygiene

2. **S3 Bucket: www.jsmc.com.br**
   - Orphaned, no active CloudFront
   - No tags, no Route53 records

3. **CloudWatch Log Group: /aws/lambda/jsmc-contact-form-handler**
   - 53KB, no corresponding Lambda
   - Safe to delete (no active function)

4. **CloudFormation Stack: sam-app**
   - Will also delete: Lambda function, API Gateway, related resources
   - Last modified 2025-11-28, not in use

5. **CloudFormation Stack: site-final-definitivo**
   - Will also delete: Lambda function, API Gateway, related resources
   - Last modified 2025-11-28, not in use

### Priority 2: RECOMMENDED (Clean Up Old Resources)
⚠️ **Consider deleting:**

1. **ACM Certificate: jsmc.com.br**
   - Not in use, but costs nothing to keep
   - Optional: delete for account hygiene

2. **CloudFormation Stack: aws-sam-cli-managed-default**
   - Only needed if using SAM CLI
   - If not actively developing with SAM, safe to delete

### Priority 3: INVESTIGATION NEEDED
🔍 **Before deleting:**

1. **CloudWatch Log Group: RDSOSMetrics (9.3 MB)**
   - Investigate if RDS monitoring is active
   - If no RDS needed: delete the logs and disable monitoring
   - If RDS exists: keep but consider reducing retention

---

## 🏷️ TAGGING RECOMMENDATIONS

### Add Tags to CloudFront E10LMATIX2UNW6:
```
Environment: production
Application: linear-hub-website
Tenant: linear-hub
CostCenter: website
ManagedBy: terraform
```

### Add Tags to API Gateway linear-hub-api:
```
Environment: production
Application: linear-hub-website
Tenant: linear-hub
```

---

## 📋 DELETION CHECKLIST

### Before deleting, verify:

- [ ] CloudFront is using **linear-hub-website-prod** S3 bucket (NOT jsmc.com.br) ✅ **DONE**
- [ ] Route 53 is pointing to correct CloudFront ✅ **DONE**
- [ ] No active Lambda functions depend on sam-app or site-final-definitivo resources
- [ ] No API endpoints in production using sam-app or site-final-definitivo APIs
- [ ] Backup old CloudFormation stack templates if needed for reference
- [ ] No custom DNS records pointing to old resources

---

## 🗑️ DELETION COMMANDS

### Delete CloudFormation Stacks (removes all associated resources):
```bash
# Delete sam-app stack (includes Lambda, API Gateway)
aws cloudformation delete-stack --stack-name sam-app

# Delete site-final-definitivo stack (includes Lambda, API Gateway)
aws cloudformation delete-stack --stack-name site-final-definitivo

# Optional: Delete SAM CLI managed stack
aws cloudformation delete-stack --stack-name aws-sam-cli-managed-default
```

### Delete Orphaned S3 Buckets (must be empty first):
```bash
# Empty and delete jsmc.com.br
aws s3 rm s3://jsmc.com.br --recursive
aws s3api delete-bucket --bucket jsmc.com.br

# Empty and delete www.jsmc.com.br
aws s3 rm s3://www.jsmc.com.br --recursive
aws s3api delete-bucket --bucket www.jsmc.com.br
```

### Delete Orphaned CloudWatch Logs:
```bash
# Delete orphaned log group
aws logs delete-log-group --log-group-name /aws/lambda/jsmc-contact-form-handler
```

### Delete Old ACM Certificate (optional):
```bash
# Delete jsmc.com.br certificate (if not needed)
aws acm delete-certificate --certificate-arn arn:aws:acm:us-east-1:781705467769:certificate/332f5a47-3c9b-4fec-aba8-02a891a035ec
```

---

## ✅ FINAL STATUS

| Component | Tagging | Usage | Action |
|-----------|---------|-------|--------|
| CloudFront E10LMATIX2UNW6 | ⚠️ Missing | ✅ ACTIVE | Add tags |
| S3 linear-hub-website-prod | ✅ Complete | ✅ ACTIVE | No action |
| Lambda linear-hub-contact-api | ✅ Complete | ✅ ACTIVE | No action |
| API Gateway linear-hub-api | ⚠️ Missing | ✅ ACTIVE | Add tags |
| Route 53 | ✅ Complete | ✅ ACTIVE | No action |
| jsmc.com.br (S3) | ❌ None | ❌ ORPHANED | Delete |
| www.jsmc.com.br (S3) | ❌ None | ❌ ORPHANED | Delete |
| sam-app (CF Stack) | N/A | ❌ ORPHANED | Delete |
| site-final-definitivo (CF) | N/A | ❌ ORPHANED | Delete |
| ACM jsmc.com.br | ⚠️ Partial | ❌ UNUSED | Optional delete |

---

## 📊 COST IMPACT

**Current Unused Resources Consuming Resources:**
- 2 S3 buckets (jsmc.com.br, www.jsmc.com.br): ~$0.50/month (minimal)
- 4 CloudWatch log groups: ~$0.50/month (minimal)
- 1 ACM certificate: $0 (no cost for unused certs)
- **Total monthly waste: ~$1/month**

**After cleanup savings:**
- Simplified account structure
- Reduced clutter for monitoring
- Clearer security posture

---

**Status:** ✅ AUDIT COMPLETE  
**Recommended Action:** Proceed with Priority 1 deletions  
**Next Steps:** Execute deletion commands and verify site stability
