# App Platform Module Outputs

#==============================================================================
# APPLICATION URLS
#==============================================================================

output "app_id" {
  description = "App Platform application ID"
  value       = digitalocean_app.chatbotai.id
}

output "app_urn" {
  description = "App Platform application URN"
  value       = digitalocean_app.chatbotai.urn
}

output "app_url" {
  description = "Main application URL"
  value       = "https://${var.domain_name}"
}

output "live_url" {
  description = "Live deployment URL from App Platform"
  value       = digitalocean_app.chatbotai.live_url
}

output "default_ingress" {
  description = "Default App Platform ingress URL"
  value       = digitalocean_app.chatbotai.default_ingress
}

#==============================================================================
# SERVICE ENDPOINTS
#==============================================================================

output "api_url" {
  description = "API endpoint URL"
  value       = "https://${var.domain_name}/api"
}

output "health_check_url" {
  description = "Health check endpoint"
  value       = "https://${var.domain_name}/api/health"
}

output "metrics_url" {
  description = "Metrics endpoint"
  value       = "https://${var.domain_name}/api/metrics"
}

output "admin_url" {
  description = "Admin dashboard URL"
  value       = "https://${var.domain_name}/admin"
}

output "webhook_url" {
  description = "Stripe webhook endpoint"
  value       = "https://${var.domain_name}/api/webhooks/stripe"
}

#==============================================================================
# SSL CERTIFICATE
#==============================================================================

output "ssl_certificate_id" {
  description = "SSL certificate ID"
  value       = digitalocean_certificate.main.id
}

output "ssl_certificate_name" {
  description = "SSL certificate name"
  value       = digitalocean_certificate.main.name
}

output "ssl_certificate_domains" {
  description = "SSL certificate domains"
  value       = digitalocean_certificate.main.domains
}

output "ssl_certificate_status" {
  description = "SSL certificate status"
  value       = digitalocean_certificate.main.state
}

#==============================================================================
# CDN INFORMATION
#==============================================================================

output "cdn_endpoint" {
  description = "CDN endpoint URL (if enabled)"
  value       = length(digitalocean_cdn.main) > 0 ? digitalocean_cdn.main[0].endpoint : null
}

output "cdn_custom_domain" {
  description = "CDN custom domain (if enabled)"
  value       = length(digitalocean_cdn.main) > 0 ? digitalocean_cdn.main[0].custom_domain : null
}

output "cdn_status" {
  description = "CDN status (if enabled)"
  value       = length(digitalocean_cdn.main) > 0 ? digitalocean_cdn.main[0].status : null
}

#==============================================================================
# STORAGE INFORMATION
#==============================================================================

output "uploads_bucket_name" {
  description = "Uploads bucket name"
  value       = digitalocean_spaces_bucket.uploads.name
}

output "uploads_bucket_endpoint" {
  description = "Uploads bucket endpoint"
  value       = digitalocean_spaces_bucket.uploads.bucket_domain_name
}

output "uploads_bucket_region" {
  description = "Uploads bucket region"
  value       = digitalocean_spaces_bucket.uploads.region
}

output "backups_bucket_name" {
  description = "Backups bucket name (if created)"
  value       = length(digitalocean_spaces_bucket.backups) > 0 ? digitalocean_spaces_bucket.backups[0].name : null
}

output "backups_bucket_endpoint" {
  description = "Backups bucket endpoint (if created)"
  value       = length(digitalocean_spaces_bucket.backups) > 0 ? digitalocean_spaces_bucket.backups[0].bucket_domain_name : null
}

#==============================================================================
# APPLICATION CONFIGURATION
#==============================================================================

output "app_configuration" {
  description = "Application configuration summary"
  value = {
    name               = var.name_prefix
    environment        = var.environment
    region             = var.region
    domain            = var.domain_name
    web_instances     = var.web_instance_count
    api_instances     = var.api_instance_count
    worker_instances  = var.worker_instance_count
    web_size          = var.web_instance_size
    api_size          = var.api_instance_size
    github_repo       = var.github_repo
    github_branch     = var.github_branch
    cdn_enabled       = var.enable_cdn
    monitoring_enabled = var.enable_monitoring
  }
}

#==============================================================================
# DEPLOYMENT INFORMATION
#==============================================================================

output "deployment_info" {
  description = "Deployment information"
  value = {
    app_platform_console = "https://cloud.digitalocean.com/apps/${digitalocean_app.chatbotai.id}"
    live_url            = digitalocean_app.chatbotai.live_url
    custom_domain       = var.domain_name
    ssl_status          = digitalocean_certificate.main.state
    created_at          = digitalocean_app.chatbotai.created_at
    updated_at          = digitalocean_app.chatbotai.updated_at
  }
}

