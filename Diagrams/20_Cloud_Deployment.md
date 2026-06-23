# Diagram 20: Cloud Deployment Architecture

## Purpose
Show the complete cloud infrastructure setup for OWHAS at owhas.org domain (AWS EC2 + Firebase).

## Type
**Cloud Infrastructure Architecture Diagram**

## Cloud Deployment Overview

```
┌──────────────────────────────────────────────────────────────┐
│               CLOUD DEPLOYMENT ARCHITECTURE                   │
│                     (owhas.org)                               │
│         AWS EC2 + Firebase + Cloudflare CDN                   │
└──────────────────────────────────────────────────────────────┘
```

## Layer 1: CDN & DDoS Protection (Cloudflare)

### Cloudflare Services
```
Domain: owhas.org
Nameservers: Cloudflare (ns1-ns4.cloudflare.com)

Services:
  ├─ DDoS Protection
  │  ├─ Layer 3-4: Network-level protection
  │  ├─ Layer 7: Application-level protection
  │  └─ Automatic mitigation: Enabled
  │
  ├─ Web Application Firewall (WAF)
  │  ├─ SQL Injection protection: Enabled
  │  ├─ XSS protection: Enabled
  │  ├─ Bot management: Enabled
  │  └─ Custom rules: Configured
  │
  ├─ SSL/TLS Encryption
  │  ├─ Mode: Full (Cloudflare ↔ Origin)
  │  ├─ Certificate: Let's Encrypt (auto-renewed)
  │  ├─ Minimum TLS: 1.2
  │  └─ HSTS: Enabled
  │
  ├─ Caching & Performance
  │  ├─ Cache level: Cache everything (images, API)
  │  ├─ Cache TTL: 30 minutes (default)
  │  ├─ Browser cache: 30 minutes
  │  ├─ Gzip compression: Enabled
  │  └─ Edge caching: 200+ PoP worldwide
  │
  ├─ Analytics
  │  ├─ Requests tracked
  │  ├─ Security threats logged
  │  ├─ Performance metrics
  │  └─ Dashboard real-time
  │
  └─ DNS Services
     ├─ DNS query time: < 50ms
     ├─ Reliability: 99.99% uptime
     ├─ Global anycast: Fast resolution worldwide
     └─ DNSSEC: Enabled (optional)
```

### Cloudflare DNS Records
```
Type A: owhas.org → 18.191.45.123 (AWS EC2 IP)
Type AAAA: owhas.org → 2600:1f1c:5a5:2200::1 (IPv6)

Subdomains (optional):
  ├─ api.owhas.org → Same IP (Express backend)
  ├─ admin.owhas.org → Same IP (Admin panel)
  └─ cdn.owhas.org → S3 origin (static assets)
```

## Layer 2: AWS EC2 Instance

### Instance Configuration
```
Instance Type: t3.large (general purpose, scalable)
  ├─ vCPU: 2 cores
  ├─ Memory: 8GB RAM
  ├─ Network: Up to 5 Gbps
  ├─ Storage: 40GB EBS (SSD)
  ├─ Availability Zone: us-east-1a (Ohio region)
  └─ Uptime SLA: 99.95%

Operating System: Ubuntu 20.04 LTS
  ├─ Kernel: Linux 5.4+
  ├─ Packages: Minimal, hardened
  ├─ Security: Auto-patching enabled
  └─ Firewall: UFW (Uncomplicated Firewall)

User Access:
  ├─ SSH Key: Key-pair authentication (no passwords)
  ├─ User: ubuntu (sudo privileges for deployment)
  ├─ Access: Only from designated IPs (whitelist)
  └─ Port 22: Restricted by security group
```

### Security Groups (Firewall Rules)
```
Inbound Rules:
  ├─ HTTP (80): From anywhere (0.0.0.0/0)
  │  └─ Purpose: Auto-redirect to HTTPS
  ├─ HTTPS (443): From anywhere
  │  └─ Purpose: Main traffic
  ├─ SSH (22): From specific IPs only (admin access)
  │  └─ Purpose: Deployment & maintenance
  └─ All else: DENY

Outbound Rules:
  ├─ All traffic: ALLOW
  │  └─ Purpose: Outbound connections to Firebase, AWS services
  └─ Limited rate: Optional (DDoS mitigation)
```

### Elastic IP
```
Static IP: 18.191.45.123
  ├─ Never changes (static assignment)
  ├─ Associated with EC2 instance
  ├─ DNS: Points to this IP
  ├─ Cost: $0.005 per hour if unused
  └─ Purpose: Consistent domain resolution
```

## Layer 3: Application Server (Nginx Reverse Proxy)

