# 🏗️ ChatbotAI Infrastructure (Terraform)

Complete Infrastructure as Code for the ChatbotAI adult AI SaaS platform on DigitalOcean.

## 📋 Overview

This Terraform configuration deploys a production-ready, scalable infrastructure for ChatbotAI including:

- **VPC & Networking**: Private networking with security groups
- **Managed Databases**: PostgreSQL (user data) + Redis (caching/sessions)  
- **App Platform**: React frontend + Python API + background workers
- **Monitoring**: Uptime checks, SSL monitoring, performance alerts
- **Storage**: Spaces buckets for uploads and backups
- **SSL**: Automated Let's Encrypt certificates
- **Multi-Environment**: Dev, staging, production configurations

## 🎯 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Users         │    │   Cloudflare    │    │   Monitoring    │
│                 │    │   (DNS/CDN)     │    │   (Uptime)      │
└─────────┬───────┘    └─────────┬───────┘    └─────────────────┘
          │                      │                       
          └──────────────────────┼───────────────────────┘
                                 │
                   ┌─────────────┴───────────────┐
                   │    DigitalOcean VPC         │
                   │                             │
                   │  ┌─────────────────────┐   │
                   │  │   App Platform      │   │
                   │  │                     │   │
                   │  │  ┌─────────────┐   │   │
                   │  │  │   React     │   │   │
                   │  │  │   Frontend  │   │   │
                   │  │  └─────────────┘   │   │
                   │  │  ┌─────────────┐   │   │
                   │  │  │  FastAPI    │   │   │
                   │  │  │  Backend    │   │   │
                   │  │  └─────────────┘   │   │
                   │  │  ┌─────────────┐   │   │
                   │  │  │  Background │   │   │
                   │  │  │  Workers    │   │   │
                   │  │  └─────────────┘   │   │
                   │  └─────────────────────┘   │
                   │                             │
                   │  ┌─────────────────────┐   │
                   │  │   Databases         │   │
                   │  │                     │   │
                   │  │  ┌─────────────┐   │   │
                   │  │  │ PostgreSQL  │   │   │
                   │  │  │ (Users/Subs)│   │   │
                   │  │  └─────────────┘   │   │
                   │  │  ┌─────────────┐   │   │
                   │  │  │    Redis    │   │   │
                   │  │  │ (Cache/Sess)│   │   │
                   │  │  └─────────────┘   │   │
                   │  └─────────────────────┘   │
                   │                             │
                   │  ┌─────────────────────┐   │
                   │  │   Spaces Storage    │   │
                   │  │ (Uploads/Backups)   │   │
                   │  └─────────────────────┘   │
                   └─────────────────────────────┘
