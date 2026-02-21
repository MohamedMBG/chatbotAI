# ChatbotAI App Platform Module
# Managed application deployment on DigitalOcean App Platform

#==============================================================================
# APP PLATFORM APPLICATION
#==============================================================================

resource "digitalocean_app" "chatbotai" {
  spec {
    name   = var.name_prefix
    region = var.region
    
    # Domain configuration
    domain {
      name = var.domain_name
      type = "DEFAULT"
      zone = var.domain_name
    }
    
    # Frontend React Application
    service {
      name               = "web"
      source_dir         = "frontend/"
      build_command      = "npm run build"
      run_command        = "npm start"
      environment_slug   = "node-js"
      instance_count     = var.web_instance_count
      instance_size_slug = var.web_instance_size
      http_port          = 3000
      
      # GitHub source configuration
      github {
        repo           = var.github_repo
        branch         = var.github_branch
        deploy_on_push = true
      }
      
      # Frontend environment variables
      env {
        key   = "NODE_ENV"
        value = var.environment == "production" ? "production" : "development"
      }
      
      env {
        key   = "REACT_APP_API_URL"
        value = "https://${var.domain_name}/api"
      }
      
      env {
        key   = "REACT_APP_ENVIRONMENT"
        value = var.environment
      }
      
      env {
        key   = "REACT_APP_STRIPE_PUBLISHABLE_KEY"
        value = var.stripe_publishable_key
      }
      
      env {
        key   = "REACT_APP_DOMAIN"
        value = var.domain_name
      }
      
      # Health check
      health_check {
        http_path = "/"
        initial_delay_seconds = 30
        period_seconds = 30
        timeout_seconds = 5
        success_threshold = 1
        failure_threshold = 3
      }
      
      # CORS configuration for adult content
      cors {
        allow_origins     = ["https://${var.domain_name}", "https://www.${var.domain_name}"]
        allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
        allow_headers     = ["*"]
        expose_headers    = ["*"]
        max_age           = 86400
        allow_credentials = true
      }
    }
    
    # Backend API Application (Python/FastAPI)
    service {
      name               = "api"
      source_dir         = "backend/"
      build_command      = "pip install -r requirements.txt"
      run_command        = "gunicorn --bind 0.0.0.0:8000 --workers 4 --worker-class uvicorn.workers.UvicornWorker main:app"
      environment_slug   = "python"
      instance_count     = var.api_instance_count
      instance_size_slug = var.api_instance_size
      http_port          = 8000
      
      # GitHub source configuration
      github {
        repo           = var.github_repo
        branch         = var.github_branch
        deploy_on_push = true
      }
      
      # Backend environment variables
      env {
        key   = "ENVIRONMENT"
        value = var.environment
      }
      
      env {
        key   = "DATABASE_URL"
        value = var.postgres_connection_uri
        type  = "SECRET"
      }
      
      env {
        key   = "REDIS_URL"
        value = var.redis_connection_uri
        type  = "SECRET"
      }
      
      env {
        key   = "STRIPE_SECRET_KEY"
        value = var.stripe_secret_key
        type  = "SECRET"
      }
      
      env {
        key   = "STRIPE_WEBHOOK_SECRET"
        value = var.stripe_webhook_secret
        type  = "SECRET"
      }
      
      env {
        key   = "JWT_SECRET_KEY"
        value = var.jwt_secret_key
        type  = "SECRET"
      }
      
      env {
        key   = "TELEGRAM_BOT_TOKEN"
        value = var.telegram_bot_token
        type  = "SECRET"
      }
      
      env {
        key   = "OPENAI_API_KEY"
        value = var.openai_api_key != "" ? var.openai_api_key : "not-configured"
        type  = "SECRET"
      }
      
      env {
        key   = "ENCRYPTION_KEY"
        value = var.encryption_key
        type  = "SECRET"
      }
      
      env {
        key   = "CORS_ORIGINS"
        value = "https://${var.domain_name},https://www.${var.domain_name}"
      }
      
      env {
        key   = "ALLOWED_HOSTS"
        value = "${var.domain_name},www.${var.domain_name},*.ondigitalocean.app"
      }
      
      env {
        key   = "LOG_LEVEL"
        value = var.environment == "production" ? "INFO" : "DEBUG"
      }
      
      env {
        key   = "TRIAL_DURATION_MINUTES"
        value = "120"  # 2-hour trial
      }
      
      env {
        key   = "ENABLE_ADULT_CONTENT"
        value = "true"
      }
      
      env {
        key   = "GDPR_COMPLIANCE"
        value = "true"
      }
      
      # Health check
      health_check {
        http_path = "/api/health"
        initial_delay_seconds = 60
        period_seconds = 30
        timeout_seconds = 10
        success_threshold = 1
        failure_threshold = 3
      }
    }
    
    # Background Worker Service (for async tasks)
    worker {
      name               = "worker"
      source_dir         = "backend/"
      build_command      = "pip install -r requirements.txt"
      run_command        = "python worker.py"
      environment_slug   = "python"
      instance_count     = var.environment == "production" ? 2 : 1
      instance_size_slug = "basic-xxs"
      
      # GitHub source configuration
      github {
        repo           = var.github_repo
        branch         = var.github_branch
        deploy_on_push = true
      }
      
      # Same environment variables as API (for database access)
      env {
        key   = "ENVIRONMENT"
        value = var.environment
      }
      
      env {
        key   = "DATABASE_URL"
        value = var.postgres_connection_uri
        type  = "SECRET"
      }
      
      env {
        key   = "REDIS_URL"
        value = var.redis_connection_uri
        type  = "SECRET"
      }
      
      env {
        key   = "STRIPE_SECRET_KEY"
        value = var.stripe_secret_key
        type  = "SECRET"
      }
      
      env {
        key   = "JWT_SECRET_KEY"
        value = var.jwt_secret_key
        type  = "SECRET"
      }
      
      env {
        key   = "TELEGRAM_BOT_TOKEN"
        value = var.telegram_bot_token
        type  = "SECRET"
      }
      
      env {
        key   = "LOG_LEVEL"
        value = var.environment == "production" ? "INFO" : "DEBUG"
      }
      
      env {
        key   = "WORKER_CONCURRENCY"
        value = var.environment == "production" ? "4" : "2"
      }
    }
    
    # Static site for landing pages (if using separate static content)
    static_site {
      name         = "static"
      source_dir   = "static/"
      build_command = "npm run build:static"
      output_dir   = "dist"
      
      # GitHub source configuration
      github {
        repo           = var.github_repo
        branch         = var.github_branch
        deploy_on_push = true
      }
      
      # Environment variables for static build
      env {
        key   = "NODE_ENV"
        value = var.environment == "production" ? "production" : "development"
      }
      
      env {
        key   = "VITE_API_URL"
        value = "https://${var.domain_name}/api"
      }
      
      # Route configuration for SPA
      routes {
        path = "/*"
      }
    }
    
    # Job for database migrations
    job {
      name               = "migrate"
      source_dir         = "backend/"
      build_command      = "pip install -r requirements.txt"
      run_command        = "python manage.py migrate"
      environment_slug   = "python"
      instance_count     = 1
      instance_size_slug = "basic-xxs"
      kind              = "PRE_DEPLOY"  # Run before deployment
      
      # GitHub source configuration
      github {
        repo           = var.github_repo
        branch         = var.github_branch
        deploy_on_push = true
      }
      
      # Database connection for migrations
      env {
        key   = "DATABASE_URL"
        value = var.postgres_connection_uri
        type  = "SECRET"
      }
      
      env {
        key   = "ENVIRONMENT"
        value = var.environment
      }
      
      env {
        key   = "LOG_LEVEL"
        value = "INFO"
      }
    }
    
    # Database configuration (references to managed databases)
    database {
      name        = "${var.name_prefix}-postgres"
      engine      = "PG"
      production  = var.environment == "production"
      cluster_name = var.postgres_cluster_name
    }
    
    # Alerts and monitoring configuration
    alert {
      rule = "CPU_UTILIZATION"
      operator = "GREATER_THAN"
      value = 80
      window = "5m"
      disabled = false
    }
    
    alert {
      rule = "MEM_UTILIZATION"
      operator = "GREATER_THAN"
      value = 85
      window = "5m"
      disabled = false
    }
    
    alert {
      rule = "RESPONSE_TIME"
      operator = "GREATER_THAN"
      value = 5000  # 5 seconds
      window = "5m"
      disabled = false
    }
    
    # Ingress configuration
    ingress {
      rule {
        match {
          path {
            prefix = "/api/"
          }
        }
        component {
          name = "api"
        }
      }
      
      rule {
        match {
          path {
            prefix = "/static/"
          }
        }
        component {
          name = "static"
        }
      }
      
      rule {
        match {
          path {
            prefix = "/"
          }
        }
        component {
          name = "web"
        }
      }
    }
  }
  
  # Lifecycle management
  lifecycle {
    ignore_changes = [
      spec[0].service[0].source_dir,
      spec[0].service[1].source_dir,
      spec[0].worker[0].source_dir,
      spec[0].static_site[0].source_dir,
      spec[0].job[0].source_dir
    ]
  }
}