#==============================================================================
# SERVICE HEALTH
#==============================================================================

output "service_health" {
  description = "Service health check endpoints"
  value = {
    web_health    = "https://${var.domain_name}/"
    api_health    = "https://${var.domain_name}/api/health"
    worker_health = "Background worker (no HTTP endpoint)"
    database_pool = "Internal connection pool status"
  }
}

#==============================================================================
# SCALING INFORMATION
#==============================================================================

output "scaling_config" {
  description = "Current scaling configuration"
  value = {
    web = {
      current_instances = var.web_instance_count
      instance_size    = var.web_instance_size
      auto_scaling     = var.enable_auto_scaling
    }
    api = {
      current_instances = var.api_instance_count
      instance_size    = var.api_instance_size
      auto_scaling     = var.enable_auto_scaling
    }
    worker = {
      current_instances = var.worker_instance_count
      instance_size    = var.worker_instance_size
      concurrency      = var.worker_concurrency
    }
  }
}

#==============================================================================
# MONITORING ENDPOINTS
#==============================================================================

output "monitoring_config" {
  description = "Monitoring and alerting configuration"
  value = {
    enabled                = var.enable_monitoring
    cpu_threshold         = var.cpu_alert_threshold
    memory_threshold      = var.memory_alert_threshold
    response_time_threshold = var.response_time_threshold
    health_checks_enabled = var.enable_health_checks
  }
}

#==============================================================================
# SECURITY CONFIGURATION
#==============================================================================

output "security_config" {
  description = "Security configuration summary"
  value = {
    ssl_enabled           = true
    force_https          = var.enable_ssl_redirect
    cors_enabled         = var.enable_cors
    rate_limiting        = var.enable_rate_limiting
    audit_logging        = var.enable_audit_logging
    gdpr_compliance      = var.enable_gdpr_compliance
    adult_content_warnings = var.enable_adult_content_warnings
    minimum_age          = var.minimum_user_age
  }
}

#==============================================================================
# STORAGE CONFIGURATION
#==============================================================================

output "storage_config" {
  description = "Storage and backup configuration"
  value = {
    uploads_enabled      = var.enable_file_uploads
    max_file_size_mb    = var.max_file_size_mb
    backup_retention    = var.backup_retention_days
    data_retention      = var.data_retention_days
    uploads_bucket      = digitalocean_spaces_bucket.uploads.name
    backups_bucket      = length(digitalocean_spaces_bucket.backups) > 0 ? digitalocean_spaces_bucket.backups[0].name : null
  }
}

#==============================================================================
# COST ESTIMATION
#==============================================================================

output "estimated_monthly_cost" {
  description = "Estimated monthly cost breakdown"
  value = {
    web_instances = {
      count = var.web_instance_count
      size  = var.web_instance_size
      note  = "React frontend instances"
    }
    api_instances = {
      count = var.api_instance_count
      size  = var.api_instance_size
      note  = "Python FastAPI backend instances"
    }
    worker_instances = {
      count = var.worker_instance_count
      size  = var.worker_instance_size
      note  = "Background worker instances"
    }
    storage = {
      uploads_bucket = "Pay per usage"
      backups_bucket = length(digitalocean_spaces_bucket.backups) > 0 ? "Production only" : "Not created"
      note = "Storage costs based on usage"
    }
    cdn = {
      enabled = var.enable_cdn
      note    = var.enable_cdn ? "Pay per bandwidth usage" : "Disabled"
    }
    ssl_certificate = {
      cost = "Free (Let's Encrypt)"
      note = "Automatic renewal"
    }
    total_note = "Actual costs depend on instance usage, storage, and bandwidth"
  }
}

#==============================================================================
# INTEGRATION ENDPOINTS
#==============================================================================

output "integration_endpoints" {
  description = "Integration endpoints for external services"
  value = {
    stripe_webhook = "https://${var.domain_name}/api/webhooks/stripe"
    telegram_webhook = var.telegram_bot_token != "" ? "https://${var.domain_name}/api/webhooks/telegram" : null
    health_check = "https://${var.domain_name}/api/health"
    metrics = "https://${var.domain_name}/api/metrics"
    admin_api = "https://${var.domain_name}/api/admin"
  }
}

#==============================================================================
# DEBUGGING INFORMATION
#==============================================================================

output "debug_info" {
  description = "Debug information for development environments"
  value = var.environment != "production" ? {
    app_platform_id     = digitalocean_app.chatbotai.id
    default_ingress     = digitalocean_app.chatbotai.default_ingress
    active_deployment   = digitalocean_app.chatbotai.active_deployment_id
    in_progress_deployment = digitalocean_app.chatbotai.in_progress_deployment
    spec_name          = digitalocean_app.chatbotai.spec[0].name
  } : null
  sensitive = var.environment != "production"
}