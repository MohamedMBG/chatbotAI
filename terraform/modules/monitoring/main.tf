# ChatbotAI Monitoring Module
# Uptime monitoring, alerts, and observability

#==============================================================================
# UPTIME MONITORING
#==============================================================================

resource "digitalocean_uptime_check" "web_app" {
  name    = "${var.name_prefix}-web-uptime"
  target  = var.app_url
  type    = "https"
  regions = var.uptime_regions
  enabled = true
}

resource "digitalocean_uptime_check" "api_health" {
  name    = "${var.name_prefix}-api-health"
  target  = var.api_url
  type    = "https"
  regions = var.uptime_regions
  enabled = true
}

resource "digitalocean_uptime_check" "api_endpoint" {
  name    = "${var.name_prefix}-api-endpoint"
  target  = "${var.api_url}/health"
  type    = "https"
  regions = var.uptime_regions
  enabled = true
}

#==============================================================================
# UPTIME ALERTS
#==============================================================================

resource "digitalocean_uptime_alert" "web_app_down" {
  check_id = digitalocean_uptime_check.web_app.id
  name     = "${var.name_prefix}-web-down-alert"
  type     = "down"
  
  # Notification settings
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#infrastructure-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  # Comparison settings
  comparison = "less_than"
  threshold  = 1
  period     = "2m"
}

resource "digitalocean_uptime_alert" "api_health_down" {
  check_id = digitalocean_uptime_check.api_health.id
  name     = "${var.name_prefix}-api-health-down"
  type     = "down"
  
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#api-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  comparison = "less_than"
  threshold  = 1
  period     = "2m"
}

# SSL certificate expiration alert
resource "digitalocean_uptime_alert" "ssl_expiry" {
  check_id = digitalocean_uptime_check.web_app.id
  name     = "${var.name_prefix}-ssl-expiry-alert"
  type     = "ssl_expiry"
  
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#security-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  # Alert 30 days before SSL expiry
  comparison = "less_than"
  threshold  = 30
  period     = "24h"
}

#==============================================================================
# RESPONSE TIME MONITORING
#==============================================================================

resource "digitalocean_uptime_alert" "slow_response" {
  check_id = digitalocean_uptime_check.api_endpoint.id
  name     = "${var.name_prefix}-slow-response-alert"
  type     = "latency"
  
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#performance-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  # Alert if response time > 5 seconds
  comparison = "greater_than"
  threshold  = var.response_time_threshold
  period     = "5m"
}

#==============================================================================
# CUSTOM MONITORING CHECKS
#==============================================================================

# Database connectivity check (through API endpoint)
resource "digitalocean_uptime_check" "database_health" {
  name    = "${var.name_prefix}-database-health"
  target  = "${var.api_url}/health/database"
  type    = "https"
  regions = ["us_east"]  # Single region for DB checks
  enabled = true
}

resource "digitalocean_uptime_alert" "database_connectivity" {
  check_id = digitalocean_uptime_check.database_health.id
  name     = "${var.name_prefix}-database-connectivity"
  type     = "down"
  
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#database-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  comparison = "less_than"
  threshold  = 1
  period     = "5m"
}

# Redis connectivity check
resource "digitalocean_uptime_check" "redis_health" {
  name    = "${var.name_prefix}-redis-health"
  target  = "${var.api_url}/health/redis"
  type    = "https"
  regions = ["us_east"]
  enabled = true
}

resource "digitalocean_uptime_alert" "redis_connectivity" {
  check_id = digitalocean_uptime_check.redis_health.id
  name     = "${var.name_prefix}-redis-connectivity"
  type     = "down"
  
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#cache-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  comparison = "less_than"
  threshold  = 1
  period     = "5m"
}

#==============================================================================
# BUSINESS METRICS MONITORING
#==============================================================================

# Trial conversion monitoring (custom endpoint)
resource "digitalocean_uptime_check" "trial_system" {
  count = var.environment == "production" ? 1 : 0
  
  name    = "${var.name_prefix}-trial-system"
  target  = "${var.api_url}/health/trials"
  type    = "https"
  regions = ["us_east"]
  enabled = true
}