### Nginx Configuration
```
Purpose: Reverse proxy, load balancer, SSL termination

Listening Ports:
  ├─ Port 80: HTTP (redirect to HTTPS)
  ├─ Port 443: HTTPS (main traffic)
  └─ Port 8080: Localhost (Express backend only)

SSL/TLS Setup:
  ├─ Certificate: Let's Encrypt
  │  ├─ File: /etc/letsencrypt/live/owhas.org/fullchain.pem
  │  ├─ Key: /etc/letsencrypt/live/owhas.org/privkey.pem
  │  ├─ Auto-renewal: Certbot (runs monthly)
  │  └─ Expiry: 90 days (renewed before expiry)
  │
  ├─ Cipher suite: ECDHE + AES256 + SHA384
  ├─ TLS 1.2 minimum (TLS 1.3 if supported)
  └─ OCSP stapling: Enabled

Reverse Proxy Rules:
  ├─ /api/* → http://localhost:8080
  ├─ / → http://localhost:8080 (fallback)
  ├─ /static/* → Serve from disk cache
  └─ /.well-known/* → Let's Encrypt validation

Headers Added:
  ├─ X-Forwarded-For: Client IP
  ├─ X-Forwarded-Proto: https
  ├─ X-Forwarded-Host: owhas.org
  └─ X-Real-IP: Client IP

Compression:
  ├─ gzip: Enabled
  ├─ Level: 9 (maximum compression)
  └─ Types: JSON, HTML, CSS, JavaScript

Caching (Static Assets):
  ├─ face-api.min.js: Cache 7 days
  ├─ hotspot.html: Cache 1 hour
  ├─ CSS/JS: Cache 1 day
  └─ API responses: No cache (dynamic)

Rate Limiting:
  ├─ Requests: 100 req/sec per IP
  ├─ Burst: 200 requests allowed
  └─ Reset: After 60 seconds
```

## Layer 4: Express Node.js Application Server

### Application Setup
```
Runtime: Node.js v18 LTS
  ├─ Binary: /usr/bin/node
  ├─ Process manager: PM2 (auto-restart)
  ├─ Workers: 4 (auto-scale by CPU)
  └─ Restart policy: Automatic on crash

Application Directory:
  ├─ Path: /var/www/owhas-backend
  ├─ Code: Git repository (GitHub)
  ├─ Deployment: CI/CD pipeline
  ├─ Version: Latest stable
  └─ Logs: /var/log/owhas/

Environment Variables:
  ├─ NODE_ENV=production
  ├─ FIREBASE_PROJECT_ID=owhas-...
  ├─ FIREBASE_PRIVATE_KEY=[encrypted]
  ├─ DATABASE_URL=postgresql://user:pass@localhost/owhas
  └─ PORT=8080
```

### Express Application
```
Entry Point: server.js
Framework: Express.js v4+
Port: 8080 (listening internally)

Routes:
  ├─ /api/session/* (session management)
  ├─ /api/attendance/* (attendance registration)
  ├─ /api/report/* (report generation)
  ├─ /api/cloud/* (cloud sync)
  └─ /api/courses/* (course management)

Middleware:
  ├─ CORS: Enabled (owhas.org, Firebase domains)
  ├─ Body parser: JSON + URL-encoded
  ├─ Helmet: Security headers
  ├─ Morgan: HTTP request logging
  └─ Error handler: Global error catching

Database Connection:
  ├─ Type: PostgreSQL (not SQLite)
  ├─ Host: RDS instance (separate)
  ├─ Connection pool: 10-20 connections
  └─ Timeout: 30 seconds

Firebase SDK:
  ├─ Authentication: Integrated
  ├─ Firestore queries: Enabled
  ├─ Cloud Functions: Triggered from here
  └─ Admin SDK: Full access
```

## Layer 5: Database (Amazon RDS PostgreSQL)

### RDS Instance
```
Engine: PostgreSQL 13+
Instance Type: db.t3.micro (small, cost-effective)
  ├─ vCPU: 1
  ├─ Memory: 1GB
  └─ IOPS: Variable (general purpose)

Storage:
  ├─ Allocated: 100GB
  ├─ Type: General Purpose SSD (gp3)
  ├─ Auto-scaling: Enabled (up to 200GB)
  ├─ Backup: Automated (35-day retention)
  └─ Encryption: AES-256 at rest

Backup Strategy:
  ├─ Automatic backups: Daily
  ├─ Retention: 35 days
  ├─ Multi-AZ: Enabled (automatic failover)
  ├─ Snapshots: Manual on-demand
  └─ Point-in-time recovery: Enabled

Access:
  ├─ VPC: Private (not internet-facing)
  ├─ Security Group: Restricted to EC2
  ├─ Port: 5432 (PostgreSQL standard)
  ├─ Authentication: Username/password + IAM roles
  └─ Encryption in transit: SSL/TLS

Maintenance:
  ├─ Window: Sunday 3-4 AM UTC (low-usage time)
  ├─ Auto-minor-version-upgrade: Enabled
  └─ Multi-AZ: No downtime during maintenance
```