#==============================================================================
# SSL CERTIFICATE (Let's Encrypt)
#==============================================================================

resource "digitalocean_certificate" "main" {
  name    = "${var.name_prefix}-cert"
  type    = "lets_encrypt"
  domains = [var.domain_name, "www.${var.domain_name}"]
  
  lifecycle {
    create_before_destroy = true
  }
}

#==============================================================================
# CDN CONFIGURATION (for static assets)
#==============================================================================

resource "digitalocean_cdn" "main" {
  count = var.enable_cdn ? 1 : 0
  
  origin           = digitalocean_app.chatbotai.live_url
  custom_domain    = "cdn.${var.domain_name}"
  certificate_name = digitalocean_certificate.main.name
  ttl              = 3600
}

#==============================================================================
# SPACES BUCKET (for file uploads, backups)
#==============================================================================

resource "digitalocean_spaces_bucket" "uploads" {
  name   = "${replace(var.name_prefix, "_", "-")}-uploads"
  region = var.region
  
  # CORS configuration for file uploads
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "DELETE"]
    allowed_origins = ["https://${var.domain_name}", "https://www.${var.domain_name}"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3600
  }
  
  # Lifecycle configuration
  lifecycle_rule {
    id      = "cleanup_temp_files"
    enabled = true
    
    expiration {
      days = 7
    }
    
    filter {
      prefix = "temp/"
    }
  }
  
  # Versioning for important files
  versioning {
    enabled = var.environment == "production"
  }
}

# Spaces bucket for backups
resource "digitalocean_spaces_bucket" "backups" {
  count = var.environment == "production" ? 1 : 0
  
  name   = "${replace(var.name_prefix, "_", "-")}-backups"
  region = var.region
  
  # Lifecycle for backup retention
  lifecycle_rule {
    id      = "backup_retention"
    enabled = true
    
    expiration {
      days = 30
    }
    
    filter {
      prefix = "database/"
    }
  }
  
  # Enable versioning for backup files
  versioning {
    enabled = true
  }
}