resource "digitalocean_uptime_alert" "trial_system_down" {
  count = var.environment == "production" ? 1 : 0
  
  check_id = digitalocean_uptime_check.trial_system[0].id
  name     = "${var.name_prefix}-trial-system-down"
  type     = "down"
  
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#business-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  comparison = "less_than"
  threshold  = 1
  period     = "10m"
}

# Payment processing monitoring
resource "digitalocean_uptime_check" "payment_health" {
  count = var.environment == "production" ? 1 : 0
  
  name    = "${var.name_prefix}-payment-health"
  target  = "${var.api_url}/health/payments"
  type    = "https"
  regions = ["us_east", "eu_central"]  # Multiple regions for payments
  enabled = true
}

resource "digitalocean_uptime_alert" "payment_system_down" {
  count = var.environment == "production" ? 1 : 0
  
  check_id = digitalocean_uptime_check.payment_health[0].id
  name     = "${var.name_prefix}-payment-system-critical"
  type     = "down"
  
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#payment-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  comparison = "less_than"
  threshold  = 1
  period     = "2m"  # Quick alert for payment issues
}

#==============================================================================
# ADULT CONTENT COMPLIANCE MONITORING
#==============================================================================

# Age verification system monitoring
resource "digitalocean_uptime_check" "age_verification" {
  count = var.enable_compliance_monitoring ? 1 : 0
  
  name    = "${var.name_prefix}-age-verification"
  target  = "${var.api_url}/health/age-verification"
  type    = "https"
  regions = ["us_east"]
  enabled = true
}

resource "digitalocean_uptime_alert" "age_verification_down" {
  count = var.enable_compliance_monitoring ? 1 : 0
  
  check_id = digitalocean_uptime_check.age_verification[0].id
  name     = "${var.name_prefix}-age-verification-critical"
  type     = "down"
  
  notifications {
    email = var.alert_email != "" ? [var.alert_email] : []
    
    dynamic "slack" {
      for_each = var.slack_webhook != "" ? [1] : []
      content {
        channel = "#compliance-alerts"
        url     = var.slack_webhook
      }
    }
  }
  
  comparison = "less_than"
  threshold  = 1
  period     = "5m"
}

#==============================================================================
# MONITORING DASHBOARD CONFIGURATION
#==============================================================================

# Create a monitoring project to organize resources
resource "digitalocean_project" "monitoring" {
  name        = "${var.name_prefix}-monitoring"
  description = "Monitoring and observability for ${var.environment} environment"
  purpose     = "Monitoring"
  environment = var.environment
  
  resources = [
    digitalocean_uptime_check.web_app.urn,
    digitalocean_uptime_check.api_health.urn,
    digitalocean_uptime_check.api_endpoint.urn,
    digitalocean_uptime_check.database_health.urn,
    digitalocean_uptime_check.redis_health.urn
  ]
}

#==============================================================================
# EXTERNAL MONITORING INTEGRATION
#==============================================================================

# Webhook for external monitoring services (like Datadog, New Relic)
locals {
  webhook_endpoints = var.external_webhook_urls
  
  monitoring_config = {
    environment = var.environment
    app_url     = var.app_url
    api_url     = var.api_url
    checks = {
      web_uptime    = digitalocean_uptime_check.web_app.id
      api_health    = digitalocean_uptime_check.api_health.id
      database      = digitalocean_uptime_check.database_health.id
      redis         = digitalocean_uptime_check.redis_health.id
    }
  }
}

# Output monitoring configuration for external integrations
resource "local_file" "monitoring_config" {
  count = var.export_monitoring_config ? 1 : 0
  
  content = jsonencode(local.monitoring_config)
  filename = "${path.module}/monitoring-config-${var.environment}.json"
}

#==============================================================================
# COST MONITORING
#==============================================================================

# Monitor for unexpected cost increases (DigitalOcean doesn't have native cost alerts)
# This would integrate with billing API if available
locals {
  cost_monitoring_note = "Cost monitoring requires external integration with DigitalOcean billing API"
}