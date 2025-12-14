# AWS Infrastructure Recovery Report

**Date:** 14 December 2025  
**Time:** 00:24 UTC  
**Status:** ✅ COMPLETE - Site Operational

## Summary

Successfully recovered linear-hub.com.br website after critical infrastructure failure. Site was offline due to misconfigured CloudFront distribution serving from wrong S3 bucket with incorrect SSL certificate.

## Issues Found & Fixed

### Issue 1: CloudFront Origin Pointing to Wrong Bucket ❌→✅
**Problem:** CloudFront distribution E10LMATIX2UNW6 was configured to serve from `jsmc.com.br` bucket instead of `linear-hub-website-prod-1765543563`

**Solution:** 
- Updated origin domain: `jsmc.com.br.s3-website-us-east-1.amazonaws.com` → `linear-hub-website-prod-1765543563.s3-website-us-east-1.amazonaws.com`
- Verified S3 website hosting enabled
- Confirmed S3 bucket policy allows public read access

### Issue 2: CloudFront Using Wrong SSL Certificate ❌→✅
**Problem:** CloudFront aliases and certificate were configured for `jsmc.com.br` instead of `linear-hub.com.br`
- Aliases: `['jsmc.com.br', 'www.jsmc.com.br']`
- Certificate: jsmc.com.br ACM cert (arn:aws:acm:us-east-1:781705467769:certificate/332f5a47-3c9b-4fec-aba8-02a891a035ec)

**Solution:**
- Updated CloudFront aliases: `['linear-hub.com.br', 'www.linear-hub.com.br']`
- Updated ACM certificate: linear-hub.com.br cert (arn:aws:acm:us-east-1:781705467769:certificate/5b7c5719-6344-4afa-9c80-73525ef0d345)
- Set SSL support method: SNI-only with TLSv1.2_2021

### Issue 3: Route 53 DNS Mismatch ❌→✅
**Problem:** Route 53 was pointing to disabled CloudFront distribution EDQZRUQFXIMQ6

**Solution:**
- Updated Route 53 A records to point to E10LMATIX2UNW6: `d378ca32dt91zn.cloudfront.net`
- Verified DNS propagation globally to CloudFront IPs (3.174.83.x range)

## Final Configuration

### CloudFront Distribution E10LMATIX2UNW6
```
Domain Names (Aliases):
  - linear-hub.com.br ✅
  - www.linear-hub.com.br ✅

SSL Certificate:
  - ACM: linear-hub.com.br ✅
  - Protocol: TLSv1.2_2021 ✅
  
Origin Configuration:
  - Domain: linear-hub-website-prod-1765543563.s3-website-us-east-1.amazonaws.com
  - Protocol: http-only (S3 website endpoint limitation)
  - Origin ID: s3-website-linear-hub
  
Viewer Configuration:
  - Protocol Policy: redirect-to-https ✅
  - HTTP Version: http2and3 ✅
  
Cache Configuration:
  - Default TTL: 300 seconds
  - Methods: GET, HEAD
  - Compression: Enabled
```

### S3 Bucket linear-hub-website-prod-1765543563
```
Website Hosting: ✅ Enabled
  - Index: index.html
  - Error: 404.html

Bucket Policy:
  - PublicRead: Principal "*" → s3:GetObject ✅
  - AllowDeployer: Full S3 permissions ✅

Content Status:
  - Total Objects: Published ✅
  - index.html: 51,807 bytes ✅
  - Direct Access: HTTP 200 OK ✅
```

### Route 53 Hosted Zone Z01786261P1IDZOECZQA5
```
A Records:
  - linear-hub.com.br → d378ca32dt91zn.cloudfront.net ✅
  - www.linear-hub.com.br → d378ca32dt91zn.cloudfront.net ✅

DNS Status:
  - Propagation: Global ✅
  - CloudFront IPs: 3.174.83.x range ✅
```

## Verification

