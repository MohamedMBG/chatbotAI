# Monitoring Module Outputs

output "uptime_check_ids" {
  description = "List of uptime check IDs"
  value = [
    digitalocean_uptime_check.web_app.id,
    digitalocean_uptime_check.api_health.id,
    digitalocean_uptime_check.api_endpoint.id,
    digitalocean_uptime_check.database_health.id,
    digitalocean_uptime_check.redis_health.id
  ]
}

output "uptime_checks" {
  description = "Uptime check details"
  value = {
    web_app = {
      id     = digitalocean_uptime_check.web_app.id
      name   = digitalocean_uptime_check.web_app.name
      target = digitalocean_uptime_check.web_app.target
      type   = digitalocean_uptime_check.web_app.type
    }
    api_health = {
      id     = digitalocean_uptime_check.api_health.id
      name   = digitalocean_uptime_check.api_health.name
      target = digitalocean_uptime_check.api_health.target
      type   = digitalocean_uptime_check.api_health.type
    }
    api_endpoint = {
      id     = digitalocean_uptime_check.api_endpoint.id
      name   = digitalocean_uptime_check.api_endpoint.name
      target = digitalocean_uptime_check.api_endpoint.target
      type   = digitalocean_uptime_check.api_endpoint.type
    }
    database = {
      id     = digitalocean_uptime_check.database_health.id
      name   = digitalocean_uptime_check.database_health.name
      target = digitalocean_uptime_check.database_health.target
      type   = digitalocean_uptime_check.database_health.type
    }
    redis = {
      id     = digitalocean_uptime_check.redis_health.id
      name   = digitalocean_uptime_check.redis_health.name
      target = digitalocean_uptime_check.redis_health.target
      type   = digitalocean_uptime_check.redis_health.type
    }
  }
}

output "alert_configurations" {
  description = "Alert configuration details"
  value = {
    web_down = {
      id        = digitalocean_uptime_alert.web_app_down.id
      name      = digitalocean_uptime_alert.web_app_down.name
      type      = digitalocean_uptime_alert.web_app_down.type
      threshold = digitalocean_uptime_alert.web_app_down.threshold
      period    = digitalocean_uptime_alert.web_app_down.period
    }
    api_down = {
      id        = digitalocean_uptime_alert.api_health_down.id
      name      = digitalocean_uptime_alert.api_health_down.name
      type      = digitalocean_uptime_alert.api_health_down.type
      threshold = digitalocean_uptime_alert.api_health_down.threshold
      period    = digitalocean_uptime_alert.api_health_down.period
    }
    ssl_expiry = {
      id        = digitalocean_uptime_alert.ssl_expiry.id
      name      = digitalocean_uptime_alert.ssl_expiry.name
      type      = digitalocean_uptime_alert.ssl_expiry.type
      threshold = digitalocean_uptime_alert.ssl_expiry.threshold
      period    = digitalocean_uptime_alert.ssl_expiry.period
    }
    slow_response = {
      id        = digitalocean_uptime_alert.slow_response.id
      name      = digitalocean_uptime_alert.slow_response.name
      type      = digitalocean_uptime_alert.slow_response.type
      threshold = digitalocean_uptime_alert.slow_response.threshold
      period    = digitalocean_uptime_alert.slow_response.period
    }
  }
}

output "monitoring_dashboard_url" {
  description = "DigitalOcean monitoring dashboard URL"
  value       = "https://cloud.digitalocean.com/monitoring"
}

output "project_id" {
  description = "Monitoring project ID"
  value       = digitalocean_project.monitoring.id
}

output "project_url" {
  description = "Monitoring project URL in DigitalOcean"
  value       = "https://cloud.digitalocean.com/projects/${digitalocean_project.monitoring.id}"
}

output "business_monitoring" {
  description = "Business-critical monitoring checks (production only)"
  value = var.environment == "production" ? {
    trial_system = length(digitalocean_uptime_check.trial_system) > 0 ? {
      id     = digitalocean_uptime_check.trial_system[0].id
      target = digitalocean_uptime_check.trial_system[0].target
    } : null
    payment_system = length(digitalocean_uptime_check.payment_health) > 0 ? {
      id     = digitalocean_uptime_check.payment_health[0].id
      target = digitalocean_uptime_check.payment_health[0].target
    } : null
  } : null
}

output "compliance_monitoring" {
  description = "Compliance monitoring checks (if enabled)"
  value = var.enable_compliance_monitoring ? {
    age_verification = length(digitalocean_uptime_check.age_verification) > 0 ? {
      id     = digitalocean_uptime_check.age_verification[0].id
      target = digitalocean_uptime_check.age_verification[0].target
    } : null
  } : null
}

output "monitoring_summary" {
  description = "Complete monitoring configuration summary"
  value = {
    environment     = var.environment
    total_checks    = 5 + (var.environment == "production" ? 2 : 0) + (var.enable_compliance_monitoring ? 1 : 0)
    alert_email     = var.alert_email != "" ? "configured" : "not configured"
    slack_webhook   = var.slack_webhook != "" ? "configured" : "not configured"
    uptime_regions  = var.uptime_regions
    response_threshold = var.response_time_threshold
    compliance_enabled = var.enable_compliance_monitoring
    project_id      = digitalocean_project.monitoring.id
  }
}