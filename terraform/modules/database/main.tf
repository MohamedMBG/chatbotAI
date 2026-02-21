# ChatbotAI Database Module
# Managed PostgreSQL and Redis clusters

#==============================================================================
# POSTGRESQL DATABASE CLUSTER
#==============================================================================

resource "digitalocean_database_cluster" "postgres" {
  name       = "${var.name_prefix}-postgres"
  engine     = "pg"
  version    = var.postgres_version
  size       = var.postgres_size
  region     = var.region
  node_count = var.postgres_nodes
  
  # Private networking for security
  private_network_uuid = var.vpc_uuid
  
  # Maintenance window (low-traffic hours)
  maintenance_window {
    day  = var.maintenance_day
    hour = var.maintenance_hour
  }
  
  # Backup configuration
  backup_restore {
    database_name = var.postgres_database_name
  }
  
  tags = concat(
    [var.environment, "database", "postgres", "chatbotai"],
    [for k, v in var.tags : "${k}:${v}"]
  )
}

# Create application database
resource "digitalocean_database_db" "chatbotai" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = var.postgres_database_name
}

# Create application database user
resource "digitalocean_database_user" "chatbotai" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = var.postgres_username
}

# Create read-only user for analytics/reporting
resource "digitalocean_database_user" "readonly" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "${var.postgres_username}_readonly"
}

#==============================================================================
# REDIS CLUSTER (for sessions, caching, rate limiting)
#==============================================================================

resource "digitalocean_database_cluster" "redis" {
  name       = "${var.name_prefix}-redis"
  engine     = "redis"
  version    = var.redis_version
  size       = var.redis_size
  region     = var.region
  node_count = var.redis_nodes
  
  # Private networking
  private_network_uuid = var.vpc_uuid
  
  # Maintenance window (same as PostgreSQL)
  maintenance_window {
    day  = var.maintenance_day
    hour = var.maintenance_hour
  }
  
  # Redis configuration
  redis_config {
    redis_maxmemory_policy             = "allkeys-lru"  # LRU eviction for cache
    redis_notify_keyspace_events       = "Ex"          # Enable keyspace events for TTL
    redis_timeout                      = 300           # Connection timeout
    redis_tcp_keepalive                = 60            # TCP keepalive
  }
  
  tags = concat(
    [var.environment, "cache", "redis", "chatbotai"],
    [for k, v in var.tags : "${k}:${v}"]
  )
}

#==============================================================================
# DATABASE CONNECTION POOLS (for better performance)
#==============================================================================

resource "digitalocean_database_connection_pool" "chatbotai" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "${var.postgres_database_name}_pool"
  mode       = "transaction"  # Good for web applications
  size       = var.connection_pool_size
  db_name    = digitalocean_database_db.chatbotai.name
  user       = digitalocean_database_user.chatbotai.name
}

# Read-only connection pool for analytics
resource "digitalocean_database_connection_pool" "readonly" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "${var.postgres_database_name}_readonly_pool"
  mode       = "session"  # Better for analytics queries
  size       = var.readonly_pool_size
  db_name    = digitalocean_database_db.chatbotai.name
  user       = digitalocean_database_user.readonly.name
}

#==============================================================================
# DATABASE REPLICAS (for production read scaling)
#==============================================================================

resource "digitalocean_database_replica" "postgres_read" {
  count      = var.environment == "production" && var.enable_read_replica ? 1 : 0
  
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "${var.name_prefix}-postgres-read"
  region     = var.region
  size       = var.postgres_size
  
  private_network_uuid = var.vpc_uuid
  
  tags = concat(
    [var.environment, "database", "postgres-replica", "chatbotai"],
    [for k, v in var.tags : "${k}:${v}"]
  )
}

#==============================================================================
# DATABASE FIREWALL RULES
#==============================================================================

resource "digitalocean_database_firewall" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id
  
  # Allow access from VPC only
  rule {
    type  = "tag"
    value = var.environment
  }
  
  # Allow access from app tier
  rule {
    type  = "tag"
    value = "app-tier"
  }
  
  # Allow access from specific IPs (for admin/debugging)
  dynamic "rule" {
    for_each = var.allowed_admin_ips
    content {
      type  = "ip_addr"
      value = rule.value
    }
  }
}

resource "digitalocean_database_firewall" "redis" {
  cluster_id = digitalocean_database_cluster.redis.id
  
  # Allow access from VPC only
  rule {
    type  = "tag"
    value = var.environment
  }
  
  # Allow access from app tier
  rule {
    type  = "tag" 
    value = "app-tier"
  }
  
  # Redis typically doesn't need admin access from outside
}

#==============================================================================
# DATABASE MONITORING
#==============================================================================

# PostgreSQL monitoring alerts
resource "digitalocean_monitor_alert" "postgres_cpu" {
  count = var.enable_monitoring ? 1 : 0
  
  alerts {
    email = var.alert_emails
    slack {
      channel = "#database-alerts"
      url     = var.slack_webhook_url
    }
  }
  
  window      = "5m"
  type        = "v1/insights/database/cpu"
  compare     = "GreaterThan"
  value       = 80
  enabled     = true
  entities    = [digitalocean_database_cluster.postgres.id]
  description = "PostgreSQL CPU usage is high in ${var.environment}"
}

resource "digitalocean_monitor_alert" "postgres_memory" {
  count = var.enable_monitoring ? 1 : 0
  
  alerts {
    email = var.alert_emails
    slack {
      channel = "#database-alerts"
      url     = var.slack_webhook_url
    }
  }
  
  window      = "5m"
  type        = "v1/insights/database/memory_utilization_percent"
  compare     = "GreaterThan"
  value       = 85
  enabled     = true
  entities    = [digitalocean_database_cluster.postgres.id]
  description = "PostgreSQL memory usage is high in ${var.environment}"
}

# Redis monitoring alerts
resource "digitalocean_monitor_alert" "redis_memory" {
  count = var.enable_monitoring ? 1 : 0
  
  alerts {
    email = var.alert_emails
    slack {
      channel = "#database-alerts"
      url     = var.slack_webhook_url
    }
  }
  
  window      = "5m"
  type        = "v1/insights/database/memory_utilization_percent"
  compare     = "GreaterThan"
  value       = 90
  enabled     = true
  entities    = [digitalocean_database_cluster.redis.id]
  description = "Redis memory usage is high in ${var.environment}"
}

#==============================================================================
# BACKUP CONFIGURATION
#==============================================================================

# Additional backup configuration for production
resource "digitalocean_database_backup" "postgres_manual" {
  count      = var.environment == "production" ? 1 : 0
  cluster_id = digitalocean_database_cluster.postgres.id
  type       = "manual"
}

#==============================================================================
# DATABASE USERS WITH PROPER PERMISSIONS
#==============================================================================

# Create additional users for different access patterns
resource "digitalocean_database_user" "app_write" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "${var.postgres_username}_write"
}

resource "digitalocean_database_user" "analytics" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "${var.postgres_username}_analytics"
}

resource "digitalocean_database_user" "backup" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = "${var.postgres_username}_backup"
}