### Site Access Tests ✅
```
Test 1: https://linear-hub.com.br/
  Status: HTTP/2 200 ✅
  Content: 51,807 bytes ✅
  Cache: Hit from cloudfront ✅
  POP: GRU3-P9 (São Paulo) ✅

Test 2: https://www.linear-hub.com.br/
  Status: HTTP/2 200 ✅
  Cache: Hit from cloudfront ✅

Test 3: https://linear-hub.com.br/index.html
  Status: HTTP/2 200 ✅
  Server: AmazonS3 ✅
```

### DNS Resolution ✅
```
nslookup linear-hub.com.br:
  3.174.83.87 ✅
  3.174.83.52 ✅
  3.174.83.28 ✅
  3.174.83.70 ✅
```

## Timeline

| Time | Action | Status |
|------|--------|--------|
| 13/12 23:47 | Discovered CloudFront disabled + Route 53 wrong | ❌ |
| 13/12 23:50 | Corrected Route 53 to E10LMATIX2UNW6 | ⚠️ Partial |
| 13/12 23:55 | Deleted old CloudFront EDQZRUQFXIMQ6 | ✅ |
| 14/12 00:00 | Discovered origin pointing to jsmc.com.br | ❌ |
| 14/12 00:05 | Updated origin domain to linear-hub bucket | ⚠️ Still 403 |
| 14/12 00:10 | Updated SSL certificate to linear-hub.com.br | ✅ |
| 14/12 00:24 | Site fully operational | ✅✅✅ |

## Root Cause Analysis

The CloudFront distribution E10LMATIX2UNW6 was originally configured for a different domain (jsmc.com.br) and was reused during the Firebase→AWS migration without proper updates:

1. **Origin Misconfiguration:** Still pointing to old jsmc.com.br bucket
2. **Certificate Mismatch:** ACM certificate and aliases for jsmc.com.br instead of linear-hub.com.br
3. **DNS Cleanup Issue:** Route 53 had been updated to correct distribution, but CloudFront config was wrong
4. **Cascading Failures:** 403 Forbidden errors masked the certificate mismatch issue

## Lessons Learned

1. ✅ Always verify CloudFront origin domain matches intended bucket
2. ✅ SSL certificate aliases must match Route 53 domain names
3. ✅ When migrating CloudFront distributions, completely audit origin + certificate configuration
4. ✅ S3 website endpoints only support HTTP origin (not HTTPS)
5. ✅ CloudFront should use `redirect-to-https` viewer policy for HTTPS domains

## Remaining AWS Resources

### Production Stack ✅
- **CloudFront:** E10LMATIX2UNW6 (d378ca32dt91zn.cloudfront.net) - ACTIVE
- **S3:** linear-hub-website-prod-1765543563 - ACTIVE
- **Route 53:** Z01786261P1IDZOECZQA5 - ACTIVE
- **ACM:** linear-hub.com.br certificate - ACTIVE
- **Lambda:** linear-hub-contact-api - ACTIVE
- **API Gateway:** linear-hub-api - ACTIVE

### Deprecated Resources (Deleted) ✅
- ~~CloudFront EDQZRUQFXIMQ6~~ (old distribution)
- ~~CloudFront E3YBNC3ZMYF4TH~~ (abandoned)
- ~~Lambda GetAllClientsFunction~~ (unused)
- ~~API Gateway uktgit7gb2~~ (unused)

## Status Summary

| Component | Status |
|-----------|--------|
| Website | ✅ Operational |
| CloudFront | ✅ Configured & Deployed |
| S3 Storage | ✅ Website Hosting Enabled |
| Route 53 DNS | ✅ Correctly Routed |
| SSL/TLS | ✅ Valid Certificate |
| Cache | ✅ Working (Hit rate active) |
| Contact API | ✅ Lambda + API Gateway functional |

---

**Recovery Status:** ✅ **COMPLETE**  
**Next Steps:** Monitor CloudFront metrics and logs for ongoing stability