```

## 🚀 Quick Start

### Prerequisites

1. **DigitalOcean Account** with API token
2. **Terraform** >= 1.0 installed
3. **Domain** configured (IntimateAI.chat)
4. **Stripe Account** for payment processing

### Environment Setup

1. **Clone & Navigate**:
   ```bash
   git clone git@github.com:epiphanyapps/chatbotAI.git
   cd chatbotAI/terraform
   ```

2. **Set Environment Variables**:
   ```bash
   export TF_VAR_do_token="your_digitalocean_token"
   export TF_VAR_stripe_secret_key="sk_test_..."
   export TF_VAR_jwt_secret_key="your_jwt_secret"
   export TF_VAR_encryption_key="your_encryption_key"
   export TF_VAR_alert_email="admin@yourcompany.com"
   ```

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Select Environment**:
   ```bash
   # Development
   terraform workspace select dev || terraform workspace new dev
   
   # Production  
   terraform workspace select production || terraform workspace new production
   ```

5. **Plan & Apply**:
   ```bash
   # Development
   terraform plan -var-file="environments/dev/terraform.tfvars"
   terraform apply -var-file="environments/dev/terraform.tfvars"
   
   # Production
   terraform plan -var-file="environments/production/terraform.tfvars"
   terraform apply -var-file="environments/production/terraform.tfvars"
   ```

## 🏗️ Module Structure

### Core Modules

#### **Networking Module** (`modules/networking/`)
- VPC creation and configuration
- Firewall rules for web/database tiers
- Load balancer (production)
- DNS management (optional)

#### **Database Module** (`modules/database/`)
- PostgreSQL cluster (user data, subscriptions)
- Redis cluster (sessions, cache, rate limiting)
- Connection pools for performance
- Automated backups and maintenance
- Read replicas (production)

#### **App Platform Module** (`modules/app-platform/`)
- React frontend service
- Python/FastAPI backend service  
- Background worker processes
- SSL certificate management
- CDN configuration
- Spaces storage for uploads

#### **Monitoring Module** (`modules/monitoring/`)
- Uptime monitoring (web, API, database)
- SSL certificate expiration alerts
- Response time monitoring
- Business metric monitoring (trials, payments)
- Compliance monitoring (age verification)

## 🌍 Environments

### Development (`environments/dev/`)
- **Domain**: `dev.intimateai.chat`
- **Scaling**: Minimal (cost-optimized)
- **Databases**: Single node, reduced backup retention
- **Monitoring**: Basic uptime checks
- **Features**: Debug mode enabled, verbose logging

### Production (`environments/production/`)
- **Domain**: `intimateai.chat`  
- **Scaling**: Multi-instance, high availability
- **Databases**: HA configuration, extended backups
- **Monitoring**: Comprehensive alerting, business metrics
- **Features**: Optimized for performance and reliability

## 📊 Cost Optimization

### Development Environment (~$150/month)
- App Platform: $50/month (basic instances)
- PostgreSQL: $60/month (1 node)
- Redis: $15/month (1 node)
- Storage: $10/month
- Monitoring: $5/month
- SSL: Free (Let's Encrypt)

### Production Environment (~$400/month)
- App Platform: $200/month (scaled instances)
- PostgreSQL: $120/month (2 nodes + replica)
- Redis: $30/month (larger instance)
- Storage: $30/month (backups + uploads)
- Monitoring: $15/month
- Load Balancer: $10/month

## 🔒 Security Features

### Network Security
- Private VPC with restricted access
- Database firewall (VPC-only access)
- Web application firewall rules
- SSL/TLS encryption throughout

### Data Protection
- Encrypted databases (at rest & in transit)
- Secure connection pools
- Environment variable secrets
- Audit logging enabled

### Adult Content Compliance
- Age verification monitoring
- GDPR compliance features
- Data retention policies
- Geographic restrictions support

## 📈 Monitoring & Alerting

### Uptime Monitoring
- **Web Application**: Multi-region checks
- **API Endpoints**: Health check monitoring
- **Database**: Connectivity monitoring
- **SSL Certificates**: Expiration alerts (30 days)

### Performance Monitoring
- **Response Time**: <5 second alerts
- **Database Performance**: CPU/memory alerts
- **Application Scaling**: Auto-scaling triggers
- **Error Rates**: Failed request monitoring

### Business Metrics
- **Trial System**: Conversion monitoring
- **Payment Processing**: Transaction health
- **User Registration**: Signup flow monitoring
- **Compliance**: Age verification system

## 🔧 Customization

### Scaling Configuration
Edit `terraform/main.tf` local values:
```hcl
app_config = {
  production = {
    web_instances = 3    # Increase for more traffic
    api_instances = 5    # Scale API backend
    web_size = "basic-s" # Upgrade instance size
  }
}
```

### Database Configuration
Modify `terraform/main.tf` database config:
```hcl
db_config = {
  production = {
    postgres_size = "db-s-4vcpu-8gb"  # Upgrade database
    postgres_nodes = 3                # High availability
  }
}
```

### Monitoring Configuration
Update `modules/monitoring/main.tf`:
```hcl
resource "digitalocean_uptime_check" "custom_business_metric" {
  name    = "${var.name_prefix}-custom-metric"
  target  = "${var.api_url}/health/custom"
  # ... configuration
}
```

## 🚀 CI/CD Integration

### GitHub Actions Workflow
Automatic deployment on push:

```yaml
# .github/workflows/terraform-deploy.yml
- main branch → production environment
- develop branch → development environment  
- PRs → terraform plan (preview changes)
```

### Required Secrets
Set in GitHub repository settings:

```
DO_TOKEN              # DigitalOcean API token
STRIPE_SECRET_KEY     # Stripe payment processing
JWT_SECRET_KEY        # Application authentication  
ENCRYPTION_KEY        # Data encryption key
ALERT_EMAIL           # Infrastructure alerts
SLACK_WEBHOOK         # Notification integration (optional)
TF_API_TOKEN          # Terraform Cloud (optional)
```

## 🔍 Troubleshooting

### Common Issues

#### **DNS Propagation**
```bash
# Check DNS resolution
dig intimateai.chat
nslookup dev.intimateai.chat
```

#### **SSL Certificate Issues**
```bash
# Check certificate status
terraform output ssl_certificate_status
```

#### **Database Connectivity**  
```bash
# Check database firewall rules
terraform show | grep digitalocean_database_firewall
```

#### **App Platform Deployment**
```bash
# Check deployment logs in DigitalOcean console
terraform output deployment_info
```

### Debugging Commands
```bash
# View current state
terraform show

# Check outputs
terraform output

# Validate configuration
terraform validate

# Check plan before apply
terraform plan

# Debug specific resource
terraform state show digitalocean_app.chatbotai
```

## 📚 Additional Resources

### DigitalOcean Documentation
- [App Platform Guide](https://docs.digitalocean.com/products/app-platform/)
- [Managed Databases](https://docs.digitalocean.com/products/databases/)
- [VPC Configuration](https://docs.digitalocean.com/products/networking/vpc/)

### Terraform Resources
- [DigitalOcean Provider](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

### Business Resources
- [Adult Content Compliance](../docs/legal-compliance.md)
- [Scaling Guidelines](../docs/scaling-guide.md)
- [Cost Optimization](../docs/cost-optimization.md)

---

## 🆘 Support

### Infrastructure Support
- **GitHub Issues**: [Create Issue](../../issues/new)
- **Documentation**: [Project Wiki](../../wiki)
- **Emergency**: Check monitoring alerts first

### DigitalOcean Support  
- **Console**: https://cloud.digitalocean.com
- **Support Tickets**: Available with paid accounts
- **Community**: https://www.digitalocean.com/community

---

**This infrastructure supports the ChatbotAI adult AI SaaS platform with enterprise-grade reliability, security, and scalability.** 🚀💰