## Layer 6: Firebase Backend

### Services Used (Cloud)
```
Firebase Authentication:
  ├─ OAuth providers: Email, Google, Facebook
  ├─ JWT tokens: Auto-issued
  └─ Token refresh: Automatic

Cloud Firestore:
  ├─ Collections: /sessions, /users, /courses, /reports
  ├─ Subcollections: /sessions/{id}/records
  ├─ Real-time sync: Enabled (optional)
  ├─ Indexing: Composite indexes created
  └─ Cost: Pay-per-read/write/delete

Cloud Storage:
  ├─ Bucket: owhas-reports-prod
  ├─ Path: /reports/{sessionID}.pdf, .xlsx
  ├─ CDN: Integrated (Cloudflare)
  ├─ Retention: 2 years (auto-delete)
  └─ Cost: Pay-per-GB-month stored + transfer

Cloud Functions:
  ├─ Runtime: Node.js 18
  ├─ Triggers: Firestore writes, HTTP, Pub/Sub
  ├─ Functions deployed: 3-4 functions
  ├─ Memory: 512MB each
  ├─ Timeout: 9 minutes
  └─ Cost: Pay-per-invocation + compute time
```

## Layer 7: Monitoring & Logging

### CloudWatch (AWS Monitoring)
```
Metrics Tracked:
  ├─ CPU utilization
  ├─ Memory usage
  ├─ Disk I/O
  ├─ Network traffic
  ├─ HTTP response times
  └─ Error rates

Logs:
  ├─ EC2 system logs: /var/log/syslog
  ├─ Nginx logs: /var/log/nginx/access.log
  ├─ Application logs: /var/log/owhas/app.log
  ├─ Database logs: RDS event logs
  └─ Retention: 30 days

Alarms:
  ├─ High CPU (> 80%): Alert
  ├─ High memory (> 90%): Alert
  ├─ Low disk space (< 10%): Alert
  ├─ HTTP errors (> 1%): Alert
  └─ Database connection pool exhausted: Alert

Dashboard:
  ├─ Real-time metrics
  ├─ Custom widgets
  └─ Alert notifications
```

### Firebase Console Monitoring
```
Metrics:
  ├─ Firestore read/write/delete operations
  ├─ Cloud Storage transfer volume
  ├─ Cloud Function invocations & duration
  ├─ Authentication sign-ups/logins
  └─ Performance analytics

Analytics:
  ├─ Session start/end events
  ├─ Report generation events
  ├─ Error tracking
  └─ User behavior analysis
```

## Deployment Process

### CI/CD Pipeline (GitHub Actions)
```
Trigger: Push to main branch

Steps:
  1. Clone repository
  2. Run tests (unit + integration)
  3. Build application (bundle dependencies)
  4. Create Docker image
  5. Push to ECR (Elastic Container Registry)
  6. SSH to EC2 instance
  7. Pull latest image
  8. Stop old container
  9. Run new container
  10. Health check
  11. Rollback if failed
  12. Notify team

Deployment time: 5-10 minutes
Downtime: 30-60 seconds (container restart)
```

## Scaling & Load Balancing

### Horizontal Scaling (Future)
```
If usage exceeds single instance capacity:

Option 1: Multiple EC2 Instances
  ├─ Use Auto Scaling Group
  ├─ Target 2-5 instances (depending on load)
  ├─ Load Balancer: Distribute traffic
  └─ Session store: Redis (distributed session)

Option 2: Container Orchestration
  ├─ Kubernetes (EKS)
  ├─ Auto-scale pods based on CPU
  ├─ Service mesh for traffic management
  └─ Helm charts for deployment
```

### Cost Estimation (Monthly)
```
EC2 t3.large: ~$60
RDS db.t3.micro: ~$30
Elastic IP: ~$3.60 (if unused)
CloudFlare Pro: ~$20
Firebase: ~$50 (pay-as-you-go)
Data transfer: ~$10-50 (depends on usage)
────────────────────────────────
Total: ~$170-230/month

Savings:
├─ Spot instances: -30%
├─ Reserved instances: -40%
└─ Reserved database: -35%
```

## Success Criteria
- Cloud infrastructure clearly shown
- CDN integration (Cloudflare) visible
- AWS EC2 configuration documented
- Nginx reverse proxy setup explained
- Database architecture (RDS) detailed
- Firebase integration shown
- Security measures (SSL, firewall, WAF) indicated
- Monitoring and logging visible
- Deployment process clear
- Scaling options documented
- Cost implications noted

## Tools Suitable For
- Draw.io
- Lucidchart
- CloudCraft (AWS diagrams)
- AWS Architecture Icons

## Related Sections in Final_Doc
- Section 9.2: Cloud Deployment Architecture
- Section 9: Deployment Architecture
